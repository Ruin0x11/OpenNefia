local IAspect = require("api.IAspect")
local IItemReadable = require("mod.elona.api.aspect.IItemReadable")
local IChargeable = require("mod.elona.api.aspect.IChargeable")
local IItemInittable = require("mod.elona.api.aspect.IItemInittable")
local Rand = require("api.Rand")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local I18N = require("api.I18N")
local Enum = require("api.Enum")

local IItemAncientBook = class.interface("IItemAncientBook",
                                         {
                                            difficulty = "number",
                                            is_decoded = "boolean"
                                         },
                                         { IAspect, IChargeable, IItemReadable, IItemInittable, IItemLocalizableExtra })

IItemAncientBook.default_impl = "mod.elona.api.aspect.ItemAncientBookAspect"

function IItemAncientBook:localize_action()
   return "base:aspect._.elona.IItemAncientBook.action_name"
end

function IItemAncientBook:on_init_params(item, params)
   -- >>>>>>>> shade2/item.hsp:30 	#define global maxMageBook 14 ..
   local MAX_LEVEL = 14
   -- <<<<<<<< shade2/item.hsp:30 	#define global maxMageBook 14 ..

   -- >>>>>>>> shade2/item.hsp:673 	if iId(ci)=idMageBook{ ..
   local object_level = params.level
   self.difficulty = Rand.rnd(Rand.rnd(math.floor(math.clamp(object_level / 2, 0, MAX_LEVEL))) + 1)
   -- <<<<<<<< shade2/item.hsp:675 		} ..
end

function IItemAncientBook:on_read(item, params)
   local ItemFunction = require("mod.elona.api.ItemFunction")
   return ItemFunction.read_ancient_book(item, params)
end

function IItemAncientBook:localize_extra(s, item)
   if item:calc("identify_state") >= Enum.IdentifyState.Full then
      local difficulty = self:calc(item, "difficulty")
      local title = I18N.get("base:aspect._.elona.IItemAncientBook.titles._" .. difficulty)
      s = I18N.get("base:aspect._.elona.IItemAncientBook.title", title, s)
   end
   if self:calc(item, "is_decoded") then
      s = I18N.get_optional("base:aspect._.elona.IItemAncientBook.decoded", s) or s
   else
      s = I18N.get_optional("base:aspect._.elona.IItemAncientBook.undecoded", s) or s
   end
   return s
end

return IItemAncientBook
