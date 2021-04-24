local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

data:add {
   _type = "elona_sys.dialog",
   _id = "zeome",

   nodes = {
      -- >>>>>>>> shade2/chat.hsp:339 	case 2 ...
      __start = {
         text = "talk.unique.zeome.dialog",
         on_finish = function()
            Sidequest.set_progress("elona.main_quest", 170)
         end
      }
      -- <<<<<<<< shade2/chat.hsp:342 	goto *chat_end ..
   }
}
