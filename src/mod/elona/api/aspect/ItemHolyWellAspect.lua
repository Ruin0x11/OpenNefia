local Gui = require("api.Gui")
local ItemFunction = require("mod.elona.api.ItemFunction")
local Rand = require("api.Rand")
local Magic = require("mod.elona_sys.api.Magic")
local Item = require("api.Item")
local Enum = require("api.Enum")
local IItemWell = require("mod.elona.api.aspect.IItemWell")

local ItemHolyWellAspect = class.class("ItemHolyWellAspect", { IItemWell })

function ItemHolyWellAspect:init(item, params)
   self.water_amount = params.water_amount or 0
end

function ItemHolyWellAspect:is_dry()
   return save.elona.holy_well_count <= 0
end

function ItemHolyWellAspect:on_drink_effects(item, params)
   local chara = params.chara

   if ItemFunction.proc_fall_into_well(item, chara) then
      return
   end
   if Rand.one_in(2) then
      Magic.cast("elona.effect_gain_potential", { target = chara })
   end

   if chara:is_player() then
      chara.nutrition = chara.nutrition + 500
   else
      chara.nutrition = chara.nutrition + 400
   end
end

function ItemHolyWellAspect:decrement_water(item)
   -- >>>>>>>> shade2/proc.hsp:1451 		flagHolyWell-- ...
   save.elona.holy_well_count = save.elona.holy_well_count - self:calc_draw_water_amount()
   -- <<<<<<<< shade2/proc.hsp:1451 		flagHolyWell-- ..
end

function ItemHolyWellAspect:pour_water_into(well, potion, params)
   -- >>>>>>>> shade2/action.hsp:1612 			txt lang(itemName(ciDip,1)+"を"+itemName(ci)+"に浸 ...
   Gui.mes("action.dip.execute", potion:build_name(1), well:build_name())

   Gui.mes("action.dip.result.holy_well_polluted")

   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:1621 			goto *turn_end ..
end

function ItemHolyWellAspect:calc_draw_water_amount()
   return 1
end

function ItemHolyWellAspect:draw_water_from(well, potion, params)
   -- >>>>>>>> shade2/action.hsp:1623 			if (iParam1(ci)<-5) or (iParam3(ci)>=20) or ( ( ...
   if self:is_dry(well) then
      Gui.mes("action.dip.result.natural_potion_dry", well:build_name())
      Gui.mes("action.dip.result.natural_potion_drop", potion:build_name(1))
      return "turn_end"
   end

   save.elona.holy_well_count = save.elona.holy_well_count - self:calc_draw_water_amount()
   local item = Item.create("elona.water", nil, nil, {}, params.chara)
   if item ~= nil then
      -- TODO pass curse state to item creation events
      item.curse_state = Enum.CurseState.Blessed
   end

   Gui.mes("action.dip.result.natural_potion", well:build_name(), potion:build_name(1))
   Gui.mes("action.dip.you_get", item:build_name(1))
   item:stack(true)

   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:1633 			goto *turn_end ..
end

function ItemHolyWellAspect:ai_drinks_from(item)
   return false
end

return ItemHolyWellAspect
