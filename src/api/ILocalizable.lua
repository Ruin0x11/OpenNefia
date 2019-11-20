--- @module ILocalizable

local ILocalizable  = class.interface("ILocalizable",
                                      {
                                         produce_locale_data = "function"
                                      })

--- Produces the data used to localize this object. This table can be
--- freeform but should only contain simple values
--- (numbers/booleans/strings).
---
--- @treturn table
function ILocalizable:produce_locale_data()
   return {}
end

return ILocalizable
