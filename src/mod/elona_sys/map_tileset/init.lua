data:add_type {
   name = "map_tileset",
   schema = schema.Record {
      elona_id = schema.Number
   }
}
data:add_index("elona_sys.map_tileset", "elona_id")
