local Rand = require("api.Rand")

data:add {
   _type = "base.resolver",
   _id = "between",

   invariants = { min = "any", max = "any" },

   resolve = function(self)
      return Rand.rnd(self.min, self.max)
   end
}

data:add {
   _type = "base.resolver",
   _id = "chance",

   invariants = { chance = "number", on_true = "any", on_false = "any" },

   resolve = function(self)
      return (Rand.percent_chance(self.chance) and self.on_true) or self.on_false
   end
}
