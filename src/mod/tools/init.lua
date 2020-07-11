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

require("mod.tools.data.init")

require("mod.tools.exec.config")
require("mod.tools.exec.interactive")
require("mod.tools.exec.widgets")

local Gui = require("api.Gui")
local function toggle_widget(id)
   local widget = Gui.global_widget(id)
   widget:set_enabled(not widget:enabled())
end

Gui.bind_keys {
   ["tools.toggle_fps"] = function()
      toggle_widget("fps_counter")
   end,
   ["tools.toggle_log"] = function()
      toggle_widget("tools.log_widget")
   end,
}
