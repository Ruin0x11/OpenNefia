local Rand = require("api.Rand")
local Effect = require("mod.elona.api.Effect")
local Event = require("api.Event")
local World = require("api.World")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Itemgen = require("mod.tools.api.Itemgen")
local Equipment = require("mod.elona.api.Equipment")

local function decrease_nutrition(chara, params, result)
   if not chara:is_player() then
      return result -- TODO nil counts as no modifying result
   end

   local nutrition = chara:calc("nutrition")
   if nutrition < 2000 then
      if nutrition < 1000 then
         chara:damage_hp(Rand.rnd(2) + chara:calc("max_hp") / 50, "elona.hunger")
         if save.elona_sys.awake_hours % 10 == 0 then
            -- interrupt action
            if Rand.one_in(50) then
               Effect.modify_weight(chara, -1)
            end
         end
      end
      result.regeneration = false
   end

   return result
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
