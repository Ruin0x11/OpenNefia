local IAspect = require("api.IAspect")

local IMapJANDungeon = class.interface("IMapJANDungeon",
                                  {
                                     firey_life_turns = "number",
                                  },
                                  IAspect)

IMapJANDungeon.default_impl = "mod.just_add_nefia.api.aspect.MapJANDungeonAspect"

function IMapJANDungeon:localize_action()
end

return IMapJANDungeon
