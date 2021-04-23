local IAspect = require("api.IAspect")
local IItemDrinkable = require("mod.elona.api.aspect.IItemDrinkable")
local Gui = require("api.Gui")

local IItemWell = class.interface("IItemWell",
                                  {
                                     draw_water_from = "function",
                                     pour_water_into = "function",
                                     is_dry = "function",
                                     on_drink_effects = "function",
                                     decrement_water = "function",
                                     ai_drinks_from = "function",
                                     water_amount = "number"
                                  },
                                  { IAspect, IItemDrinkable })

IItemWell.default_impl = "mod.elona.api.aspect.ItemWellAspect"

function IItemWell:localize_action()
   return "base:aspect._.elona.IItemWell.action_name"
end

function IItemWell:on_drink(item, params)
   -- >>>>>>>> shade2/proc.hsp:1453 		iParam1(ci)-=rnd(3):iParam3(ci)+=rnd(3) ...
   if self:is_dry(item) then
      Gui.mes("action.drink.well.is_dry", item:build_name())
      return false
   end

   Gui.play_sound("base.drink1")

   self:on_drink_effects(item, params)
   self:decrement_water(item, params)

   return true
   -- <<<<<<<< shade2/proc.hsp:1458 		} ..
end

return IItemWell
