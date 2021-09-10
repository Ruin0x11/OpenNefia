data:add_type {
   name = "map_tileset",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "tiles",
         type = types.map(types.data_id("base.map_tile"), types.some(types.data_id("base.map_tile"), types.callback({}, types.data_id("base.map_tile"))))
      },
      {
         name = "fog",
         type = types.data_id("base.map_tile")
      }
   }
}
