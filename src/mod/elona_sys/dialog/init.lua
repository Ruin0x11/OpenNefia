data:add_type {
   name = "dialog",
   fields = {
      {
         name = "nodes",
         type = types.map(types.string, types.any) -- TODO
      }
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "ignores_you",
   nodes = {
      __start = {
         text = {
            {"talk.ignores_you", args = function(t) return {t.speaker} end},
         }
      },
   }
}
