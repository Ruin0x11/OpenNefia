local IItemMuseumValued = require("mod.elona.api.aspect.IItemMuseumValued")
local ElonaBuilding = require("mod.elona.api.ElonaBuilding")

local ItemMuseumValuedFigureAspect = class.class("ItemMuseumValuedFigureAspect", IItemMuseumValued)

function ItemMuseumValuedFigureAspect:init(item, params)
   self.museum_value = params.museum_value or nil
end

function ItemMuseumValuedFigureAspect:calc_value(item, seen_charas)
   return ElonaBuilding.calc_default_museum_item_value(item, seen_charas)
end

return ItemMuseumValuedFigureAspect
