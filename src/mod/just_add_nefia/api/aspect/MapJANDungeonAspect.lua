local IMapJANDungeon = require("mod.just_add_nefia.api.aspect.IMapJANDungeon")

local MapJANDungeonAspect = class.class("MapJANDungeonAspect", { IMapJANDungeon })

function MapJANDungeonAspect:init(map, params)
   self.firey_life_turns = 0
end

return MapJANDungeonAspect
