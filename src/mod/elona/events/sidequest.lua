local Chara = require("api.Chara")
local Event = require("api.Event")
local Area = require("api.Area")
local Rand = require("api.Rand")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Map = require("api.Map")

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
