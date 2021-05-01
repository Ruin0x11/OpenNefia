local Chara = require("api.Chara")
local Event = require("api.Event")
local Area = require("api.Area")
local Rand = require("api.Rand")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Map = require("api.Map")
local Gui = require("api.Gui")
local FieldMap = require("mod.elona.api.FieldMap")
local Input = require("api.Input")
local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")

local function change_chip_lily(map)
   -- >>>>>>>> shade2/map.hsp:2019 	if areaId(gArea)=areaNoyel{ ...
   if map._archetype ~= "elona.noyel" then
      return
   end

   if Sidequest.progress("elona.pael_and_her_mom") >= 10 then
      local lily = Chara.find("elona.lily", "others", map)
      if Chara.is_alive(lily) then
         lily.image = "elona.chara_lily_sick"
         lily.portrait = nil
      end
   end
   -- <<<<<<<< shade2/map.hsp:2024 		} ..
end
Event.register("base.on_map_entered", "Change Lily's chip late in subquest", change_chip_lily)

local function pael_and_her_mom_update()
   -- >>>>>>>> shade2/main.hsp:662 		if (sqMother=1)or(sqMother=3)or(sqMother=5)or(sq ...
   local flag = Sidequest.progress("elona.pael_and_her_mom")
   if flag == 1 or flag == 3 or flag == 5 or flag == 7 or flag == 9 then
      local map = Map.current()
      local area = Area.for_map(map)
      if not area or area._archtype ~= "elona.noyel" then
         if Rand.one_in(20) then
            Sidequest.set_progress("elona.pael_and_her_mom", flag + 1)
            Sidequest.update_journal()
         end
      end
   end
   -- <<<<<<<< shade2/main.hsp:665 		} ..
end
Event.register("base.on_day_passed", "Update sidequest Pael and her Mom", pael_and_her_mom_update)

local function proc_prevent_enter_pyramid(feat, params, result)
   -- >>>>>>>> shade2/map.hsp:160 					if areaId(gArea)=areaPyramid    : if sqPyrami ...
   if params.prev_map and not params.prev_map:has_type("world_map") then
      return result
   end

   local area = result.area
   if area and area._archetype == "elona.pyramid" then
      if Sidequest.progress("elona.pyramid_trial") == 0 then
         Gui.mes("action.exit_map.no_invitation_to_pyramid")
         Input.query_more()
         local stood_tile = Map.tile(params.prev_map_x, params.prev_map_y, params.prev_map)
         result.area = nil
         result.map = FieldMap.generate_default(stood_tile, params.prev_map)
         return result
      end
   end
   -- <<<<<<<< shade2/map.hsp:160 					if areaId(gArea)=areaPyramid    : if sqPyrami ..
end
Event.register("elona.on_travel_using_feat", "Prevent entering pyramid if sidequest not accepted", proc_prevent_enter_pyramid)

local function check_sidequest_chara_killed(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1680 			if cBit(cGuardTemp,tc)=true{ ...
   if chara:is_player() or not chara:is_in_player_party() then
      return
   end

   local aspect = chara:get_aspect_or_default(ICharaElonaFlags)
   if aspect.is_being_escorted_sidequest then
      assert(chara:leave_party())
      chara.state = "Dead"
      chara:remove_ownership()
   end
   -- <<<<<<<< shade2/chara_func.hsp:1682 				} ..
end
Event.register("base.on_chara_killed", "Remove Poppy/sidequest chara from party if killed", check_sidequest_chara_killed)
Event.register("base.on_chara_place_failure", "Remove Poppy/sidequest chara from party on place failure", check_sidequest_chara_killed)

local function spawn_big_daddy(map)
   if map.is_temporary then
      return
   end

   local kill_count = save.elona.little_sisters_killed
   if Rand.one_in(15 + kill_count * 2) then
      Chara.create("elona.big_daddy", nil, nil, {}, map)
   end
end
Event.register("elona.on_populate_dungeon_map", "Spawn Big Daddy based on Little Sister kill count", spawn_big_daddy)
