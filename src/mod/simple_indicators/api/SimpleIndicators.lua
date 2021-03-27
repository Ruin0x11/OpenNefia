local Gui = require("api.Gui")
local global = require("mod.simple_indicators.internal.global")

local SimpleIndicators = {}

function SimpleIndicators.set_enabled(id, enabled)
   data["simple_indicators.indicator"]:ensure(id)
   global.disabled_indicators[id] = not enabled
   Gui.refresh_hud(true)
end

return SimpleIndicators
