local Dungeon = require("mod.elona_sys.api.Dungeon")

data:add(
   {
      _id = "type_1",
      _type = "elona_sys.dungeon_template",

      generate = Dungeon.gen_type_1
   }
)

data:add(
   {
      _id = "type_4",
      _type = "elona_sys.dungeon_template",

      generate = Dungeon.gen_type_4
   }
)

data:add(
   {
      _id = "type_5",
      _type = "elona_sys.dungeon_template",

      generate = Dungeon.gen_type_5
   }
)
