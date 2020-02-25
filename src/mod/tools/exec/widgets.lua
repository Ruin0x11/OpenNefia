local Event = require("api.Event")
local Gui = require("api.Gui")

local LogWidget = require("mod.tools.api.gui.LogWidget")

Gui.add_hud_widget(LogWidget:new(), "tools.log_widget")

Event.register("base.on_log_message", "Send log message to widget",
               function(_, params)
                  local log = Gui.hud_widget("tools.log_widget")
                  if log then
                     log:widget():print(params.level, params.message)
                  end
               end)

local WatcherWidget = require("mod.tools.api.gui.WatcherWidget")
local Watcher = require("mod.tools.api.Watcher")

Gui.add_hud_widget(WatcherWidget:new(), "tools.watcher_widget")

Event.register("base.on_turn_begin", "Update watches on turn begin",
               function()
                  Watcher.update_watches()
               end)
