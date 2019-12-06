-- data that has to exist for no errors to occur
local data = require("internal.data")

local Resolver = require("api.Resolver")

data:add {
   _type = "base.map_tile",
   _id = "floor",

   is_solid = false,
   is_opaque = false,

   image = "mod/base/graphic/floor.png"
}

data:add {
   _type = "base.class",
   _id = "debugger",

   ordering = 0,
   item_type = 1,
   is_extra = true,
   equipment_type = 1,

   on_generate = function(self)
      for _, stat in data["base.stat"]:iter() do
         self.stats[stat._id] = 50
      end
   end,
}
