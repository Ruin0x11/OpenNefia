local IAspectModdable = require("api.IAspectModdable")

local IAspect = class.interface("IAspect", { localize_action = "function" }, { IAspectModdable })

function IAspect:localize_action(obj, iface)
   return "???"
end

return IAspect
