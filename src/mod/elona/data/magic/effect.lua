local Anim = require("mod.elona_sys.api.Anim")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Map = require("api.Map")
local TreasureMapWindow = require("mod.elona.api.gui.TreasureMapWindow")
local Event = require("api.Event")
local Input = require("api.Input")
local Save = require("api.Save")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.tools.api.Itemgen")
local I18N = require("api.I18N")
local God = require("mod.elona.api.God")
local AliasPrompt = require("api.gui.AliasPrompt")
local Log = require("api.Log")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Text = require("mod.elona.api.Text")
local Mef = require("api.Mef")
local Const = require("api.Const")

local function per_curse_state(curse_state, doomed, cursed, none, blessed)
   assert(type(curse_state) == "string")
   if curse_state == "doomed" then
      return doomed
   elseif curse_state == "cursed" then
      return cursed
   elseif curse_state == "blessed" then
      return blessed
   end

   return none
end

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
               Gui.mes_c("magic.milk.cursed.other", "SkyBlue")
            end
         elseif target:is_player() then
            Gui.mes("magic.milk.self")
         else
            Gui.mes_c("magic.milk.other", "SkyBlue")
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
   _id = "effect_ale",
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
            Gui.mes_c("magic.alcohol.cursed", "SkyBlue")
         else
            Gui.mes_c("magic.alcohol.normal", "SkyBlue")
         end
      end

      target:apply_effect("elona.drunk", params.power)
      Effect.apply_food_curse_state(target, params.curse_state)

      return true
   end
}

