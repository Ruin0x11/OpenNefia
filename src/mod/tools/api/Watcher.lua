local Gui = require("api.Gui")

local Watcher = {}

function Watcher.get_widget()
   return Gui.hud_widget("tools.watcher_widget"):widget()
end

function Watcher.set(name, value, preserve_delta)
   return Watcher.get_widget():update_variable(name, value, preserve_delta)
end

function Watcher.clear()
   return Watcher.get_widget():clear()
end

function Watcher.update_watches()
   return Watcher.get_widget():update_watches()
end

function Watcher.start_watching_object(object, name, indices)
   return Watcher.get_widget():start_watching_object(object, name, indices)
end

function Watcher.stop_watching_object(object)
   return Watcher.get_widget():stop_watching_object(object)
end

return Watcher
