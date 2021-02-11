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
            { _type = "base.config_menu", _id = "base.anime" }
         }
      }
   }
)

data:add_multi(
   "base.config_menu",
   {
      {
         _id = "anime",

         -- >>>>>>>> elona122/shade2/help.hsp:898 		dx=440:dy=300 ...
         menu_width = 440,
         menu_height = 300,
         -- <<<<<<<< elona122/shade2/help.hsp:898 		dx=440:dy=300 ..

         items = {
            "base.screen_refresh",
            "base.skip_scene_playback"
         }
      }
   }
)
