local IItemMoneyBox = require("mod.elona.api.aspect.IItemMoneyBox")
local Rand = require("api.Rand")

local ItemMoneyBoxAspect = class.class("ItemMoneyBoxAspect", { IItemMoneyBox })

function ItemMoneyBoxAspect:init(item, params)
   -- >>>>>>>> shade2/item.hsp:661 	if iId(ci)=idMoneyBox{ ..
   self.gold_deposited = 0
   self.gold_increment = params.gold_increment or IItemMoneyBox.BANK_INCREMENTS[Rand.rnd(Rand.rnd(#IItemMoneyBox.BANK_INCREMENTS) + 1) + 1]
   self.gold_limit = params.gold_limit or 1000000000
   -- <<<<<<<< shade2/item.hsp:664 		} ..
end

return ItemMoneyBoxAspect
