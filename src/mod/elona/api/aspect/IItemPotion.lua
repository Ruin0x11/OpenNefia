local IAspect = require("api.IAspect")
local IItemDrinkable = require("mod.elona.api.aspect.IItemDrinkable")
local Gui = require("api.Gui")
local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Const = require("api.Const")
local Rand = require("api.Rand")
local Hunger = require("mod.elona.api.Hunger")

local IItemPotion = class.interface("IItemPotion",
                                  {
                                     can_draw_from_well = "function",
                                     effects = "table"
                                  },
                                  { IAspect, IItemDrinkable })

IItemPotion.default_impl = "mod.elona.api.aspect.ItemPotionAspect"

function IItemPotion:localize_action()
   return "base:aspect._.elona.IItemPotion.action_name"
end

function IItemPotion:on_drink(item, params)
   local chara = params.chara

   if chara:is_in_fov() then
      Gui.play_sound("base.drink1", chara.x, chara.y)
      if (params.triggered_by or "potion") == "potion" then
         Gui.mes("action.drink.potion", chara, item:build_name(1))
      end
   end

   local did_something = false

   for _, effect in ipairs(self:calc(item, "effects")) do
      local effect_id = assert(effect._id)
      local power = effect.power or 100
      did_something = did_something or ElonaMagic.drink_potion(effect_id, power, item, params)
   end

   item.amount = item.amount - 1

   chara.nutrition = chara.nutrition + 150

   if chara:is_in_player_party() and chara.nutrition > Const.HUNGER_THRESHOLD_BLOATED and Rand.one_in(5) then
      Hunger.vomit(chara)
   end

   return "turn_end"
end

return IItemPotion
