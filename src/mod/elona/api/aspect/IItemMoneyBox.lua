local IAspect = require("api.IAspect")
local IItemLocalizableExtra = require("mod.elona.api.aspect.IItemLocalizableExtra")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local IItemThrowable = require("mod.elona.api.aspect.IItemThrowable")
local Item = require("api.Item")

local IItemMoneyBox = class.interface("IItemMoneyBox", {
                                          gold_deposited = "number",
                                          gold_increment = "number",
                                          gold_limit = "number"
                                                         },
                                       {
                                          IAspect,
                                          IItemUseable,
                                          IItemThrowable,
                                          IItemLocalizableExtra
                                       })

IItemMoneyBox.default_impl = "mod.elona.api.aspect.ItemMoneyBoxAspect"

-- >>>>>>>> shade2/item.hsp:69 	moneyBox =500,2000,10000,50000,500000,5000000,100 ..
IItemMoneyBox.BANK_INCREMENTS = { 500, 2000, 10000, 50000, 500000, 5000000, 100000000 }
-- <<<<<<<< shade2/item.hsp:69 	moneyBox =500,2000,10000,50000,500000,5000000,100 ..

function IItemMoneyBox:localize_action()
   return "base:aspect._.elona.IItemMoneyBox.action_name"
end

function IItemMoneyBox:on_init_params(item)
   local idx = nil
   for i, inc in ipairs(IItemMoneyBox.BANK_INCREMENTS) do
      if self.gold_increment <= inc then
         idx = i
         break
      end
   end
   idx = idx or #IItemMoneyBox.BANK_INCREMENTS
   item.value = 2000 + idx * idx + idx * 100
end

function IItemMoneyBox:localize_extra(s, item)
   local increment = I18N.get("base:aspect._.elona.IItemMoneyBox.increments._" .. self:calc(item, "gold_increment"))
   return I18N.get("base:aspect._.elona.IItemMoneyBox.amount", s, increment)
end

function IItemMoneyBox:deposit_gold(item, chara, amount)
   -- >>>>>>>> shade2/action.hsp:1950 	snd sePayGold : cGold(pc)-=moneyBox(iParam2(ci))  ...
   amount = math.min(amount, chara.gold)
   chara.gold = chara.gold - amount
   self.gold_deposited = self.gold_deposited + amount
   if amount > 0 then
      item.weight = item.weight + 100
   end
   -- <<<<<<<< shade2/action.hsp:1950 	snd sePayGold : cGold(pc)-=moneyBox(iParam2(ci))  ..
end

function IItemMoneyBox:on_thrown(item, params)
   -- >>>>>>>> shade2/action.hsp:118 	if sync(tlocX,tlocY) : txt lang("それは地面に落ちて砕けた。"," ...
   Gui.mes("action.throw.shatters")
   Gui.play_sound("base.crush2", params.x, params.y)
   local map = params.chara:current_map()
   if map and self.gold_deposited > 0 then
      Item.create("elona.gold_piece", params.x, params.y, {amount=self.gold_deposited}, map)
   end
   return true
   -- <<<<<<<< shade2/action.hsp:119 	if iId(ci)=idMoneyBox : flt:item_create -1,idGold ..
end

function IItemMoneyBox:on_use(item, params)
   -- >>>>>>>> shade2/action.hsp:1946 	case effMoneyBox ...
   local increment = self:calc(item, "gold_increment")
   if increment > params.chara.gold then
      Gui.mes("action.use.money_box.not_enough_gold")
      return "player_turn_query"
   end

   local limit = self:calc(item, "gold_limit")
   if self.gold_deposited > limit then
      Gui.mes("action.use.money_box.full")
      return "player_turn_query"
   end

   local sep = item:separate()
   local aspect = sep:get_aspect(IItemMoneyBox)
   Gui.play_sound("base.paygold1", params.chara.x, params.chara.y)
   aspect:deposit_gold(item, params.chara, increment)

   return "player_turn_query"
   -- <<<<<<<< shade2/action.hsp:1951 	swbreak ..
end

return IItemMoneyBox
