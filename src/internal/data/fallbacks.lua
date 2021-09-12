-- data that has to exist for no errors to occur
local data = require("internal.data")
local Enum = require("api.Enum")

data:add {
   _type = "base.map_tile",
   _id = "floor",

   is_solid = false,
   is_opaque = false,

   image = "mod/base/graphic/floor.png"
}

data:add {
   _type = "base.chip",
   _id = "default",

   image = "mod/base/graphic/blank.png"
}

data:add {
   _type = "base.chip",
   _id = "white",

   image = "mod/base/graphic/white.png"
}

data:add {
   _type = "base.chara",
   _id = "player",

   level = 1,
   rarity = 0,
   coefficient = 0
}
