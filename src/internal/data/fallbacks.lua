-- data that has to exist for no errors to occur
local data = require("internal.data")

local Resolver = require("api.Resolver")

data:add {
   _type = "base.map_tile",
   _id = "floor",

   is_solid = false,
   is_opaque = false
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


data:add {
   _type = "base.resolver",
   _id = "race",

   ordering = 100000,
   method = "add",
   invariants = { race = "string" },

   resolve = function(self, params)
      local race = data["base.race"][self.race or params.chara.race]
      if not race then
         return {}
      end
      return Resolver.resolve(race.copy_to_chara, params)
   end
}

data:add {
   _type = "base.resolver",
   _id = "class",

   ordering = 200000,
   method = "add",
   invariants = { class = "string" },

   resolve = function(self, params)
      local class = data["base.class"][self.class or params.chara.class]
      if not class then
         return {}
      end
      return Resolver.resolve(class.copy_to_chara, params)
   end
}
