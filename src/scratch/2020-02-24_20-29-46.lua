LogWidget = require("mod.tools.api.gui.LogWidget")
Gui = require("api.Gui")

Gui.add_hud_widget(LogWidget:new(), "tools.log_widget")

Event.register("base.on_log_message", "Send log message to widget",
               function(_, params)
                  local log = Gui.hud_widget("tools.log_widget")
                  if log then
                     log:widget():print(params.level, params.message)
                  end
               end)

Log.info"dood"

Watcher = require("mod.tools.api.Watcher")

Event.register("base.on_chara_moved", "Watch var",
               function(chara)
                  if chara:is_player() then
                     Watcher.set("x", chara.x)
                     Watcher.set("y", chara.y)
                  end
               end)

-- Local Variables:
-- elona-next-always-send-to-repl: t
-- End:
