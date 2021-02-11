local data = require("internal.data")

data:add_multi(
   "base.config_menu",
   {
      {
         _id = "default",

         -- >>>>>>>> elona122/shade2/help.hsp:873 		dx=370:dy=270 ...
         menu_width = 370,
         menu_height = 270,
         -- <<<<<<<< elona122/shade2/help.hsp:873 		dx=370:dy=270 ..

         items = {
            { _type = "base.config_menu", _id = "base.game" },
            { _type = "base.config_menu", _id = "base.screen" },
            { _type = "base.config_menu", _id = "base.net" },
            { _type = "base.config_menu", _id = "base.anime" },
            { _type = "base.config_menu", _id = "base.input" },
            { _type = "base.config_menu", _id = "base.keybindings" },
            { _type = "base.config_menu", _id = "base.message" },
            { _type = "base.config_menu", _id = "base.language" }
         }
      }
   }
)
