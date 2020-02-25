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

      return map, "blank"
   end,
}

data:add_type {
   name = "interactive_fn",
   fields = {
      {
         name = "func",
         type = "function",
         template = true
      },
      {
         name = "spec",
         type = "table",
         template = true
      }
   }
}

data:add {
   _type = "base.keybind",
   _id = "m_x",
   default = "alt_x"
}

data:add {
   _type = "base.keybind",
   _id = "prefix_m_x",
   default = "ctrl_alt_x"
}

data:add {
   _type = "base.keybind",
   _id = "prompt_previous",
   default = "ctrl_p"
}

data:add {
   _type = "base.keybind",
   _id = "prompt_next",
   default = "ctrl_n"
}

require("mod.tools.exec.interactive")