data:add {
   _id = "effect_deed",
   _type = "elona_sys.magic",
   elona_id = 1115,

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
   _id = "effect_sulfuric",
   _type = "elona_sys.magic",
   elona_id = 1116,

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
   _id = "effect_water",
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
   _id = "effect_soda",
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
   _id = "effect_cupsule",
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
   _id = "effect_dirty_water",
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
   _id = "effect_love_potion",
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
         Gui.mes_c("misc.love_miracle.uh", "SkyBlue")
         if Rand.one_in(2) then
            local item = Item.create("elona.egg", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params.chara_id = chara._id
               local weight = chara:calc("weight")
               item.weight = weight * 10 + 250
               item.value = math.clamp(math.floor(weight * weight / 10000), 200, 40000)
            end
         else
            local item = Item.create("elona.bottle_of_milk", chara.x, chara.y, {}, chara:current_map())
            if item then
               item.params.chara_id = chara._id
            end
         end

         Gui.play_sound("base.atk_elec")
         local anim = Anim.load("elona.anim_elec", chara.x, chara.y)
         Gui.start_draw_callback(anim)
      end

      params.target:set_emotion_icon("elona.heart", 3)

      if params.triggered_by == "potion_spilt" or params.triggered_by == "potion_thrown" then
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

local function find_treasure_location(map)
   local cardinal = {
      {  1,  0 },
      { -1,  0 },
      {  0,  1 },
      {  0, -1 },
   }

   local point = function()
      local tx = 4 + Rand.rnd(map:width() - 8)
      local ty = 3 + Rand.rnd(map:width() - 6)
      return tx, ty
   end

   local filter = function(tx, ty)
      -- TODO
      if map.id == "elona.north_tyris" then
         if tx >= 50 and ty >= 39 and tx <= 73 and ty <= 54 then
            return false
         end
      end

      for _, pos in ipairs(cardinal) do
         local tile = map:tile(tx + pos[1], ty + pos[2])
         if tile.field_type == "elona.sea" or tile.is_solid then
            return false
         end
      end

      return true
   end

   return fun.tabulate(point):take(1000):filter(filter):nth(1)
end

data:add {
   _id = "effect_treasure_map",
   _type = "elona_sys.magic",
   elona_id = 1136,

   type = "effect",
   params = {
      "source",
      "item",
   },

   cast = function(self, params)
      local source = params.source
      local item = params.item
      local map = params.source:current_map()
      if not Map.is_world_map(map) then
         Gui.mes("magic.map.need_global_map")
         return true
      end

      if Effect.is_cursed(params.curse_state) and Rand.one_in(5) then
         Gui.mes("magic.map.cursed")
         item.amount = item.amount - 1
         item:refresh_cell_on_map()
         return true
      end

      local item_map = item:containing_map()
      if item.params.treasure_map_x == nil then
         item:separate()

         local tx, ty = find_treasure_location(item_map)
         if tx and ty then
            item.params.treasure_map_x = tx
            item.params.treasure_map_y = ty
         end
      end

      if not item.params.treasure_map then
         Log.warn("No treasure map location found.")
         return true
      end

      Gui.mes("magic.map.apply")

      TreasureMapWindow:new(item_map,
                            item.params.treasure_map_x,
                            item.params.treasure_map_y)
         :query()

      return true
   end
}

local function proc_treasure_map(map, params)
   -- >>>>>>>> shade2/proc.hsp:1012 	if mType=mTypeWorld{ ..
   local chara = params.chara
   local _type = params.type

   if not Map.is_world_map(map) then
      return
   end

   local filter = function(item)
      return item._id == "elona.treasure_map"
         and type(item.params.treasure_map) == "table"
         and item.params.treasure_map.x == chara.x
         and item.params.treasure_map.y == chara.y
   end
   local treasure_map = chara:iter_inventory():filter(filter):nth(1)

   if treasure_map then
      Gui.play_sound("base.chest1")
      Gui.mes_c("activity.dig_spot.something_is_there", "Yellow")
      Input.query_more()
      Gui.play_sound("base.ding2")

      Item.create("elona.small_medal", chara.x, chara.y, { amount = 2 + Rand.rnd(2) }, map)
      Item.create("elona.platinum_coin", chara.x, chara.y, { amount = 1 + Rand.rnd(3) }, map)
      Item.create("elona.gold_piece", chara.x, chara.y, { amount = Rand.rnd(10000) + 20001 }, map)
      for i = 1, 4 do
         local level = Calc.calc_object_level(chara:calc("level") + 10, map)
         local quality = Calc.calc_object_quality(Enum.Quality.Good)
         if i == 1 then
            quality = Enum.Quality.God
         end
         local category = Rand.choice(Filters.fsetchest)
         Itemgen.create(chara.x, chara.y, { level = level, quality = quality, categories = {category} }, map)
      end

      Gui.mes("common.something_is_put_on_the_ground")
      treasure_map.amount = treasure_map.amount - 1
      Save.save_game() -- TODO autosave
   end
   -- <<<<<<<< shade2/proc.hsp:1033 		} ..
end

Event.register("elona.on_search_finish", "Proc treasure map", proc_treasure_map)

data:add {
   _id = "effect_salt",
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
         Gui.mes_c("magic.salt.apply", "SkyBlue")
      end

      return true
   end
}

data:add {
   _id = "effect_elixir",
   _type = "elona_sys.magic",
   elona_id = 1120,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      Gui.mes_c("magic.prayer", "Yellow", target)

      target:set_effect_turns("elona.poison", 0)
      target:set_effect_turns("elona.sleep", 0)
      target:set_effect_turns("elona.confusion", 0)
      target:set_effect_turns("elona.blindness", 0)
      target:set_effect_turns("elona.paralysis", 0)
      target:set_effect_turns("elona.choking", 0)
      target:set_effect_turns("elona.dimming", 0)
      target:set_effect_turns("elona.drunk", 0)
      target:set_effect_turns("elona.bleeding", 0)
      target:set_effect_turns("elona.sleep", 0)
      target.hp = target:calc("max_hp")
      target.mp = target:calc("max_mp")
      target.stamina = target:calc("max_stamina")

      local cb = Anim.heal(target.x, target.y, "base.heal_effect", "base.heal1")
      Gui.start_draw_callback(cb)

      return true
   end
}

data:add {
   _id = "effect_gain_knowledge",
   _type = "elona_sys.magic",
   elona_id = 1104,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local times = 1
      if params.curse_state == "blessed" then
         times = times + 1
      end

      local candidates = data["base.skill"]:iter():filter(function(skill) return skill.type == "spell" end):to_list()
      local did_something = true

      for i = 1, times do
         Gui.update_screen()

         for _ = 1, 2000 do
            local consider = true

            local spell = Rand.choice(candidates)

            -- HACK
            if spell._id == "elona.wish" and not Rand.one_in(10) then
               consider = false
            end

            if consider then
               local spell_name = "ability." .. spell._id .. ".name"

               if not Effect.is_cursed(params.curse_state) then
                  if spell.related_skill ~= nil then
                     local mes
                     if i == 1 then
                        mes = "magic.gain_knowledge.suddenly"
                     else
                        mes = "magic.gain_knowledge.furthermore"
                     end
                     Skill.gain_skill(target, spell._id, 1, 100 * 2)
                     Gui.mes_c(I18N.get(mes) .. I18N.get("magic.gain_knowledge.gain", spell_name), "Green")
                     did_something = true
                     break
                  end
               else
                  if target.spell_stocks[spell._id] > 0 then
                     target.spell_stocks[spell._id] = 0
                     Gui.mes("magic.common.it_is_cursed")
                     Gui.mes_c("magic.gain_knowledge.lose", "Red", spell_name, target)
                     did_something = true
                     break
                  end
               end
            end
         end
      end

      if not did_something then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      Save.autosave()

      return true
   end
}

data:add {
   _id = "effect_gain_skill",
   _type = "elona_sys.magic",
   elona_id = 1105,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      -- HACK
      local candidates = data["base.skill"]:iter():filter(function(skill) return skill.type == nil or skill.type == "skill" end):to_list()

      -- Greater chance to learn a new skill instead of improving an existing
      -- one based on the curse level.
      local existing_threshold = per_curse_state(params.curse_state, 0, 0, 100, 2000)

      local cnt = 0

      while true do
         local skill = Rand.choice(candidates)

         local skill_name = "ability." .. skill._id .. ".name"

         if not Effect.is_cursed(params.curse_state) then
            if skill.related_skill ~= nil then
               local consider = true
               if cnt < existing_threshold and target:base_skill_level(skill._id) > 0 then
                  consider = false
               end
               if consider then
                  Skill.gain_skill(target, skill._id, 1)
                  Gui.mes_c("magic.gain_skill", "Green", target, skill_name)
                  Gui.play_sound("base.ding2")
                  break
               end
            end
         else
            if target:base_skill_level(skill._id) > 0 then
               if target:is_in_fov() then
                  Gui.play_sound("base.curse1", target.x, target.y)
                  Gui.mes("magic.common.it_is_cursed")
               end
               Skill.gain_skill_exp(target, skill._id, -1000)
               break
            end
         end
         cnt = cnt + 1
      end

      target:refresh()
      Save.autosave()

      return true
   end
}

data:add {
   _id = "effect_descent",
   _type = "elona_sys.magic",
   elona_id = 1143,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if Effect.is_cursed(params.curse_state) or params.curse_state == "none" then
         if target.level <= 1 then
            Gui.mes("common.nothing_happens")
            return true, { obvious = false }
         end
         target.level = target.level - 1
         target.experience = 0
         target.required_experience = Skill.calc_required_experience(target)
         Gui.mes_c("magic.descent", "Purple", target)
      else
         target.experience = target.required_experience
         Skill.gain_level(target, true)
         if target:is_in_fov() then
            Gui.play_sound("base.ding1", target.x, target.y)
         end
      end
      if Effect.is_cursed(params.curse_state) then
         Gui.mes("magic.common.it_is_cursed")
         for _, stat in Skill.iter_stats() do
            if Rand.one_in(3) then
               if stat._id ~= "elona.stat_speed"
                  and stat._id ~= "elona.stat_luck"
                  and stat._id ~= "elona.stat_mana"
                  and stat._id ~= "elona.stat_life"
               then
                  if target:base_skill_level(stat._id) > 0 then
                     Skill.gain_skill_exp(target, stat._id, -1000)
                  end
               end
            end
         end
         local cb = Anim.load("elona.anim_smoke", target.x, target.y)
         Gui.start_draw_callback(cb)
      end

      target:refresh()

      return true
   end
}

data:add {
   _id = "effect_gain_faith",
   _type = "elona_sys.magic",
   elona_id = 1107,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local god_id = target:calc("god")
      if god_id == nil then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      if Effect.is_cursed(params.curse_state) then
         Gui.mes("magic.faith.doubt")
         Gui.play_sound("base.curse3", target.x, target.y)
         local cb = Anim.load("elona.anim_curse", target.x, target.y)
         Gui.start_draw_callback(cb)
         Skill.gain_skill_exp(target, "elona.faith", -1000)
         return true
      end

      local god_name = "god." .. god_id .. ".name"
      Gui.mes_c("magic.faith.apply", "Green", god_name)

      local cb = Anim.miracle({{ x = target.x, y = target.y }})
      Gui.start_draw_callback(cb)
      Gui.play_sound("base.pray2")

      target.prayer_charge = target.prayer_charge + 500
      God.modify_piety(target, 75)
      local exp = 1000
      if params.curse_state == "blessed" then
         exp = exp + 750
      end
      Skill.gain_skill_exp(target, "elona.faith", exp, 6, 1000)

      target:refresh()

      return true
   end
}

data:add {
   _id = "effect_gain_skill_potential",
   _type = "elona_sys.magic",
   elona_id = 1119,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      local times = 1
      if params.curse_state == "blessed" then
         times = times + 1
      end

      local candidates = data["base.skill"]:iter()
         :filter(function(skill) return skill.type == nil or skill.type == "skill" end)
         :to_list()

      for i = 1, times do
         while true do
            local skill = Rand.choice(candidates)
            if skill.related_skill ~= nil then
               if target:base_skill_level(skill._id) > 0 then
                  local amount = params.power * per_curse_state(params.curse_state, -4,-2,5,5) / 100
                  Skill.modify_potential(target, skill._id, amount)
                  local mes
                  if i == 1 then
                     mes = "magic.gain_skill_potential.the"
                  else
                     mes = "magic.gain_skill_potential.furthermore_the"
                  end

                  local skill_name = "ability." .. skill._id .. ".name"

                  if not Effect.is_cursed(params.curse_state) then
                     if target:is_in_fov() then
                        Gui.play_sound("base.ding2", target.x, target.y)
                        Gui.mes_c(I18N.get(mes) .. I18N.get("magic.gain_skill_potential.increases", target, skill_name), "Green")
                     end
                  else
                     if target:is_in_fov() then
                        Gui.play_sound("base.curse3", target.x, target.y)
                        Gui.mes_c("magic.gain_skill_potential.decreases", "Red", target, skill_name)
                     end
                  end

                  break
               end
            end
         end
      end

      target:refresh()
      Save.autosave()

      return true
   end
}

data:add {
   _id = "effect_punish_decrement_stats",
   _type = "elona_sys.magic",
   elona_id = 1106,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      for _, stat in Skill.iter_stats() do
         local amount = per_curse_state(params.curse_state, -2000, -2000, -1000, -250)
         Skill.gain_skill_exp(target, stat._id, amount)
      end

      local cb = Anim.load("elona.anim_curse", target.x, target.y)
      Gui.start_draw_callback(cb)

      target:refresh()

      return true
   end
}

data:add {
   _id = "effect_gain_potential",
   _type = "elona_sys.magic",
   elona_id = 1113,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if params.curse_state == "blessed" then
         for _, stat in Skill.iter_base_stats() do
            local amount = Rand.rnd(target:skill_potential(stat._id) / 20 + 3) + 1
            Skill.modify_potential(target, stat._id, amount)
         end
         Gui.mes("magic.gain_potential.blessed", target)
         local cb = Anim.miracle({{ x = target.x, y = target.y }})
         Gui.start_draw_callback(cb)
         Gui.play_sound("base.ding3", target.x, target.y)
      else
         local stat = Rand.choice(Skill.iter_base_stats())
         local stat_name = "ability." .. stat._id .. ".name"
         if params.curse_state == "none" then
            Gui.mes("magic.gain_potential.increases", target, stat_name)
            local amount = Rand.rnd(target:skill_potential(stat._id) / 10 + 10) + 1
            Skill.modify_potential(target, stat._id, -amount)
            Gui.play_sound("base.ding2", target.x, target.y)
         else
            Gui.mes("magic.gain_potential.decreases", target, stat_name)
            local amount = Rand.rnd(target:skill_potential(stat._id) / 10 + 10) + 1
            Skill.modify_potential(target, stat._id, -amount)
            Gui.play_sound("base.curse3", target.x, target.y)
         end
      end

      Save.autosave()

      return true
   end
}

data:add {
   _id = "effect_troll_blood",
   _type = "elona_sys.magic",
   elona_id = 1139,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      Gui.mes("magic.troll_blood.apply", target)
      local amount = per_curse_state(params.curse_state, -4000, -1000, 8000, 12000)
      Skill.gain_skill_exp(target, "elona.stat_speed", amount)
      if params.curse_state == "blessed" then
         Skill.modify_potential(target, "elona.stat_speed", 15)
         Gui.mes_c("magic.troll_blood.blessed", "Green")
      end

      target:refresh()

      return true
   end
}

data:add {
   _id = "effect_escape",
   _type = "elona_sys.magic",
   elona_id = 1141,

   type = "effect",
   params = {
      "target"
   },

   cast = function(self, params)
      local target = params.target
      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local s = save.elona
      if s.turns_until_cast_return ~= 0 then
         Gui.mes("magic.escape.cancel")
         s.turns_until_cast_return = 0
      else
         -- TODO quest
         -- TODO dungeon boss

         if Effect.is_cursed(params.curse_state) and Rand.one_in(3) then
            Gui.mes("TODO jail") -- TODO
         end

         Gui.mes("misc.return.air_becomes_charged")

         -- TODO map
         Gui.mes("TODO")

         -- if map_uid then
         --    s.return_destination_map_uid = map_uid
         --    s.turns_until_cast_return = 5 + Rand.rnd(10)
         -- end
      end

      return true
   end
}

data:add {
   _id = "effect_poison",
   _type = "elona_sys.magic",
   elona_id = 1108,

   type = "effect",
   params = {
      "target"
   },

   cast = function(self, params)
      local target = params.target

      Gui.mes_visible("magic.poison_attack", target)
      if target:calc("is_pregnant") then
         target:reset("is_pregnant", false)
         Gui.mes_visible("common.melts_alien_children", target)
      end

      target:apply_effect("elona.poison", params.power)

      return true
   end
}

data:add {
   _id = "effect_confuse",
   _type = "elona_sys.magic",
   elona_id = 1109,

   type = "effect",
   params = {
      "target"
   },

   cast = function(self, params)
      local target = params.target

      Gui.mes_visible("magic.confusion", target)

      target:apply_effect("elona.confusion", params.power)

      return true
   end
}

data:add {
   _id = "effect_paralyze",
   _type = "elona_sys.magic",
   elona_id = 1110,

   type = "effect",
   params = {
      "target"
   },

   cast = function(self, params)
      local target = params.target

      Gui.mes_visible("magic.paralysis", target)

      target:apply_effect("elona.paralysis", params.power)

      return true
   end
}

data:add {
   _id = "effect_blind",
   _type = "elona_sys.magic",
   elona_id = 1111,

   type = "effect",
   params = {
      "target"
   },

   cast = function(self, params)
      local target = params.target

      Gui.mes_visible("magic.ink_attack", target)

      target:apply_effect("elona.blindness", params.power)

      return true
   end
}

data:add {
   _id = "effect_sleep",
   _type = "elona_sys.magic",
   elona_id = 1112,

   type = "effect",
   params = {
      "target"
   },

   cast = function(self, params)
      local target = params.target

      Gui.mes_visible("magic.sleep", target)

      target:apply_effect("elona.sleep", params.power)

      return true
   end
}

data:add {
   _id = "effect_weaken_resistance",
   _type = "elona_sys.magic",
   elona_id = 1118,

   type = "effect",
   params = {
      "target"
   },

   cast = function(self, params)
      local target = params.target

      local total_weakened = 0

      for _, element in Skill.iter_resistances() do
         if target:base_resist_level(element._id) >= 150 then
            total_weakened = total_weakened + 1
            Skill.modify_resist_level(target, element._id, -50)
            if total_weakened >= params.power / 100 then
               break
            end
         end
      end

      if total_weakened == 0 then
         Gui.mes("magic.weaken_resistance.nothing_happens")
         return true, { obvious = false }
      end

      Gui.play_sound("base.curse1", target.x, target.y)

      target:refresh()

      return true
   end
}

data:add {
   _id = "effect_name",
   _type = "elona_sys.magic",
   elona_id = 1145,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target

      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(target, "elona.inv_equipment")

      if not result or canceled then
         return true, { obvious = false }
      end

      local item = result.result
      item:separate()

      if item.quality < Enum.Quality.Great or item.quality == Enum.Quality.Unique then
         Gui.mes("common.it_is_impossible")
         return true, { obvious = false }
      end

      Gui.mes("magic.name.prompt")

      result, canceled = AliasPrompt:new("weapon"):query()

      if not result or canceled then
         return true, { obvious = false }
      end

      local seed = result.seed
      item.title_seed = seed

      Gui.mes("magic.name.apply", result.alias)

      return true
   end
}

-- >>>>>>>> shade2/proc.hsp:2993 	case effGarokHammer ..
data:add {
   _id = "effect_garoks_hammer",
   _type = "elona_sys.magic",
   elona_id = 49,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      local hammer = params.item

      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(target, "elona.inv_garoks_hammer")

      if not result or canceled then
         return true, { obvious = false }
      end

      local target_item = result.result
      target_item:separate()

      if target_item.quality >= Enum.Quality.Great or target_item:calc("is_alive") then
         return true
      end

      local seed = hammer.params.garoks_hammer_seed
      assert(seed)

      -- Prevent save scumming by using a predefined seed when regenerating the
      -- item.
      Rand.set_seed(seed)

      local material = hammer:calc("material")

      local cb = Anim.load("elona.anim_smoke", target.x, target.y)
      Gui.start_draw_callback(cb)

      ItemMaterial.change_item_material(target_item, material)

      Rand.set_seed(seed)

      target_item:reset("quality", Enum.Quality.Great)
      target_item.subname = Text.random_subname_seed()

      local times = Rand.rnd(Rand.rnd(Rand.rnd(10) + 1) + 3) + 3
      -- TODO random enchantment
      local enchant_level = Rand.rnd(math.clamp(Rand.rnd(30/10+3), 0, Const.MAX_ENCHANTMENT_LEVEL) + 1)

      for _ = 1, times do
         Rand.set_seed(seed)
         -- TODO random enchantment
      end

      Rand.set_seed()

      Gui.mes("magic.garoks_hammer.apply", target_item)

      target:refresh()

      hammer.amount = hammer.amount - 1
      hammer:refresh_cell_on_map()

      return true
   end
}
-- <<<<<<<< shade2/proc.hsp:3029 	swbreak ...
--
-- >>>>>>>> shade2/proc.hsp:3031 	case effMaterialKit ..
local function do_change_material(target, material_kit, target_item, power)
   if target_item:calc("quality") == Enum.Quality.Unique then
      if power < 350  then
         Gui.mes("magic.change_material.more_power_needed")
         return true
      end

      local cb = Anim.load("elona.anim_smoke", target.x, target.y)
      Gui.start_draw_callback(cb)

      Gui.mes("magic.change_material.artifact_reconstructed", target, target_item)

      material_kit.amount = material_kit.amount - 1
      target_item:refresh_cell_on_map()
      local new_item = Item.create(target_item._id, nil, nil, { ownerless = true })
      target_item:replace_with(new_item)
   else
      local cb = Anim.load("elona.anim_smoke", target.x, target.y)
      Gui.start_draw_callback(cb)
      local fixed_material = nil
      if power <= 50 and Rand.one_in(3) then
         fixed_material = "elona.fresh"
      end
-- <<<<<<<< shade2/proc.hsp:3051 			if efP<=50:if rnd(3)=0 : fixMaterial=mtFresh ..
      -- >>>>>>>> shade2/item_data.hsp:1144 	if cm : mtLv = cLevel(rc)/15 + 1 :else: mtLv=rnd( ..
      local level = power / 10
      local quality = power / 100

      local mat_level = math.floor(Rand.rnd(level + 1) / 10 + 1)

      if material_kit._id == "elona.material_kit" then
         mat_level = Rand.rnd(mat_level + 1)
         if not fixed_material and Rand.one_in(3) then
            fixed_material = "elona.soft"
         else
            fixed_material = "elona.metal"
         end
      end
      -- <<<<<<<< shade2/item_data.hsp:1146  ...
-- >>>>>>>> shade2/proc.hsp:3052 			s=itemName(ci,1,1) ..
      local old_name = target_item:build_name()

      local material_id = ItemMaterial.choose_random_material_2(target_item, mat_level, quality, fixed_material, nil)
      ItemMaterial.change_item_material(target_item, material_id)

      Gui.mes("magic.change_material.apply", target, old_name, target_item)
   end

   target:refresh()

   return true
end

data:add {
   _id = "effect_material_kit",
   _type = "elona_sys.magic",
   elona_id = 21,

   type = "effect",
   params = {
      "target",
      "item"
   },

   cast = function(self, params)
      local target = params.target
      local material_kit = params.item

      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(target, "elona.inv_equipment")

      if not result or canceled then
         return true, { obvious = false }
      end

      local target_item = result.result
      target_item:separate()

      return do_change_material(target, material_kit, target_item, params.power)
   end
}

data:add {
   _id = "effect_change_material",
   _type = "elona_sys.magic",
   elona_id = 1127,

   type = "effect",
   params = {
      "target",
      "item"
   },

   cast = function(self, params)
      local target = params.target
      local material_kit = params.item

      if not target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(target, "elona.inv_equipment")

      if not result or canceled then
         return true, { obvious = false }
      end

      local target_item = result.result
      target_item:separate()

      if target_item.quality == Enum.Quality.God or target_item:calc("is_alive") then
         Gui.mes("common.nothing_happens")
         return true, {obvious = false}
      end

      return do_change_material(target, material_kit, target_item, params.power)
   end
}
-- <<<<<<<< shade2/proc.hsp:3068 	swbreak ..

-- >>>>>>>> shade2/proc.hsp:2340 	case efMakeMaterial ..
data:add {
   _id = "effect_create_material",
   _type = "elona_sys.magic",
   elona_id = 1117,

   type = "effect",
   params = {
      "target",
   },

   cast = function(self, params)
      local target = params.target
      local item = params.item

      if not target:is_allied() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local mes
      if params.curse_state == "none" or params.curse_state == "blessed" then
         mes = "magic.create_material.junks"
      else
         mes = "magic.create_material.materials"
      end

      Gui.play_sound("base.ding2")
      Gui.mes("magic.create_material.apply", mes)

      Save.autosave()

      local times = Rand.rnd(3) + 3
      if params.curse_state == "blessed" then
         times = times + 6
      end

      for _ = 1, times do
         Gui.mes_continue_sentence()

         -- TODO material spot
      end

      return true
   end
}
-- <<<<<<<< shade2/proc.hsp:2350 	swbreak ..

-- >>>>>>>> shade2/proc.hsp:3070:DONE 	case efHeirDeed ..
data:add {
   _id = "effect_deed_of_inheritance",
   _type = "elona_sys.magic",
   elona_id = 1128,

   type = "effect",
   params = {
      "source",
   },

   cast = function(self, params)
      local source = params.source

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      Gui.play_sound("base.ding2")
      local amount = math.floor(Rand.rnd(params.power + 1) / 100 + 1)
      local s = save.elona
      s.inheritable_item_count = s.inheritable_item_count + amount
      Gui.mes_c("magic.deed_of_inheritance.claim", "Yellow", amount)
      Gui.mes("magic.deed_of_inheritance.can_now_inherit", s.inheritable_item_count)

      return true
   end
}
-- <<<<<<<< shade2/proc.hsp:3076 	swbreak ..

local function do_enchant(inventory_proto, source, power)
   -- >>>>>>>> shade2/proc.hsp:3083 	if efId=efEnchantWeapon:invCtrl=23,1:else:invCtrl ..
   local result, canceled = Input.query_item(source, inventory_proto)
   if not result or canceled then
      return true, { obvious = false }
   end

   local item = result.result

   item:separate()

   if item.bonus < power / 100 then
      Gui.play_sound("base.ding2")
      Gui.mes("magic.enchant.apply", item)
      item.bonus = item.bonus + 1
   else
      Gui.mes("magic.common.resists", item)
   end

   source:refresh()

   return true
   -- <<<<<<<< shade2/proc.hsp:3100 	swbreak ..
end

data:add {
   _id = "effect_enchant_weapon",
   _type = "elona_sys.magic",
   elona_id = 1124,

   type = "effect",
   params = {
      "source",
   },

   cast = function(self, params)
      local source = params.source

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      return do_enchant("elona.inv_equipment_weapon", source, params.power)
   end
}

data:add {
   _id = "effect_enchant_armor",
   _type = "elona_sys.magic",
   elona_id = 1125,

   type = "effect",
   params = {
      "source",
   },

   cast = function(self, params)
      local source = params.source

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      return do_enchant("elona.inv_equipment_armor", source, params.power)
   end
}

data:add {
   _id = "effect_flight",
   _type = "elona_sys.magic",
   elona_id = 1140,

   type = "effect",
   params = {
      "source",
   },

   cast = function(self, params)
      -- >>>>>>>> shade2/proc.hsp:3187 	if cc!pc:txtNothingHappen:obvious=false:swbreak ..
      local source = params.source

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(source, "elona.inv_equipment_flight")
      if not result or canceled then
         return true, { obvious = false }
      end

      Save.autosave()

      local item = result.result

      item:separate()

      local cb = Anim.load("elona.anim_smoke", source.x, source.y)
      Gui.start_draw_callback(cb)

      if params.curse_state == Enum.CurseState.Normal or params.curse_state == Enum.CurseState.Blessed then
         if item.weight > 0 then
            item.weight = math.clamp(math.floor(item.weight * (100 - params.power/10) / 100), 1, item.weight)
            if item.pv > 0 then
               item.pv = math.floor(item.pv - item.pv / 10 + 1)
               if params.curse_state ~= Enum.CurseState.Blessed then
                  item.pv = item.pv - 1
               end
            end
            if item.damage_bonus > 0 then
               item.damage_bonus = math.floor(item.damage_bonus - item.damage_bonus / 10 + 1)
               if params.curse_state ~= Enum.CurseState.Blessed then
                  item.damage_bonus = item.damage_bonus - 1
               end
            end
         end
         Gui.mes("magic.flying.apply", item)
      else
         item.weight = math.floor(item.weight * 150 / 100 + 1000)
         if item.pv > 0 then
            item.pv = item.pv + math.clamp(item.pv / 10, 1, 5)
         end
         if item.damage_bonus > 0 then
            item.damage_bonus = item.damage_bonus + math.clamp(item.damage_bonus / 10, 1, 5)
         end
         Gui.mes("magic.flying.cursed", item)
      end

      source:refresh_weight()
      source:refresh()

      return true
      -- <<<<<<<< shade2/proc.hsp:3211 	swbreak ..
   end
}

data:add {
   _id = "effect_alchemy",
   _type = "elona_sys.magic",
   elona_id = 1132,

   type = "effect",
   params = {
      "source",
   },

   cast = function(self, params)
      -- >>>>>>>> shade2/proc.hsp:3213 	case efChangeItem ..
      local source = params.source
      local map = params.source:current_map()

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(source, "elona.inv_equipment_alchemy")
      if not result or canceled then
         return true, { obvious = false }
      end

      local item = result.result

      if item.quality > Enum.Quality.Great or item:calc("is_precious") then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      Save.autosave()

      item:separate()

      local cb = Anim.load("elona.anim_smoke", source.x, source.y)
      Gui.start_draw_callback(cb)

      local value_prev = Calc.calc_item_value(item, "buy")

      local major_categories = {}
      for _, cat in ipairs(item.categories) do
         if data["base.item_type"]:ensure(cat).is_major then
            table.insert(major_categories, cat)
         end
      end

      item:remove()

      local new_item
      local i = 0
      while true do
         local level = Calc.calc_object_level(params.power / 10 + 5, map)
         local quality = Calc.calc_object_quality(Enum.Quality.Good)
         local gen_params = { level = level, quality = quality, ownerless = true }
         if i < 10 then
            gen_params.categories = major_categories
         end
         new_item = Itemgen.create(nil, nil, gen_params)
         if new_item and new_item.value <= (value_prev * 3 / 2) + 1000 then
            break
         end
         i = i + 1
      end

      Gui.mes("magic.alchemy", new_item)

      source:take_object(new_item)
      source:refresh_weight()

      return true
      -- <<<<<<<< shade2/proc.hsp:3236 	swbreak ..
   end
}

data:add {
   _id = "effect_cure_corruption",
   _type = "elona_sys.magic",
   elona_id = 1131,

   type = "effect",
   params = {
      "source",
   },

   cast = function(self, params)
      -- >>>>>>>> shade2/proc.hsp:3361 	case efCureCorrupt ..
      local source = params.source

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      Gui.play_sound("base.pray1", source.x, source.y)

      if params.curse_state == "none" or params.curse_state == "blessed" then
         Gui.mes_c("magic.cure_corruption.apply", "Green")
         Effect.modify_corruption(source, params.power * -10)
      else
         Gui.mes_c("magic.cure_corruption.cursed", "Purple")
         Effect.modify_corruption(source, 200)
      end

      return true
      -- <<<<<<<< shade2/proc.hsp:3371 	swbreak ..
   end
}

data:add {
   _id = "effect_molotov",
   _type = "elona_sys.magic",
   elona_id = 1133,

   type = "effect",
   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      -- >>>>>>>> shade2/proc.hsp:3406 	case efMorotov ..
      local source = params.source
      local target = params.target

      Gui.mes_visible("magic.molotov", target)
      Mef.create("elona.fire", target.x, target.y, { duration = Rand.rnd(15) + 25, params.power, origin = source })

      Effect.damage_map_fire(target.x, target.y, source)

      return true
      -- <<<<<<<< shade2/proc.hsp:3409 	swbreak ..
   end
}
