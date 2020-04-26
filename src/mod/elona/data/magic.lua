local Anim = require("mod.elona_sys.api.Anim")
local Chara = require("api.Chara")
local Effect = require("mod.elona.api.Effect")
local ElonaPos = require("mod.elona.api.ElonaPos")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")

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

local function sp_check(chara, skill)
   local sp_cost = skill.cost / 2 + 1
   if source.stamina < 50 and source.stamina < Rand.rnd(75) then
      Gui.mes("magic.common.too_exhausted")
      source:damage_sp(sp_cost)
      return false
   end
   source:damage_stamina(Rand.rnd(sp_cost) + sp_cost)
   return true
end

data:add {
   _id = "love_potion",
   _type = "elona_sys.magic",
   elona_id = 1135,

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

   params = {
      "source",
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

data:add {
   _id = "return",
   _type = "elona_sys.magic",
   elona_id = 428,

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

local function make_breath(element, elona_id, range, dice_x, dice_y, bonus)
   local id
   if element then
      id = element .. "_breath"
      element = "elona." .. element
   else
      id = "breath"
   end
   local full_id = "elona." .. id
   data:add {
      _id = id,
      _type = "elona_sys.magic",
      elona_id = elona_id,

      params = {
         "source"
      },

      skill = "elona.stat_perception",
      cost = 20,
      range = 10000,
      difficulty = 550,

      dice = function(self, params)
         local level = params.source:magic_level(full_id)
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
         if not map:has_los(sx, sy, params.x, params.y) then
            return false
         end
         if map:is_in_fov(sx, sy) then
            local breath_name
            if element then
               breath_name = I18N.get("magic.breath.named", "element." .. element .. ".name")
            else
               breath_name = I18N.get("magic.breath.named", "magic.breath.no_element")
            end
            Gui.mes_visible("magic.breath.bellows", sx, sy, params.source, breath_name)

            local positions = ElonaPos.make_breath(sx, sy, params.x, params.y, range, map)

            local cb = Anim.breath(positions, element, sx, sy, params.x, params.y, map)
            Gui.start_draw_callback(cb)

            local element_data
            if element then
               element_data = data["base.element"]:ensure(element)
            end

            for _, pos in ipairs(positions) do
               local tx = pos[1]
               local ty = pos[2]

               if map:has_los(sx, sy, tx, ty) then
                  if not (sx == tx and sx == ty) then
                     -- TODO riding
                     if element_data and element_data.on_damage_tile then
                        element_data:on_damage_tile(tx, ty)
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
                                           no_attack_text = true
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
