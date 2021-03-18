local Rand = require("api.Rand")
local Effect = require("mod.elona.api.Effect")
local Event = require("api.Event")
local World = require("api.World")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Itemgen = require("mod.elona.api.Itemgen")
local Equipment = require("mod.elona.api.Equipment")
local Gui = require("api.Gui")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Const = require("api.Const")
local Map = require("api.Map")
local Feat = require("api.Feat")
local Filters = require("mod.elona.api.Filters")
local MapgenUtils = require("mod.elona.api.MapgenUtils")

local function decrease_nutrition(chara, params, result)
   -- >>>>>>>> shade2/calculation.hsp:1274 		if cHunger(r1)<hungerHungry{ ...
   if not chara:is_player() then
      return result
   end

   local nutrition = chara:calc("nutrition")
   if nutrition < Const.HUNGER_THRESHOLD_HUNGRY then
      if nutrition < Const.HUNGER_THRESHOLD_STARVING then
         if not chara:has_activity("elona.eating") then
            chara:damage_hp(Rand.rnd(2) + chara:calc("max_hp") / 50, "elona.hunger")
            if save.base.play_turns % 10 == 0 then
               chara:interrupt_activity()
               if Rand.one_in(50) then
                  Effect.modify_weight(chara, -1)
               end
            end
         end
      end
      result.regeneration = false
   end
   -- <<<<<<<< shade2/calculation.hsp:1277 			} ..

   -- >>>>>>>> shade2/calculation.hsp:1278 		if gSleep>=sleepModerate{ ...
   if save.elona_sys.awake_hours >= Const.SLEEP_THRESHOLD_MODERATE then
      if save.base.play_turns % 100 == 0 then
         Gui.mes("misc.status_ailment.sleepy")
      end
      if Rand.one_in(2) then
         result.regeneration = false
      end
      if save.elona_sys.awake_hours >= Const.SLEEP_THRESHOLD_HEAVY then
         result.regeneration = false
         chara:damage_sp(1)
      end
   end

   return result
   -- <<<<<<<< shade2/calculation.hsp:1282 			} ..
end

Event.register("base.on_chara_turn_end", "Decrease nutrition", decrease_nutrition)

local function play_default_map_music(map, _, music_id)
   if map:has_type("field") then
      return "none"
   end
   if map:has_type("town") then
      music_id = "elona.town1"
   end
   if map:has_type("player_owned") then
      music_id = "elona.home"
   end
   if map:calc("music") then
      music_id = map:calc("music")
   end
   if map:has_type("dungeon") then
      local choices = {
         "elona.dungeon1",
         "elona.dungeon2",
         "elona.dungeon3",
         "elona.dungeon4",
         "elona.dungeon5",
         "elona.dungeon6"
      }
      local hour = World.date().hour
      music_id = choices[hour % 6 + 1]
   end

   if music_id == nil or map:has_type("world_map") then
      local choices = {
         "elona.field1",
         "elona.field2",
         "elona.field3",
      }
      local day = World.date().day
      music_id = choices[day % 3 + 1]
   end

   return music_id
end

Event.register("elona_sys.calc_map_music", "Play default map music",
               play_default_map_music)

local function on_map_renew_minor(map)
-- >>>>>>>> shade2/map.hsp:2253 			if (mType=mTypeTown)or(mType=mTypeVillage)or(gA ...
   if map:has_type("town") or map:has_type("guild")
      or map.uid == save.base.home_map_uid
   then
      for _, chara in Chara.iter_others(map):filter(Chara.is_alive) do
         Effect.generate_money(chara)

         if chara._id == "elona.bard" then
            local pred = function(i) return i:has_category("elona.furniture_instrument") end
            if not chara:iter_items():any(pred) and Rand.one_in(150) then
               Item.create("elona.stradivarius", nil, nil, nil, chara)
            else
               local filter = {
                  level = Calc.calc_object_level(chara:calc("level"), map),
                  quality = Calc.calc_object_quality(Enum.Quality.Normal),
                  categories = "elona.furniture_instrument"
               }
               Itemgen.create(nil, nil, filter, chara)
            end
         end

         if Rand.one_in(5) then
            Equipment.generate_and_equip(chara)
         end

         if Rand.one_in(2) then
            if chara:iter_items():length() < 8 then
               local filter = {
                  level = Calc.calc_object_level(chara:calc("level"), map),
                  quality = Calc.calc_object_quality(Enum.Quality.Normal),
               }
               local item = Itemgen.create(nil, nil, filter, chara)
               if (item:calc("cargo_weight") or 0) > 0 or item:calc("weight") <= 0 or item:calc("weight") >= 4000 then
                  item.amount = 0
                  item:remove_ownership()
               end
            end
         end
      end
   end
-- <<<<<<<< shade2/map.hsp:2264 				} ..
end
Event.register("base.on_map_renew_minor", "Map renew minor events", on_map_renew_minor)

