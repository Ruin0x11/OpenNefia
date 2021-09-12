local Gui = require("api.Gui")
local Debug = require("mod.tools.api.debug.Debug")

require("mod.tools.data.init")

require("mod.tools.exec.config")
require("mod.tools.exec.widgets")

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
   ["tools.show_debug_menu"] = function()
      Debug.query_debug_menu()
   end,
}
