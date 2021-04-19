local IItemBookOfRachel = require("mod.elona.api.aspect.IItemBookOfRachel")
local Rand = require("api.Rand")

local ItemBookOfRachelAspect = class.class("ItemBookOfRachelAspect", { IItemBookOfRachel })

function ItemBookOfRachelAspect:init(item, params)
   -- >>>>>>>> shade2/item.hsp:618 	if iId(ci)=idBookOfRachel	:if iBookOfRachelId(ci)=0:iBookOfRachelId(ci)=i ..
   self.book_number = params.book_number or Rand.rnd(4) + 1
   -- <<<<<<<< shade2/item.hsp:618 	if iId(ci)=idBookOfRachel	:if iBookOfRachelId(ci)=0:iBookOfRachelId(ci)=i ..
end

return ItemBookOfRachelAspect
