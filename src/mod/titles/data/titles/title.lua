data:add_type {
   name = "title",
   fields = {
      {
         -- TODO standardize
         name = "elona_variant_ids",
         type = types.map(types.identifier, types.uint),
      },
      {
         name = "localize_info",
         type = types.callback({"info", types.table}, types.table)
      },
      {
         name = "check_earned",
         type = types.callback({"chara", types.map_object("base.chara")}, types.boolean)
      },
      {
         name = "on_refresh",
         type = types.callback("chara", types.map_object("base.chara"), "effect_on", types.boolean)
      }
   }
}
