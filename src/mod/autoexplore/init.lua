local Gui = require("api.Gui")
local Autoexplore = require("mod.autoexplore.api.Autoexplore")

require("mod.autoexplore.data")

Gui.bind_keys {
   ["autoexplore.autoexplore"] = Autoexplore.do_autoexplore,
   ["autoexplore.travel"] = Autoexplore.do_travel
}