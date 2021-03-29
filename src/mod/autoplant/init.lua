local Gui = require("api.Gui")
local Autoplant = require("mod.autoplant.api.Autoplant")

require("mod.autoplant.data.init")
require("mod.autoplant.event.init")

Gui.bind_keys {
   ["autoplant.toggle_autoplant"] = Autoplant.toggle
}
