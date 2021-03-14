local Area = require("api.Area")
local Nefia = require("mod.elona.api.Nefia")
local Event = require("api.Event")
local Map = require("api.Map")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Gui = require("api.Gui")
local Input = require("api.Input")

-- >>>>>>>> shade2/map.hsp:129 	if areaId(gArea)=areaRandDungeon:if gLevel=areaMa ...
local function vanquish_nefia_boss(map, params)
   local area = Area.for_map(map)
   if area == nil or not Nefia.get_type(area) then
      return
   end

   if area:deepest_floor() == Map.floor_number(map) then
      local boss_uid = Nefia.get_boss_uid(area)
      if boss_uid and boss_uid >= 0 then
         local boss = map:get_object_of_type("base.chara", boss_uid)
         if boss then
            boss:vanquish()
         end
      end
      Nefia.set_boss_uid(area, -1) -- Don't spawn another boss for this area.
   end
end
Event.register("base.on_map_leave", "Remove nefia boss on exit", vanquish_nefia_boss, 100000)
-- <<<<<<<< shade2/map.hsp:131 		} ..

-- >>>>>>>> shade2/map.hsp:395 	if areaId(gArea)=areaRandDungeon{ ...
local function spawn_nefia_boss(map, params)
   if params.load_type == "continue" then
      return
   end

   local area = Area.for_map(map)
   if area == nil or not Nefia.get_type(area) then
      return
   end

   if area:deepest_floor() == Map.floor_number(map) then
      local boss_uid = Nefia.get_boss_uid(area)
      if boss_uid and boss_uid < 0 then
         -- >>>>>>>> shade2/map.hsp:2053 		if gLevel=areaMaxLevel(gArea):if areaBoss(gArea) ...
         Gui.mes("nefia.no_dungeon_master", map.name)
         -- <<<<<<<< shade2/map.hsp:2053 		if gLevel=areaMaxLevel(gArea):if areaBoss(gArea) ..
      else
         DeferredEvent.add(function() DeferredEvents.nefia_boss(map, boss_uid) end)
      end
   end
end
Event.register("base.on_map_initialize", "Spawn nefia boss on deepest floor", spawn_nefia_boss, 100000)
-- <<<<<<<< shade2/map.hsp:398 		} ..

-- >>>>>>>> shade2/sound.hsp:408 		if (areaId(gArea)=areaRandDungeon)or(areaId(gAre ...
local function play_nefia_boss_music(map, _, music_id)
   local area = Area.for_map(map)
   if area == nil or not Nefia.get_type(area) then
      return
   end

   if area:deepest_floor() == Map.floor_number(map) then
      local boss_uid = Nefia.get_boss_uid(area)
      if boss_uid and boss_uid >= 0 then
         return "elona.boss"
      end
   end

   return music_id
end
Event.register("elona_sys.calc_map_music", "Play nefia boss music", play_nefia_boss_music, 200000)
-- <<<<<<<< shade2/sound.hsp:410 			} ..

-- >>>>>>>> shade2/action.hsp:837 	if areaId(gArea)=areaRandDungeon : if gLevel=area ...
local function prompt_leave_nefia_boss(feat, params, result)
   local map = feat:current_map()
   if map == nil then
      return
   end
   local area = Area.for_map(map)
   if area == nil or not Nefia.get_type(area) then
      return
   end

   if area:deepest_floor() == Map.floor_number(map) then
      local boss_uid = Nefia.get_boss_uid(area)
      if boss_uid and boss_uid >= 0 then
         Gui.mes("action.use_stairs.prompt_give_up_quest")
         if not Input.yes_no() then
            return { blocked = true }
         end
      end
   end

   return result
end
Event.register("elona.before_travel_using_feat", "Prompt leaving nefia boss", prompt_leave_nefia_boss, 50000)
-- <<<<<<<< shade2/action.hsp:841 	} ..

local function proc_nefia_boss_defeated(victim, params)
   -- >>>>>>>> shade2/chara_func.hsp:1717 			if (gLevel=areaMaxLevel(gArea))or(gArea=areaVoi ...
   local map = victim:current_map()
   if map == nil then
      return
   end
   local area = Area.for_map(map)
   if area == nil or not Nefia.get_type(area) then
      return
   end

   local boss_uid = Nefia.get_boss_uid(area)
   if boss_uid == victim.uid then
      DeferredEvent.add(function() DeferredEvents.nefia_boss_defeated(map) end)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1719 				} ..
end
Event.register("base.on_kill_chara", "Add reward for defeating nefia boss", proc_nefia_boss_defeated, 100000)
