data:add_type {
   name = "dialog",
   schema = schema.Record {
      name = schema.String,
      image = schema.Number,
      max_hp = schema.Number,
      on_death = schema.Optional(schema.Function),
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "ignores_you",
   root = "talk",
   nodes = {
      __start = {
         text = {
            {"ignores_you", args = function(t) return {t.speaker} end},
         }
      },
   }
}
