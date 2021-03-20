local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local util = require("mod.elona.data.map_archetype.util")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

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
