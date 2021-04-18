local IAspect = require("api.IAspect")

local IItemMuseumValued = class.interface("IItemMuseumValued",
                                  {
                                     museum_value = { type = "number", optional = true }
                                  },
                                  { IAspect })

IItemMuseumValued.default_impl = "mod.elona.api.aspect.ItemMuseumValuedFigureAspect"

function IItemMuseumValued:calc_value(item, base_value)
   return base_value
end

return IItemMuseumValued