local function ai_snow(chara, _, result)
   if result then
      return result -- TODO implement in event system
   end

   if chara.item_to_use or chara:relation_towards(Chara.player()) == Enum.Relation.Ally then
      return result
   end

   -- >>>>>>>> shade2/ai.hsp:241 		if (gArea=areaNoyel)or(gArea=areaSister):if (cId ...
   local map = chara:current_map()
   if not map:calc("has_snow") then
      return result
   end

   if not chara:calc("can_use_snow") or not chara:is_in_fov() then
      return result
   end

   if map:tile(chara.x, chara.y).kind ~= Enum.TileRole.Snow then
      return result
   end

   if save.elona.fire_giant_uid then
      local fire_giant = map:get_object_of_type("base.chara", save.elona.fire_giant_uid)
      if Rand.one_in(4) and Chara.is_alive(fire_giant) and fire_giant:is_in_fov() then
         local snowball = Item.create("elona.handful_of_snow", nil, nil, {}, chara)
         if snowball then
            Gui.mes_c("ai.fire_giant", "SkyBlue")
            ElonaAction.throw(chara, snowball, fire_giant.x, fire_giant.y)
            return true, "blocked"
         end
      end
   end

   if Rand.one_in(12) then
      local snowman = Item.iter(map):filter(function(i) return i._id == "elona.snow_man" and i:is_in_fov() end):nth(1)
      if snowman then
         local snowball = Item.create("elona.handful_of_snow", nil, nil, {}, chara)
         if snowball then
            ElonaAction.throw(chara, snowball, snowman.x, snowman.y)
            return true, "blocked"
         end
      end
   end

   if Rand.one_in(10) then
      if Item.at(chara.x, chara.y, map):length() == 0 then
         local snowman = Item.create("elona.snow_man", chara.x, chara.y, {}, map)
         if snowman then
            Gui.play_sound("base.snow", chara.x, chara.y)
            Gui.mes("ai.makes_snowman", chara, snowman:build_name())
            return true, "blocked"
         end
      end
   end

   if Rand.one_in(12) then
      local snowball = Item.create("elona.handful_of_snow", nil, nil, {}, chara)
      if snowball then
         local player = Chara.player()
         Gui.mes_c("ai.snowball", "SkyBlue")
         ElonaAction.throw(chara, snowball, player.x, player.y)
         return true, "blocked"
      end
   end
   -- <<<<<<<< shade2/ai.hsp:257 			} ..
end
Event.register("elona.on_ai_calm_action", "Use snow if available", ai_snow, { priority = 70000 })

-- >>>>>>>> shade2/command.hsp:3220 	cell_itemOnCell cX(pc),cY(pc)	 ...
local function scoop_up_snow(chara, params, result)
   if Item.at(chara.x, chara.y):length() > 0 then
      return result
   end

   local map = chara:current_map()
   if map:has_type("town") or map:has_type("guild") then
      if map:tile(chara.x, chara.y).kind == Enum.TileRole.Snow then
         Gui.play_sound("base.foot2a", chara.x, chara.y)
         Gui.mes("action.get.snow")
         if not Effect.do_stamina_check(chara, 10) then
            Gui.mes("magic.common.too_exhausted")
            return true, "blocked"
         end
         local snow = Item.create("elona.handful_of_snow", nil, nil, {}, chara)
         if snow then
            snow.curse_state = Enum.CurseState.Normal
            snow.identify_state = Enum.IdentifyState.Full
            snow:stack(true)
            return true, "blocked"
         end
      end
   end

   return result
end

Event.register("elona_sys.on_get", "Scoop up snow", scoop_up_snow)
-- <<<<<<<< shade2/command.hsp:3228 			} ..
