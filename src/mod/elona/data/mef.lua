local Gui = require("api.Gui")

data:add {
   _type = "base.mef",
   _id = "web",
   elona_id = 1,

   image = "elona.mef_web",

   on_stepped_on = function(self, params)
      Gui.mes("Web.")
   end,
}


data:add {
   _type = "base.mef",
   _id = "fire",
   elona_id = 5,

   image = "elona.mef_fire",

   -- TODO check if tile is water, if so do not place

   on_stepped_on = function(self, params)
      Gui.mes("Fire.")
   end,
}
