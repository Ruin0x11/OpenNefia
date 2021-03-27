local Gui = require("api.Gui")
local Autodig = require("mod.autodig.api.Autodig")

require("mod.autodig.data.init")
require("mod.autodig.event.init")

Gui.bind_keys {
   ["autodig.toggle_autodig"] = Autodig.toggle
}
