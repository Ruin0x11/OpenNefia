local util = require("mod.elona.data.map_archetype.util")

data:add {
   _type = "base.map_archetype",
   _id = "north_tyris",
   elona_id = 4,

   on_generate_map = util.generate_122("ntyris"),

   properties = {
      types = { "world_map" },
      tileset = "elona.world_map",
      turn_cost = 50000,
      is_indoor = false,
      has_anchored_npcs = true,
      default_ai_calm = 0,
   },
}

data:add {
   _type = "base.area_archetype",
   _id = "north_tyris",
   elona_id = 4,

   floors = {
      [1] = "elona.north_tyris"
   }
}
