local IAspect = require("api.IAspect")
local ISortable = require("mod.elona.api.aspect.ISortable")

local IItemMusicDisc = class.interface("IItemMusicDisc", {
                                          music_id = "string",
                                                         }, { IAspect, ISortable })

IItemMusicDisc.default_impl = "mod.elona.api.aspect.ItemMusicDiscAspect"

function IItemMusicDisc:localize_action()
   return "base:aspect._.elona.IItemMusicDisc.action_name"
end

function IItemMusicDisc:sort(other)
   return self.music_id < other.music_id
end

function IItemMusicDisc:localize_music_name()
   return "???"
end

return IItemMusicDisc
