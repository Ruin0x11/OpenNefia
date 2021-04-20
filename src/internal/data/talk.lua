local data = require("internal.data")

data:add_type {
   name = "talk_event",

   fields = {
      {
         name = "elona_txt_id",
         type = "string?"
      },
      {
         name = "variant_txt_ids",
         type = "table?"
      }
   }
}

data:add_type {
   name = "tone",

   fields = {
      {
         name = "show_in_menu",
         default = nil,
         type = "boolean?"
      },
      {
         name = "texts",
         template = true,
         type = "table"
      },
   }
}

data:add {
   _type = "base.talk_event",
   _id = "calm",
   elona_txt_id = "txtCalm"
}

data:add {
   _type = "base.talk_event",
   _id = "aggro",
   elona_txt_id = "txtAggro"
}

data:add {
   _type = "base.talk_event",
   _id = "dead",
   elona_txt_id = "txtDead"
}

data:add {
   _type = "base.talk_event",
   _id = "killed",
   elona_txt_id = "txtKilled"
}

data:add {
   _type = "base.talk_event",
   _id = "welcome",
   elona_txt_id = "txtWelcome"
}

data:add {
   _type = "base.talk_event",
   _id = "dialog",
   elona_txt_id = "txtDialog"
}
