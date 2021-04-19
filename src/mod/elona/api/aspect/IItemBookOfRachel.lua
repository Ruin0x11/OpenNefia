local IAspect = require("api.IAspect")
local IItemReadable = require("mod.elona.api.aspect.IItemReadable")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local Gui = require("api.Gui")
local Enum = require("api.Enum")
local I18N = require("api.I18N")

local IItemBookOfRachel = class.interface("IItemBookOfRachel",
                                  {
                                     book_number = "number"
                                  },
                                  {
                                     IAspect,
                                     IItemReadable,
                                     IItemLocalizableExtra
                                  })

IItemBookOfRachel.default_impl = "mod.elona.api.aspect.ItemBookOfRachelAspect"

function IItemBookOfRachel:localize_action()
   return "base:aspect._.elona.IItemBookOfRachel.action_name"
end

function IItemBookOfRachel:on_read(item, params)
   -- >>>>>>>> shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBookOfRachel: txt lang( ...
   Gui.play_sound("base.book1")
   Gui.mes("action.read.book.book_of_rachel")
   return "turn_end"
   -- <<<<<<<< shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBookOfRachel: txt lang( ..
end

function IItemBookOfRachel:localize_extra(s, item)
   return I18N.get("base:aspect._.elona.IItemBookOfRachel.title", s, self:calc(item, "book_number"))
end

return IItemBookOfRachel
