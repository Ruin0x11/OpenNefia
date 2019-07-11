data:extend_type(
   "base.chara",
   {
      elona_id = schema.Number,
      impress = schema.Number,
      attract = schema.Number,
      on_gold_amount = schema.Function,
   }
)

data:extend_type(
   "base.item",
   {
      elona_id = schema.Number,
   }
)

data:extend_type(
   "base.scenario",
   {
      restrictions = schema.Table,
   }
)

data:extend_type(
   "base.feat",
   {
      elona_id = schema.Optional(schema.Number),
   }
)

data:add_index("base.chara", "elona_id")
data:add_index("base.item", "elona_id")

require("mod.elona_sys.theme.init")
require("mod.elona_sys.map_loader.init")
require("mod.elona_sys.dialog.init")
