local Anim = require("mod.elona_sys.api.Anim")
local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Effect = require("mod.elona.api.Effect")
local ElonaPos = require("mod.elona.api.ElonaPos")
local Pos = require("api.Pos")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Queue = require("api.Queue")

-- Magic, action, and item effects.
--
-- In vanilla, there are three main categories of "effects".
--   Magic: Treated as skills with level/potential.
--   Actions: Activatable through certain menus, items or AI.
--   Effects: Activatable through items only.
--
-- This division accomplished the following:
--   - Magic can be leveled up like passive skills and also be triggered in the
--     code like runEffect(magic_revealMap).
--   - Actions have different damage calculations than magic, because they don't
--     have skill levels, so the damage depends on the casting character's stats
--     instead.
--   - Effects have a predetermined power that is passed in to the effect runner.
--   - All three effect types can be triggered programmatically.
--
-- In OpenNefia, the effect system is decoupled from skill levels and actions.
-- Now the intention is that learnable skills or magic with an associated effect
-- would declare a new "base.skill" entry and label it as an action or magic.
-- That "base.skill" entry would contain a callback which would then call
-- Magic.cast() with the ID of the "elona_sys.magic" entry to trigger. The
-- callback would be run when the magic/action entry is selected in the
-- magic/action menus, which are populated by filtering the list of "base.skill"
-- entries.

local RANGE_BOLT = 6
local RANGE_BALL = 2
local RANGE_BREATH = 5

local function per_curse_state(curse_state, doomed, cursed, none, blessed)
   if curse_state == "doomed" then
      return doomed
   elseif curse_state == "cursed" then
      return cursed
   elseif curse_state == "blessed" then
      return blessed
   end

   return none
end

local function is_in_screen(sx, sy)
   local msg_y = Gui.message_window_y()
   return sy >= 0 and sy <= msg_y
      and sx >= 0 and sx <= Draw.get_width()
end

local function sp_check(source, skill)
   local sp_cost = skill.cost / 2 + 1
   if source.stamina < 50 and source.stamina < Rand.rnd(75) then
      Gui.mes("magic.common.too_exhausted")
      source:damage_sp(sp_cost)
      return false
   end
   source:damage_sp(Rand.rnd(sp_cost) + sp_cost)
   return true
end

