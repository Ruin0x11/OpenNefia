local Gui = require("api.Gui")

local Watcher = {}

function Watcher.get_widget()
   return Gui.hud_widget("tools.watcher_widget"):widget()
end

function Watcher.set(name, value, preserve_delta, group)
   return Watcher.get_widget():update_variable(name, value, preserve_delta, group)
end

function Watcher.clear()
   return Watcher.get_widget():clear()
end

function Watcher.update_watches()
   return Watcher.get_widget():update_watches()
end

function Watcher.start_watching_object(name, object, indices)
   return Watcher.get_widget():start_watching_object(name, object, indices)
end

function Watcher.stop_watching_object(name)
   return Watcher.get_widget():stop_watching_object(name)
end

function Watcher.start_watching_index(name, index)
   return Watcher.get_widget():start_watching_index(name, index)
end

function Watcher.stop_watching_index(name, index)
   return Watcher.get_widget():stop_watching_index(name, index)
end

return Watcher
