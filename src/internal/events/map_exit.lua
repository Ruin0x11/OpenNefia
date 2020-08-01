local Chara = require("api.Chara")
local Map = require("api.Map")
local Gui = require("api.Gui")
local save = require("internal.global.save")
local World = require("api.World")
local Event = require("api.Event")
local Save = require("api.Save")
local Area = require("api.Area")

local function proc_area_changed(prev_map, params)
   -- >>>>>>>> shade2/map.hsp:202 	if gArea ! gAreaPrev{ ..
   local prev_area = Area.for_map(prev_map)
   local next_area = Area.for_map(params.next_map)
   if prev_area == next_area then
      return
   end

   if prev_map:has_type({"town", "guild"}) or prev_map:calc("is_travel_destination") then
      save.base.travel_distance = 0
      save.base.travel_last_town_name = prev_map.name
      save.base.travel_date = World.date_hours()
   end

   if not prev_map:has_type("field") then
      Save.autosave()
   end
   -- <<<<<<<< shade2/map.hsp:204 		if (areaType(gArea)!mTypeWorld)&(areaType(gArea) ..

   -- >>>>>>>> shade2/map.hsp:212 			if areaType(gAreaPrev)=mTypeWorld{ ..
   local was_killed = false -- TODO player_died
   if was_killed then
      Gui.mes("action.exist_map.delivered_to_your_home")
      -- TODO weather
   else
      if Map.is_world_map(prev_map) then
         Gui.mes("action.exit_map.entered", params.next_map.name)
      else
         if prev_map:has_type("quest") then
            Gui.mes("action.exit_map.returned_to", params.next_map.name)
         else
            Gui.mes("action.exit_map.left", prev_map.name)
         end
      end
   end

   local player = Chara.player()
   if player:calc("cargo_weight") > player:calc("max_cargo_weight") then
      Gui.mes("action.exit_map.burdened_by_cargo")
   end
   -- <<<<<<<< shade2/map.hsp:219 		} ..
end

Event.register("base.on_map_leave", "Events on area change", proc_area_changed)
