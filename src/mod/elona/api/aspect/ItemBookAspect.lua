local IItemBook = require("mod.elona.api.aspect.IItemBook")
local Rand = require("api.Rand")

local ItemBookAspect = class.class("ItemBookAspect", { IItemBook })

function ItemBookAspect:init(item, params)
   -- >>>>>>>> shade2/item.hsp:618 	if iId(ci)=idBook	:if iBookId(ci)=0:iBookId(ci)=i ..
   if params.book_id then
      self.book_id = params.book_id
   else
      local cands = data["elona.book"]:iter()
         :filter(function(book) return not book.no_generate end)
         :extract("_id")
         :to_list()
      self.book_id = Rand.choice(cands)
   end
   -- <<<<<<<< shade2/item.hsp:618 	if iId(ci)=idBook	:if iBookId(ci)=0:iBookId(ci)=i ..
end

return ItemBookAspect
