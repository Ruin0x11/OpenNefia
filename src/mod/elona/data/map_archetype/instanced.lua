local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local util = require("mod.elona.data.map_archetype.util")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Feat = require("api.Feat")
local Chara = require("api.Chara")
local Enum = require("api.Enum")
local Area = require("api.Area")

local the_mine = {
   _type = "base.map_archetype",
   _id = "the_mine",

   on_generate_map = util.generate_122("puti"),
   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      level = 3,
      is_indoor = true,
      is_temporary = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      material_spot_type = "elona.dungeon"
   },

   events = {
      {
         id = "elona_sys.on_quest_check",
         name = "Sidequest: putit_attacks",

         callback = function(map)
            if Sidequest.progress("elona.putit_attacks") < 2 then
               if Sidequest.no_targets_remaining(map) then
                  Sidequest.set_progress("elona.putit_attacks", 2)
                  Sidequest.update_journal()
               end
            end
         end
      },
      {
         id = "base.on_map_generated",
         name = "Sidequest: putit_attacks",

         callback = function(map)
            Sidequest.set_quest_targets(map)
         end
      }
   }
}
data:add(the_mine)

data:add {
   _type = "base.area_archetype",
   _id = "the_mine",

   floors = {
      [1] = "elona.the_mine"
   }
}


local the_sewer = {
   _type = "base.map_archetype",
   _id = "the_sewer",

   on_generate_map = util.generate_122("sqSewer"),
   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      level = 20,
      is_indoor = true,
      is_temporary = true,
      default_ai_calm = 1,
      max_crowd_density = 0,
      material_spot_type = "elona.dungeon"
   },

   events = {
      {
         id = "elona_sys.on_quest_check",
         name = "Sidequest: sewer_sweeping",

         callback = function(map)
            if Sidequest.progress("elona.sewer_sweeping") < 2 then
               if Sidequest.no_targets_remaining(map) then
                  Sidequest.set_progress("elona.sewer_sweeping", 2)
                  Sidequest.update_journal()
               end
            end
         end
      },
      {
         id = "base.on_map_generated",
         name = "Sidequest: sewer_sweeping",

         callback = function(map)
            Sidequest.set_quest_targets(map)
         end
      }
   }
}
data:add(the_sewer)

data:add {
   _type = "base.area_archetype",
   _id = "the_sewer",

   floors = {
      [1] = "elona.the_sewer"
   }
}

do
   local test_site = {
      _id = "test_site",
      _type = "base.map_archetype",

      unique = true,

      properties = {
         music = "elona.puti",
         types = { "dungeon" },
         level = 5,
         is_indoor = true,
         is_not_renewable = true,
         max_crowd_density = 0,
         default_ai_calm = 0,
         material_spot_type = "elona.dungeon"
      },
      events = {
         {
            id = "elona_sys.on_quest_check",
            name = "Sidequest: nightmare",

            callback = function(map)
               if Sidequest.progress("elona.nightmare") < 2 then
                  if Sidequest.no_targets_remaining(map) then
                     Sidequest.set_progress("elona.nightmare", 2)
                     Sidequest.update_journal()
                  end
               end
            end
         }
      }
   }

   function test_site.starting_pos(map)
      return { x = 6, y = 27 }
   end

   function test_site.on_generate_map(area, floor)
      local map = Elona122Map.generate("sqNightmare")
      map:set_archetype("elona.shelter", { set_properties = true })

      Sidequest.set_quest_targets(map)

      return map
   end

   data:add(test_site)

   data:add {
      _type = "base.area_archetype",
      _id = "test_site",

      floors = {
         [1] = "elona.test_site"
      },

      --parent_area = {
      --   _id = "elona.north_tyris",
      --   on_floor = 1,
      --   x = 20,
      --   y = 20,
      --   starting_floor = 1
      --}
   }
end

local doom_ground = {
   _type = "base.map_archetype",
   _id = "doom_ground",

   starting_pos = MapEntrance.center,

   properties = {
      music = "elona.puti",
      types = { "dungeon" },
      level = 25,
      is_indoor = false,
      is_temporary = true,
      max_crowd_density = 0,
      material_spot_type = "elona.dungeon"
   },
}

function doom_ground.on_generate_map(area, floor)
   -- >>>>>>>> shade2/map.hsp:1390 			map_initCustom "sqkamikaze" ...
   local map = Elona122Map.generate("sqkamikaze")
   -- <<<<<<<< shade2/map.hsp:1390 			map_initCustom "sqkamikaze" ..

   -- >>>>>>>> shade2/map.hsp:1401  ...
   local x = math.floor(map:width() / 2)
   local y = math.floor(map:height() / 2)
   for _ = 1, 10 do
      local palmian_soldier = Chara.create("elona.palmian_elite_soldier", x, y, {}, map)
      if palmian_soldier then
         palmian_soldier.relation = Enum.Relation.Ally
      end
   end
   -- <<<<<<<< shade2/map.hsp:1404 			loop ..

   return map
end

function doom_ground.on_map_entered(map)
   -- >>>>>>>> shade2/map.hsp:1399 			flagKamikaze	=0 ...
   save.elona.flag_kamikaze_attack = 0
   -- <<<<<<<< shade2/map.hsp:1399 			flagKamikaze	=0 ..
end

function doom_ground.on_map_pass_turn(map)
   -- >>>>>>>> shade2/map.hsp:3318 	if gArea=areaKapul : if gLevel=25{ ...
   save.elona.flag_kamikaze_attack = save.elona.flag_kamikaze_attack + 1

   local x = 1
   local y = Rand.rnd(map:height())

   if Rand.one_in(4) then
      x = map:width() - 2
      y = Rand.rnd(map:height())
   end
   if Rand.one_in(5) then
      x = Rand.rnd(map:width())
      y = 1
   end
   if Rand.one_in(6) then
      x = Rand.rnd(map:width())
      y = map:height() - 2
   end

   local chara_id = "elona.kamikaze_yeek"

   local flag = save.elona.flag_kamikaze_attack

   if flag > 50 and Rand.one_in(10) then
      chara_id = "elona.bomb_rock"
   end
   if flag > 100 and Rand.one_in(10) then
      chara_id = "elona.kamikaze_samurai"
   end
   if flag > 150 and Rand.one_in(10) then
      chara_id = "elona.kamikaze_samurai"
   end
   if flag == 250 then
      Sidequest.update_journal()
      Sidequest.set_progress("elona.kamikaze_attack", 3)
      Gui.mes_c("misc.quest.kamikaze_attack.message", "SkyBlue")
      Gui.mes("misc.quest.kamikaze_attack.stairs_appear")

      -- TODO allow optionally setting map UIe instead of area UID for entrance
      local map_uid, start_x, start_y = map:previous_map_and_location()
      local area, floor = Area.for_map(map_uid)

      local stairs = assert(Feat.create("elona.stairs_down", 18, 9, {force=true}, map))
      stairs.params.area_uid = area.uid
      stairs.params.area_floor = floor
      stairs.params.area_starting_x = start_x
      stairs.params.area_starting_y = start_y
   end

   local enemy = Chara.create(chara_id, x, y, {}, map)
   if enemy then
      enemy:set_target(Chara.player(), 1000)
   end
   -- <<<<<<<< shade2/map.hsp:3336 	} ..
end

data:add(doom_ground)
