local IItemMuseumValued = require("mod.elona.api.aspect.IItemMuseumValued")
local ElonaBuilding = require("mod.elona.api.ElonaBuilding")

local ItemMuseumValuedCardAspect = class.class("ItemMuseumValuedCardAspect", IItemMuseumValued)

function ItemMuseumValuedCardAspect:init(item, params)
   self.museum_value = params.museum_value or nil
end

function ItemMuseumValuedCardAspect:calc_value(item, seen_charas)
   return ElonaBuilding.calc_default_museum_item_value(item, seen_charas) / 2
end

return ItemMuseumValuedCardAspect
