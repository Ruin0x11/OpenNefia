local IAspect = require("api.IAspect")
local IItemReadable = require("mod.elona.api.aspect.IItemReadable")
local IChargeable = require("mod.elona.api.aspect.IChargeable")
local ElonaMagic = require("mod.elona.api.ElonaMagic")

local IItemSpellbook = class.interface("IItemSpellbook",
                                  {
                                     skill_id = "string"
                                  },
                                  { IAspect, IChargeable, IItemReadable })

IItemSpellbook.default_impl = "mod.elona.api.aspect.ItemSpellbookAspect"

function IItemSpellbook:localize_action()
   return "base:aspect._.elona.IItemSpellbook.action_name"
end

function IItemSpellbook:on_read(item, params)
   local skill_id = self:calc(item, "skill_id")
   return ElonaMagic.read_spellbook(item, skill_id, params)
end

return IItemSpellbook
