local Event = require("api.Event")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Chara = require("api.Chara")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local Area = require("api.Area")
local Feat = require("api.Feat")
local Scene = require("mod.elona_sys.scene.api.Scene")
local Map = require("api.Map")
local Home = require("mod.elona.api.Home")

local function proc_main_quest_scenes(map)
   -- >>>>>>>> shade2/map.hsp:1995 	proc "Map:Proc scene" ...
   if not Sidequest.is_active_main_quest("elona.main_quest") then
      return
   end

   local function stones(no)
      return function()
         local result = 0
         if save.elona.flag_fools_magic_stone then
            result = result + 1
         end
         if save.elona.flag_kings_magic_stone then
            result = result + 1
         end
         if save.elona.flag_sages_magic_stone then
            result = result + 1
         end
         return result >= no
      end
   end

   local flag = Sidequest.progress("elona.main_quest")

   local FLAGS = {
      [9]   = { scene = "elona.story_2",  new_flag = 10 },
      [60]  = { scene = "elona.story_5",  new_flag = 65 },
      [110] = { scene = "elona.story_26", new_flag = 115 },
      [115] = { scene = "elona.story_28", new_flag = 116, pred = stones(1) },
      [116] = { scene = "elona.story_29", new_flag = 117, pred = stones(2) },
      [117] = { scene = "elona.story_30", new_flag = 120, pred = stones(3) },
   }

   local f = FLAGS[flag]
   if f and (not f.pred or f.pred()) then
      Scene.play(f.scene)
      Sidequest.set_progress("elona.main_quest", f.new_flag)
   end

   if map._archetype == "elona.lesmias" then
      local floor_number = Map.floor_number(map)

      local LESIMAS_FLAGS = {
         [10]   = { scene = "elona.story_3",  new_flag = 20 },
         [65]  = { scene = "elona.story_7",  new_flag = 70, floor = 4 },
         [70] = { scene = "elona.story_15", new_flag = 75, floor = 7 },
         [75] = { scene = "elona.story_16", new_flag = 80, floor = 10 },
         [80] = { scene = "elona.story_17", new_flag = 85, floor = 14 },
         [85] = { scene = "elona.story_24", new_flag = 90, floor = 16 },
         [125] = { scene = "elona.story_33", new_flag = 130, floor = 26 },
         [130] = { scene = "elona.story_35", new_flag = 135, floor = 28 },
         [135] = { scene = "elona.story_40", new_flag = 140, floor = 31 },
         [140] = { scene = "elona.story_60", new_flag = 145, floor = 35 },
         [145] = { scene = "elona.story_70", new_flag = 150, floor = 38 },
         [150] = { scene = "elona.story_90", new_flag = 160, floor = 42 },
      }

      f = LESIMAS_FLAGS[flag]
      if f and (not f.floor or f.floor == floor_number) then
         Scene.play(f.scene)
         Sidequest.set_progress("elona.main_quest", f.new_flag)
      end
   end
   -- <<<<<<<< shade2/map.hsp:2015 		} ..
end
Event.register("base.after_map_changed", "Proc main quest scenes", proc_main_quest_scenes)

local function find_kapul(map)
   return Area.iter_entrances_in_parent(map):filter(
      function(feat)
         local area = Area.get(feat.params.area_uid)
         return area and area._archetype == "elona.port_kapul"
                                                   end)
      :nth(1)
end

local function proc_three_years_elapsed(map)
   -- >>>>>>>> shade2/map.hsp:1870 	if gArea=areaNorthTyris:if flagMain=180{ ...
   if not Sidequest.is_active_main_quest("elona.main_quest") then
      return
   end

   if map._archetype == "elona.north_tyris"
      and Sidequest.progress("elona.main_quest") == 180
   then
      local kapul = find_kapul(map)
      if Feat.is_alive(kapul) then
         local player = Chara.player()
         player:set_pos(kapul.x, kapul.y)
         player.direction = Enum.Direction.West
         -- TODO scroll edge X
         Gui.mes_newline()
         Gui.mes("scenario.three_years_later")
      end

      Scene.play("elona.story_100")
      Sidequest.set_progress("elona.main_quest", 200)
      save.base.date.year = save.base.date.year + 3
   end
   -- <<<<<<<< shade2/map.hsp:1873 		} ..
end
Event.register("base.after_map_changed", "Proc main quest clear event (\"Three years elapsed...\")", proc_three_years_elapsed)

local function proc_main_quest_vernis(map)
   -- >>>>>>>> shade2/map.hsp:2036 		if flagMain=0:sceneId=1:gosub *scene:flagMain=9 ...
   if not Sidequest.is_active_main_quest("elona.main_quest") then
      return
   end

   if map._archetype == "elona.vernis"
      and Sidequest.progress("elona.main_quest") == 0
   then
      Scene.play("elona.story_1")
      Sidequest.set_progress("elona.main_quest", 9)
   end
   -- <<<<<<<< shade2/map.hsp:2036 		if flagMain=0:sceneId=1:gosub *scene:flagMain=9 ..
end
Event.register("base.after_map_changed", "Proc main quest (Vernis)", proc_main_quest_vernis)

-- >>>>>>>> shade2/map.hsp:2040 	if gArea=areaPalmia{ ...
local function proc_main_quest_palmia(map)
   -- >>>>>>>> shade2/map.hsp:2036 		if flagMain=0:sceneId=1:gosub *scene:flagMain=9 ...
   if Sidequest.is_active_main_quest("elona.main_quest")
      and map._archetype == "elona.palmia"
   then
      if Sidequest.progress("elona.main_quest") == 30 then
         Scene.play("elona.story_4")
         Sidequest.set_progress("elona.main_quest", 40)
      elseif Sidequest.progress("elona.main_quest") == 100 then
         Scene.play("elona.story_25")
         Sidequest.set_progress("elona.main_quest", 105)
      end
   end
   -- <<<<<<<< shade2/map.hsp:2036 		if flagMain=0:sceneId=1:gosub *scene:flagMain=9 ..
end
-- <<<<<<<< shade2/map.hsp:2043 		} ..
Event.register("base.after_map_changed", "Proc main quest (Palmia)", proc_main_quest_palmia)

local function proc_vanquish_lomias_larnneire(map)
   -- >>>>>>>> shade2/map.hsp:2090 		if flagMain!0{ ...
   if Sidequest.is_active_main_quest("elona.main_quest")
      and Sidequest.progress("elona.main_quest") > 0
      and Home.is_home(map)
   then
      local lomias = Chara.find("elona.lomias", "others", map)
      if lomias then
         lomias:vanquish()
      end
      local larnneire = Chara.find("elona.lomias", "others", map)
      if larnneire then
         larnneire:vanquish()
      end
   end
   -- <<<<<<<< shade2/map.hsp:2094 		} ..
end
Event.register("base.on_map_entered", "Vanquish Lomias/Larnneire if story was progressed", proc_vanquish_lomias_larnneire)

local function proc_vanquish_xabi(map)
   -- >>>>>>>> shade2/map.hsp:2090 		if flagMain!0{ ...
   if Sidequest.is_active_main_quest("elona.main_quest")
      and Sidequest.progress("elona.main_quest") >= 90
      and map._archetype == "elona.palmia"
   then
      local xabi = Chara.find("elona.xabi", "others", map)
      if xabi then
         xabi:vanquish()
      end
   end
   -- <<<<<<<< shade2/map.hsp:2094 		} ..
end
Event.register("base.on_map_entered", "Vanquish Xabi if story was progressed", proc_vanquish_xabi)
