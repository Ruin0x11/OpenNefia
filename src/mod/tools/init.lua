local InstancedMap = require("api.InstancedMap")

data:add {
   _type = "base.map_generator",
   _id = "blank",

   params = { stood_tile = "string" },
   generate = function(self, params, opts)
      local width = params.width or 20
      local height = params.height or 20

      local map = InstancedMap:new(width, height)
      map:clear(params.tile or "elona.grass")

      return map
   end,
}
