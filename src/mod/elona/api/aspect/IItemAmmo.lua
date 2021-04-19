local IAspect = require("api.IAspect")

local IItemAmmo = class.interface("IItemAmmo", {
                                     dice_x = "number",
                                     dice_y = "number",
                                     skill = "string",
                                               }, { IAspect })

IItemAmmo.default_impl = "mod.elona.api.aspect.ItemAmmoAspect"

function IItemAmmo:is_active(item)
   return true
end

return IItemAmmo
