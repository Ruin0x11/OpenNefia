local Gui = require("api.Gui")
local TitlesMenu = require("mod.titles.api.gui.TitlesMenu")

require("mod.titles.data.init")
require("mod.titles.event.init")

Gui.bind_keys {
   ["titles.title"] = function(_, me)
      TitlesMenu:new(me):query()
   end
}
