local InstancedMap = require("api.InstancedMap")

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

require("mod.tools.exec.config")
require("mod.tools.exec.interactive")
require("mod.tools.exec.widgets")
