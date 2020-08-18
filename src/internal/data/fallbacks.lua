-- data that has to exist for no errors to occur
local data = require("internal.data")

data:add {
   _type = "base.map_tile",
   _id = "floor",

   is_solid = false,
   is_opaque = false,

   image = "mod/base/graphic/floor.png"
}

data:add {
   _type = "base.chara",
   _id = "player",

   level = 1
}
