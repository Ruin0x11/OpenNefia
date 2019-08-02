local Resolver = require("api.Resolver")

local resolver = {
   resolve = function(self, params)
      return "female" .. self.text .. params.asd
   end,
   params = { text = "string" }
}

local arr = {
   resolve = function(self, params, result)
      result.gender = result.gender .. "dood"
      return result
   end,
   params = { text = "string" }
}

local proto = {
   param1 = 10,
   gender = Resolver.make(resolver, {text="a"}),
   Resolver.make(arr),
   Resolver.make(arr),
}

print("go")
print(inspect(Resolver.resolve(proto, {asd="g"})))
