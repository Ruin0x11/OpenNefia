local IItemWell = require("mod.elona.api.aspect.IItemWell")
local Gui = require("api.Gui")
local Itemgen = require("mod.elona.api.Itemgen")
local ItemFunction = require("mod.elona.api.ItemFunction")
local Rand = require("api.Rand")

local ItemWellAspect = class.class("ItemWellAspect", { IItemWell })

function ItemWellAspect:init(item, params)
   self.water_amount = params.water_amount or 0
   self.dryness_amount = params.dryness_amount or 0
end

function ItemWellAspect:is_dry(item)
   return self.water_amount < -5 or self.dryness_amount >= 20
end

function ItemWellAspect:on_drink_effects(item, params)
   local chara = params.chara

   if ItemFunction.proc_fall_into_well(item, chara) then
      return
   end
   ItemFunction.drink_from_well(item, chara)

   if chara:is_player() then
      chara.nutrition = chara.nutrition + 500
   else
      chara.nutrition = chara.nutrition + 400
   end
end

function ItemWellAspect:decrement_water(item)
   self.water_amount = self.water_amount - self:calc_draw_water_amount()
   self.dryness_amount = self.dryness_amount + self:calc_draw_water_amount()

   if self.dryness_amount >= 20 then
      Gui.mes("action.drink.well.completely_dried_up", item:build_name())
      return true
   end

   if self.water_amount <= -5 then
      Gui.mes("action.drink.well.dried_up", item:build_name())
   end
end

function ItemWellAspect:pour_water_into(well, potion, params)
   -- >>>>>>>> shade2/action.hsp:1612 			txt lang(itemName(ciDip,1)+"を"+itemName(ci)+"に浸 ...
   Gui.mes("action.dip.execute", potion:build_name(1), well:build_name())

   if self.dryness_amount >= 30 then
      Gui.mes("action.dip.result.well_dry", well:build_name())
      return "turn_end"
   end

   Gui.mes("action.dip.result.well_refilled", well:build_name())

   local amount = Rand.rnd(3)
   amount = math.floor(amount)
   if amount ~= 0 then
      self.water_amount = self.water_amount + amount
   end

   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:1621 			goto *turn_end ..
end

function ItemWellAspect:calc_draw_water_amount()
   return 3
end

function ItemWellAspect:draw_water_from(well, potion, params)
   -- >>>>>>>> shade2/action.hsp:1623 			if (iParam1(ci)<-5) or (iParam3(ci)>=20) or ( ( ...
   if self:is_dry(well) then
      Gui.mes("action.dip.result.natural_potion_dry", well:build_name())
      Gui.mes("action.dip.result.natural_potion_drop", potion:build_name(1))
      return "turn_end"
   end

   self.water_amount = self.water_amount - self:calc_draw_water_amount()
   local item = Itemgen.create(nil, nil, {level = 20, categories = "elona.drink"}, params.chara)

   Gui.mes("action.dip.result.natural_potion", well:build_name(), potion:build_name(1))
   Gui.mes("action.dip.you_get", item:build_name(1))
   item:stack(true)

   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:1633 			goto *turn_end ..
end

function ItemWellAspect:ai_drinks_from(item)
   return true
end

return ItemWellAspect
