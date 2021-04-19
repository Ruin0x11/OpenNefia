local IAspect = require("api.IAspect")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local IItemReadable = require("mod.elona.api.aspect.IItemReadable")
local I18N = require("api.I18N")
local Enum = require("api.Enum")
local Effect = require("mod.elona.api.Effect")
local BookMenu = require("api.gui.menu.BookMenu")

local IItemBook = class.interface("IItemBook",
                                  {
                                     book_id = "string"
                                  },
                                  {
                                     IAspect,
                                     IItemReadable,
                                     IItemLocalizableExtra
                                  })

IItemBook.default_impl = "mod.elona.api.aspect.ItemBookAspect"

function IItemBook:localize_action()
   return "base:aspect._.elona.IItemBook.action_name"
end

function IItemBook:on_read(item, params)
   -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
   Effect.identify_item(item, Enum.IdentifyState.Name)
   local text = I18N.localize("elona.book", self:calc(item, "book_id"), "text")
   BookMenu:new(text, true):query()

   return "player_turn_query"
   -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
end

function IItemBook:localize_extra(s, item)
   if item:calc("identify_state") >= Enum.IdentifyState.Name then
      local book_title = I18N.localize("elona.book", self:calc(item, "book_id"), "title")
      return I18N.get("base:aspect._.elona.IItemBook.title", s, book_title)
   end
end

return IItemBook
