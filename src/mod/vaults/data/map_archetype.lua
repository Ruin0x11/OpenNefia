local MapEntrance = require("mod.elona_sys.api.MapEntrance")

data:add {
   _type = "base.map_archetype",
   _id = "vault",

   -- starting_pos = MapEntrance.stairs_up,

   properties = {
      types = { "dungeon" },
      is_indoor = true,
      has_anchored_npcs = true,
      default_ai_calm = 0,
      material_spot_type = "elona.dungeon"
   }
}
