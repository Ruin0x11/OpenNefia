local IItemPotion = require("mod.elona.api.aspect.IItemPotion")
local IItemDippable = require("mod.elona.api.aspect.IItemDippable")
local IItemWell = require("mod.elona.api.aspect.IItemWell")
local Gui = require("api.Gui")

local ItemPotionAspect = class.class("ItemPotionAspect", { IItemPotion, IItemDippable })

function ItemPotionAspect:init(item, params)
   self.effects = params.effects or {}
end

function ItemPotionAspect:can_dip_into(item, target_item)
   return target_item:get_aspect(IItemWell)
end

function ItemPotionAspect:can_draw_from_well(item, well)
   return item._id == "elona.empty_bottle"
end

function ItemPotionAspect:on_dip_into(item, params)
   -- >>>>>>>> shade2/action.hsp:1609 	if iType(ciDip)=fltPotion:if iTypeMinor(ci)=fltWe ...
   local target_item = params.target_item
   local well = target_item:get_aspect(IItemWell)
   if well then
      Gui.play_sound("base.drink1", params.chara.x, params.chara.y)
      target_item = target_item:separate()
      item:remove(1)

      if self:can_draw_from_well(item, target_item) then
         return well:draw_water_from(target_item, item, params)
      else
         return well:pour_water_into(target_item, item, params)
      end
   end

   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:1635 		}	 ..
end

return ItemPotionAspect