data:add {
   _id = "love_potion",
   _type = "elona_sys.magic",
   elona_id = 1135,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      if Effect.is_cursed(params.curse_state) then
         if params.target:is_player() then
         else
            Gui.mes("magic.love_potion.cursed", params.target)
            Skill.modify_impression(params.target, -15)
         end
         return true, { obvious = false }
      end

      local function love_miracle(chara)
         if Rand.one_in(2) or chara:is_player() then
            return
         end
         Gui.mes_c("misc.love_miracle.uh", "Cyan")
         if Rand.one_in(2) then
            local item = Item.create("elona.egg", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params = { chara_id = chara._id }
               local weight = chara:calc("weight")
               item.weight = weight * 10 + 250
               item.value = math.clamp(math.floor(weight * weight / 10000), 200, 40000)
            end
         else
            local item = Item.create("elona.bottle_of_milk", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params = { chara_id = chara._id }
            end
         end

         Gui.play_sound("base.atk_elec")
         local anim = Anim.load("elona.anim_elec", chara.x, chara.y)
         Gui.start_draw_callback(anim)
      end

      -- TODO emotion icon
      if params.potion_spilt or params.potion_thrown then
         Gui.mes("magic.love_potion.spill", params.target)
         Skill.modify_impression(params.target, math.clamp(params.power / 15, 0, 15))
         params.target:apply_effect("elona.dimming", 100)
         love_miracle(params.target)
         return true
      end

      if params.target:is_player() then
         Gui.mes("magic.love_potion.self", params.target)
      else
         Gui.mes("magic.love_potion.other", params.target)
         love_miracle(params.target)
         Skill.modify_impression(params.target, math.clamp(params.power / 4, 0, 25))
      end

      params.target:apply_effect("elona.dimming", 500)
      return true
   end
}

data:add {
   _id = "pregnancy",
   _type = "elona_sys.magic",
   elona_id = 626,

   type = "action",
   params = {
      "source",
      "target",
   },

   skill = "elona.stat_perception",
   cost = 15,
   range = 2001,

   cast = function(self, params)
      if params.target:is_in_fov() then
         Gui.mes("magic.pregnant", params.source, params.target)
      end

      Effect.impregnate(params.target)

      return true
   end
}

data:add {
   _id = "milk",
   _type = "elona_sys.magic",
   elona_id = 1101,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.play_sound("base.atk_elec")
         if Effect.is_cursed(params.curse_state) then
            if target:is_player() then
               Gui.mes("magic.milk.cursed.self")
            else
               Gui.mes_c("magic.milk.cursed.other", "Cyan")
            end
         elseif target:is_player() then
            Gui.mes("magic.milk.self")
         else
            Gui.mes_c("magic.milk.other", "Cyan")
         end
      end

      if params.curse_state == "blessed" then
         Effect.modify_height(target, Rand.rnd(5) + 1)
      elseif Effect.is_cursed(params.curse_state) then
         Effect.modify_height(target, (Rand.rnd(5) + 1) * -1)
      end

      target.nutrition = target.nutrition + 1000 * math.floor(params.power / 100)
      if target:is_player() then
         Effect.show_eating_message(target)
      end

      Effect.apply_food_curse_state(target, params.curse_state)
      local anim = Anim.load("elona.anim_elec", target.x, target.y)
      Gui.start_draw_callback(anim)

      return true
   end
}

data:add {
   _id = "alcohol",
   _type = "elona_sys.magic",
   elona_id = 1102,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if Effect.is_cursed(params.curse_state) then
            Gui.mes_c("magic.alcohol.cursed", "Cyan")
         else
            Gui.mes_c("magic.alcohol.normal", "Cyan")
         end
      end

      target:apply_effect("elona.drunk", params.power)
      Effect.apply_food_curse_state(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "potion_acid",
   _type = "elona_sys.magic",
   elona_id = 1102,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.acid.self")
         end
         Gui.mes("magic.acid.apply", target)
      end

      if target.is_pregnant then
         target.is_pregnant = false
         if target:is_in_fov() then
            Gui.mes("magic.common.melts_alien_children", target)
         end
      end

      target:damage_hp(params.power * per_curse_state(params.curse_state, 500, 400, 100, 50) / 1000,
                       "elona.acid",
                       {element="elona.acid", element_power=params.power})

      return true
   end
}

data:add {
   _id = "potion_water",
   _type = "elona_sys.magic",
   elona_id = 1103,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.water.self")
         else
            Gui.mes("magic.water.other")
         end
      end

      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "potion_restore_stamina",
   _type = "elona_sys.magic",
   elona_id = 1146,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.mes("magic.restore_stamina.dialog")
         Gui.mes("magic.restore_stamina.apply", target)
      end

      target:heal_stamina(25)
      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "potion_restore_stamina_greater",
   _type = "elona_sys.magic",
   elona_id = 1147,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         Gui.mes("magic.restore_stamina_greater.dialog")
         Gui.mes("magic.restore_stamina_greater.apply", target)
      end

      target:heal_stamina(100)
      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "potion_salt",
   _type = "elona_sys.magic",
   elona_id = 1142,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if target.race == "elona.snail" then
         if target:is_in_fov() then
            Gui.mes_c("magic.salt.snail", "Red", target)
         end
         if target.hp > 10 then
            target:damage_hp(target.hp - Rand.rnd(10), "elona.acid")
         else
            target:damage_hp(Rand.rnd(20000), "elona.acid")
         end
      elseif target:is_in_fov() then
         Gui.mes_c("magic.salt.snail", "Cyan")
      end

      return true
   end
}

data:add {
   _id = "potion_dirty_water",
   _type = "elona_sys.magic",
   elona_id = 1130,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      if target:is_in_fov() then
         if target:is_player() then
            Gui.mes("magic.dirty_water.self")
         else
            Gui.mes("magic.dirty_water.other")
         end
      end

      Effect.proc_cursed_drink(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "pickpocket",
   _type = "elona_sys.magic",
   elona_id = 300,

   type = "skill",
   params = {
      "source",
      "target",
   },

   skill = "elona.stat_dexterity",
   cost = 20,
   range = 8000,

   cast = function(self, params)
      -- TODO
      if false then
         Gui.mes("magic.steal.in_quest")
         return false
      end

      local source = params.source
      if source:is_player() and not sp_check(source, self) then
         return true
      end

      Input.query_inventory(source, "elona.inv_steal", {target=params.target})

      return true
   end
}

data:add {
   _id = "riding",
   _type = "elona_sys.magic",
   elona_id = 301,

   type = "skill",
   params = {
      "source",
      "target",
   },

   skill = "elona.stat_will",
   cost = 20,
   range = 8000,

   cast = function(self, params)
      -- TODO
      return true
   end
}

data:add {
   _id = "performer",
   _type = "elona_sys.magic",
   elona_id = 183,

   type = "skill",
   params = {
      "source",
      "target",
   },

   skill = "elona.stat_charisma",
   cost = 25,
   range = 10000,

   cast = function(self, params)
      local source = params.source
      if not source:is_player() then
         local found = false
         for _, i in source:iter_items() do
            if Item.is_alive(i) and i.skill == "elona.performer" then
               params.item = i
               found = true
               break
            end
         end
         if not found then
            return false
         end
      end

      if not source:has_skill("elona.performer") then
         if source:is_in_fov() then
            Gui.mes("magic.perform.do_not_know", source)
         end
         return false
      end

      if source:is_player() and not sp_check(source, self) then
         return true
      end

      source:start_activity("elona.performer")

      return true
   end
}

local function cook(chara, item, cooking_tool)
   Gui.play_sound("base.cook1")
   local sep = item:separate()
   local cooking = chara:skill_level("elona.cooking")

   local food_quality = Rand.rnd(cooking + 7) + Rand.rnd
end

data:add {
   _id = "cooking",
   _type = "elona_sys.magic",
   elona_id = 184,

   type = "skill",
   params = {
      "source",
      "item",
   },

   skill = "elona.stat_learning",
   cost = 15,
   range = 10000,

   cast = function(self, params)
      local source = params.source
      if not source:has_skill("elona.cooking") then
         Gui.mes("magic.cook.do_not_know")
         return false
      end

      local item, canceled = Input.query_item(source, "elona.inv_cook")
      if canceled then
         return false
      end

      if source:is_player() and not sp_check(source, self) then
         return true
      end

      cook(source, item, params.item)

      return true
   end
}

data:add {
   _id = "return",
   _type = "elona_sys.magic",
   elona_id = 428,

   type = "skill",
   params = {
      "source"
   },

   skill = "elona.stat_perception",
   cost = 20,
   range = 10000,
   difficulty = 550,

   cast = function(self, params)
      local source = params.source
      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local s = save.elona
      if s.turns_until_cast_return ~= 0 then
         Gui.mes("magic.return.cancel")
         s.turns_until_cast_return = 0
      else
         local map_uid = Effect.query_return_location(source)

         if Effect.is_cursed(params.curse_state) and Rand.one_in(3) then
            Gui.mes("jail") -- TODO
         end

         if map_uid then
            s.return_destination_map_uid = map_uid
            s.turns_until_cast_return = 15 + Rand.rnd(15)
         end
      end

      return true
   end
}

---
--- Skills
---


-- attack (spore)

-- bolt

local function make_bolt(element_id, elona_id, dice_x, dice_y, dice_element_power, cost, difficulty)
   local id = element_id .. "_bolt"
   local full_id = "elona.magic_" .. id
   element_id = "elona." .. element_id

   data:add {
      _id = "magic_" .. id,
      _type = "base.skill",

      type = "magic",
      related_skill = "elona.stat_magic",
      cost = cost,
      range = RANGE_BOLT,
      difficulty = difficulty,
      target_type = "both"
   }

   data:add {
      _id = id,
      _type = "elona_sys.magic",
      elona_id = elona_id,

      type = "action",
      params = {
         "source"
      },

      dice = function(self, params)
         local level = params.source:skill_level(full_id)
         return {
            x = dice_x(params.power, level),
            y = dice_y(params.power, level),
            bonus = 0,
            element_power = dice_element_power(params.power, level)
         }
      end,

      cast = function(self, params)
         local source = params.source
         local map = params.source:current_map()
         local sx = params.source.x
         local sy = params.source.y
         local positions, success = ElonaPos.make_route(sx, sy, params.x, params.y, map)
         if not success then
            return false
         end

         local element, color, sound
         if element_id then
            element = data["base.element"]:ensure(element_id)
            color = element.color
            sound = element.sound
         end

         local cb = Anim.bolt(positions, color, sound, sx, sy, params.x, params.y, params.range, map)
         Gui.start_draw_callback(cb)

         local tx = sx
         local ty = sy

         for i = 0, 19 do
            local pos = positions[(i%#positions)+1]
            local dx = pos[1]
            local dy = pos[2]
            tx = tx + dx
            ty = ty + dy

            if i <= #positions or (map:is_in_bounds(tx, ty) and map:can_see_through(tx, ty) and is_in_screen(tx, ty)) then
               if Pos.dist(sx, sy, tx, ty) > params.range then
                  break
               end

               if sx ~= tx or sy ~= ty then
                  if element and element.on_damage_tile then
                     element:on_damage_tile(tx, ty)
                  end
                  local target = Chara.at(tx, ty, map)
                  if target and target ~= source then
                     -- TODO riding
                     local dice = self:dice(params)
                     require("api.Log").info("%s %s", inspect(params), inspect(dice))
                     local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)

                     local success, damage = SkillCheck.handle_control_magic(source, target, damage)
                     if not success then
                        local tense = "enemy"
                        if not target:is_ally() then
                           tense = "ally"
                        end
                        if tense == "ally" then
                           Gui.mes_visible("magic.bolt.other", tx, ty, target)
                        else
                           Gui.mes_visible("magic.bolt.ally", tx, ty, target)
                        end
                        target:damage_hp(damage,
                                         source,
                                         {
                                            element = element,
                                            element_power = dice.element_power,
                                            message_tense = tense,
                                            no_attack_text = true,
                                            is_third_person = true
                        })
                     end
                  end
               end
            end
         end
         return true
      end
   }
end

make_bolt("cold",      419, function(p, l) return p/50+1+l/20 end, function(p, l) return p/26+4 end, function(p, l) return 180+p/4 end, 10, 220)
make_bolt("fire",      420, function(p, l) return p/50+1+l/20 end, function(p, l) return p/26+4 end, function(p, l) return 180+p/4 end, 10, 220)
make_bolt("lightning", 421, function(p, l) return p/50+1+l/20 end, function(p, l) return p/26+4 end, function(p, l) return 180+p/4 end, 10, 220)
make_bolt("darkness",  422, function(p, l) return p/50+1+l/20 end, function(p, l) return p/25+4 end, function(p, l) return 180+p/4 end, 12, 350)
make_bolt("mind",      423, function(p, l) return p/50+1+l/20 end, function(p, l) return p/25+4 end, function(p, l) return 180+p/4 end, 12, 350)

-- arrow

-- ball (spSuicide)

local function make_ball(opts)
   local full_id = "elona.magic_" .. opts._id
   local type = opts.type or "magic"

   data:add {
      _id = type .. "_" .. opts._id,
      _type = "base.skill",

      type = type,
      related_skill = opts.related_skill,
      cost = opts.cost,
      range = RANGE_BALL,
      difficulty = opts.difficulty,
      target_type = "both"
   }

   data:add {
      _id = opts._id,
      _type = "elona_sys.magic",
      elona_id = opts.elona_id,

      type = "action",
      params = {
         "source"
      },

      dice = function(self, params)
         local level = params.source:skill_level(full_id)
         return {
            x = (opts.dice_x and opts.dice_x(params.power, level)) or 0,
            y = (opts.dice_y and opts.dice_y(params.power, level)) or 0,
            bonus = (opts.dice_bonus and opts.dice_bonus(params.power, level)) or 0,
            element_power = (opts.dice_element_power and opts.dice_element_power(params.power, level)) or 0
         }
      end,

      cast = function(self, params)
         local source = params.source
         local map = params.source:current_map()
         local x = params.source.x
         local y = params.source.y

         local positions = ElonaPos.make_ball(x, y, params.range, map)

         local element
         if opts.element_id then
            element = data["base.element"]:ensure(opts.element_id)
            local color = element.color
            local sound = element.sound

            local cb = Anim.ball(positions, color, sound, x, y, map)
            Gui.start_draw_callback(cb)
         end

         for _, pos in ipairs(positions) do
            local tx = pos[1]
            local ty = pos[2]

            local target = Chara.at(tx, ty)

            if target then
               opts.ball_cb(self, x, y, tx, ty, source, target, element, params)
            end
         end

         return true
      end
   }
end

local function ball_cb_elemental(self, x, y, tx, ty, source, target, element, params)
   if x == tx and y == ty then
      return
   end

   -- TODO riding
   if element and element.on_damage_tile then
      element:on_damage_tile(tx, ty)
   end

   local dice = self:dice(params)
   local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus) * 100 / (75 + Pos.dist(tx, ty, x, y) * 25)

   local success, damage = SkillCheck.handle_control_magic(source, target, damage)
   if not success then
      local tense = "enemy"
      if not target:is_ally() then
         tense = "ally"
      end
      if tense == "ally" then
         Gui.mes_visible("magic.ball.other", tx, ty, target)
      else
         Gui.mes_visible("magic.ball.ally", tx, ty, target)
      end

      target:damage_hp(damage,
                       source,
                       {
                          element = element,
                          element_power = params.element_power,
                          message_tense = tense,
                          no_attack_text = true,
                          is_third_person = true
      })
   end
end

make_ball {
   _id = "cold_ball",
   elona_id = 431,
   related_skill = "elona.stat_magic",
   element_id = "elona.cold",
   dice_x = function(p,l) return p/100+1+l/20 end,
   dice_y = function(p,l) return p/15+2 end,
   bonus = nil,
   element_power = function(p,l) return 150+p/5 end,
   cost = 16,
   difficulty = 450,
   ball_cb = ball_cb_elemental
}

make_ball {
   _id = "fire_ball",
   elona_id = 432,
   related_skill = "elona.stat_magic",
   element_id = "elona.fire",
   dice_x = function(p,l) return p/100+1+l/20 end,
   dice_y = function(p,l) return p/15+2 end,
   bonus = nil,
   element_power = function(p,l) return 150+p/5 end,
   cost = 16,
   difficulty = 450,
   ball_cb = ball_cb_elemental
}

make_ball {
   _id = "chaos_ball",
   elona_id = 433,
   related_skill = "elona.stat_magic",
   element_id = "elona.chaos",
   dice_x = function(p,l) return p/80+1+l/20 end,
   dice_y = function(p,l) return p/12+2 end,
   bonus = nil,
   element_power = function(p,l) return 150+p/5 end,
   cost = 20,
   difficulty = 1000,
   ball_cb = ball_cb_elemental
}

make_ball {
   _id = "sound_ball",
   elona_id = 434,
   related_skill = "elona.stat_magic",
   element_id = "elona.sound",
   dice_x = function(p,l) return p/80+1+l/20 end,
   dice_y = function(p,l) return p/12+2 end,
   bonus = nil,
   element_power = function(p,l) return 150+p/5 end,
   cost = 18,
   difficulty = 700,
   ball_cb = ball_cb_elemental
}

make_ball {
   _id = "magic_ball",
   elona_id = 435,
   related_skill = "elona.stat_magic",
   element_id = "elona.magic",
   dice_x = function(p,l) return p/100+1+l/25 end,
   dice_y = function(p,l) return p/18+2 end,
   bonus = nil,
   element_power = function(p,l) return 100 end,
   cost = 40,
   difficulty = 1400,
   ball_cb = ball_cb_elemental
}

local function ball_cb_healing_rain(self, x, y, tx, ty, source, target, element, params)
   if source:reaction_towards(target) >= 0 then
      local cb = Anim.heal(tx, ty, "base.heal_effect", "base.heal1", 5)
      Gui.start_draw_callback(cb)
      Gui.mes_visible("damage.is_healed", target.x, target.y, target)
      -- Magic.cast("")
   end
end

make_ball {
   _id = "healing_rain",
   elona_id = 404,
   related_skill = "elona.stat_will",
   element_id = nil,
   dice_x = function(p, l) return l/20+3 end,
   dice_y = function(p, l) return p/15+5 end,
   bonus = function(p, l) return p/10 end,
   element_power = nil,
   cost = 38,
   difficulty = 500,
   ball_cb = ball_cb_healing_rain
}

local function ball_cb_rain_of_sanity(self, x, y, tx, ty, source, target, element, params)
   if source:reaction_towards(target) >= 0 then
      local cb = Anim.heal(tx, ty, "base.heal_effect", "base.heal1", 5)
      Gui.start_draw_callback(cb)
      Gui.mes_visible("magic.rain_of_sanity", target.x, target.y, target)
      Effect.heal_insanity(target, params.power / 10)
      target:heal_effect("elona.insanity", 9999)
   end
end

make_ball {
   _id = "rain_of_sanity",
   elona_id = 404,
   type = "action",
   related_skill = "elona.stat_will",
   element_id = nil,
   dice_x = nil,
   dice_y = nil,
   bonus = nil,
   element_power = nil,
   cost = 38,
   difficulty = 500,
   ball_cb = ball_cb_rain_of_sanity
}

local function mes_if_can_see(target, mes, ...)
   if Chara.player():has_effect("elona.blindness") or not target:is_in_fov() then
      return
   end

   Gui.mes(mes, ...)
end

data:add {
   _id = "action_explosion",
   _type = "base.skill",

   type = "action",
   related_skill = "elona.stat_constitution",
   cost = 20,
   range = 2,
   difficulty = 450,
   target_type = "direction"
}
data:add {
   _id = "explosion",
   _type = "elona_sys.magic",
   elona_id = 644,

   type = "action",
   params = {
      "source"
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.action_explosion")
      return {
         x = 1 + level / 25,
         y = 15 + level / 5,
         bonus = 0
      }
   end,

   cast = function(self, params)
      local map = params.source:current_map()
      local original = params.source

      local chain_bomb = Queue:new()
      chain_bomb:push(params.source)

      local range = 2

      while chain_bomb:len() > 0 do
         local source = chain_bomb:pop()

         if Chara.is_alive(source) then
            if source == original then
               mes_if_can_see(source, "magic.explosion.begins", source)
            else
               mes_if_can_see(source, "magic.explosion.chain", source)
            end

            params.source = source -- to ensure self:dice(params) is correct
            local x = source.x
            local y = source.y

            local positions = ElonaPos.make_ball(x, y, range, map)

            local cb = Anim.ball(positions, nil, nil, x, y, map)
            Gui.start_draw_callback(cb)

            source:reset("is_about_to_explode", false)

            for _, pos in ipairs(positions) do
               local tx = pos[1]
               local ty = pos[2]

               local target = Chara.at(tx, ty)

               if target then
                  if x ~= tx or y ~= ty then
                     -- TODO riding
                     local dice = self:dice(params)
                     local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus) * 100 / (75 + Pos.dist(tx, ty, x, y) * 25)

                     local success, damage = SkillCheck.handle_control_magic(source, target, damage)
                     if not success then
                        local tense = "enemy"
                        if not target:is_ally() then
                           tense = "ally"
                        end
                        if tense == "ally" then
                           Gui.mes_visible("magic.explosion.other", tx, ty, target)
                        else
                           Gui.mes_visible("magic.explosion.ally", tx, ty, target)
                        end

                        if target:calc("is_explodable") then
                           chain_bomb:push(target)
                        else
                           target:damage_hp(damage,
                                            source,
                                            {
                                               message_tense = tense,
                                               no_attack_text = true,
                                               is_third_person = true
                           })
                        end
                     end
                  end
               end
            end
         end

         source:damage_hp(99999, "elona.explosion")
      end

      return true
   end
}

-- heal

-- tele

local function teleport_to(chara, x, y, check_cb, pos_cb, success_cb)
   local prevents_teleport = false -- TODO
   if prevents_teleport then
      if chara:is_in_fov() then
         Gui.mes("magic.teleport.prevented")
      end
      return true
   end

   if check_cb and not check_cb() then
      return true
   end

   if chara:is_in_fov() then
      Gui.play_sound("base.teleport1", chara.x, chara.y)
   end

   local map = chara:current_map()
   for attempt = 1, 200 do
      local next_x, next_y = pos_cb(x, y, attempt)

      if Map.can_access(next_x, next_y, map) then
         success_cb(chara)

         chara:remove_activity()
         chara:set_pos(next_x, next_y)
         if chara:is_player() then
            Gui.update_screen()
         end

         break
      end
   end

   return true
end

data:add {
   _id = "shadow_step",
   _type = "elona_sys.magic",
   elona_id = 619,

   type = "skill",
   params = {
      "source",
      "target",
   },

   skill = "elona.stat_will",
   cost = 10,
   range = 6005,
   difficulty = 0,

   cast = function(self, params)
      local source = params.source
      local target = params.target

      local pos = function(x, y, attempt)
         return x + Rand.rnd(attempt / 8 + 2) - Rand.rnd(attempt / 8 + 2),
         y + Rand.rnd(attempt / 8 + 2) - Rand.rnd(attempt / 8 + 2)
      end
      local success = function(chara)
         if chara:is_in_fov() then
            Gui.mes("magic.teleport.shadow_step", chara, target)
         end
      end

      return teleport_to(source, target.x, target.y, nil, pos, success)
   end
}

-- hand

-- summon

local function make_breath(element_id, elona_id, dice_x, dice_y, bonus, cost)
   local id
   if element_id then
      id = element_id .. "_breath"
      element_id = "elona." .. element_id
   else
      id = "breath"
   end

   data:add {
      _id = "breath_" .. id,
      _type = "base.skill",

      type = "action",
      skill = "elona.stat_constitution",
      cost = cost,
      range = RANGE_BREATH,
      difficulty = 0,
      target_type = "both"
   }

   data:add {
      _id = id,
      _type = "elona_sys.magic",
      elona_id = elona_id,

      type = "action",
      params = {
         "source"
      },

      dice = function(self, params)
         local level = params.source:skill_level("elona.magic_" .. id)
         return {
            x = 1 + level / dice_x,
            y = dice_y,
            bonus = level / bonus
         }
      end,

      cast = function(self, params)
         local map = params.source:current_map()
         local sx = params.source.x
         local sy = params.source.y
         local tx = sx
         local ty = sy
         if not map:has_los(sx, sy, params.x, params.y) then
            return false
         end

         local element, color, sound
         if element_id then
            element = data["base.element"]:ensure(element_id)
            color = element.color
            sound = element.sound
         end

         if map:is_in_fov(sx, sy) then
            local breath_name
            if element_id then
               breath_name = I18N.get("magic.breath.named", "element." .. element_id .. ".name")
            else
               breath_name = I18N.get("magic.breath.named", "magic.breath.no_element")
            end
            Gui.mes_visible("magic.breath.bellows", sx, sy, params.source, breath_name)

            local positions = ElonaPos.make_breath(sx, sy, params.x, params.y, params.range, map)

            local cb = Anim.breath(positions, color, sound, sx, sy, params.x, params.y, map)
            Gui.start_draw_callback(cb)

            for _, pos in ipairs(positions) do
               local dx = pos[1]
               local dy = pos[2]
               tx = tx + dx
               ty = ty + dy

               if map:has_los(sx, sy, tx, ty) then
                  if not (sx == tx and sx == ty) then
                     -- TODO riding
                     if element and element.on_damage_tile then
                        element:on_damage_tile(tx, ty)
                     end
                     local chara = Chara.at(tx, ty, map)
                     if chara then
                        local dice = self:dice(params)
                        local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)

                        local tense = "enemy"
                        if not chara:is_ally() then
                           tense = "ally"
                        end
                        if tense == "ally" then
                           Gui.mes_visible("magic.breath.ally", tx, ty, chara)
                        else
                           Gui.mes_visible("magic.breath.other", tx, ty, chara)
                        end
                        chara:damage_hp(damage,
                                        params.source,
                                        {
                                           element = element,
                                           element_power = params.element_power,
                                           message_tense = tense,
                                           no_attack_text = true,
                                           is_third_person = true
                        })
                     end
                  end
               end
            end
         end
         return true
      end
   }
end

make_breath("fire",      602, 15, 7, 8,  12)
make_breath("cold",      603, 15, 7, 8,  10)
make_breath("lightning", 604, 15, 7, 8,  10)
make_breath("chaos",     605, 15, 7, 8,  10)
make_breath("poison",    606, 15, 7, 8,  10)
make_breath("nether",    607, 15, 7, 8,  10)
make_breath("sound",     608, 15, 7, 8,  10)
make_breath("darkness",  609, 15, 7, 8,  10)
make_breath("mind",      610, 15, 7, 8,  10)
make_breath("nerve",     611, 15, 7, 8,  10)
make_breath(nil,         612, 20, 6, 15, 10)

-- fov

-- attack
