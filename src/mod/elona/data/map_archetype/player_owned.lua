local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local HomeMap = require("mod.elona.api.HomeMap")

local your_home = {
   _id = "your_home",
   _type = "base.map_archetype",
   elona_id = 7,

   starting_pos = MapEntrance.south,

   properties = {
      music = "elona.lonely",
      types = { "player_owned" },
      level = 1,
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 1,
      tileset = "elona.home",

      is_fixed = true,
      can_return_to = false
   }
}

data:add(your_home)

data:add {
   _type = "base.area_archetype",
   _id = "your_home",

   image = "elona.feat_area_your_dungeon",

   on_generate_floor = function(area, floor)
      local home_rank = save.elona.home_rank
      local map
      if floor == 1 then
         map = HomeMap.generate(home_rank)
      else
         map = HomeMap.generate(home_rank, { no_callbacks = true })
      end

      map:set_archetype("elona.your_home", { set_properties = true })
      return map
   end,

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 22,
      y = 21,
      starting_floor = 1
   }
}
