local IItemBlacksmithHammer = require("mod.smithing.api.aspect.IItemBlacksmithHammer")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local IEvented = require("mod.elona.api.aspect.IEvented")
local Enum = require("api.Enum")
local Smithing = require("mod.smithing.api.Smithing")
local Gui = require("api.Gui")

local ItemBlacksmithHammerAspect = class.class("ItemBlacksmithHammerAspect", { IItemBlacksmithHammer, IItemUseable, IEvented })

function ItemBlacksmithHammerAspect:init(item, params)
   self.hammer_level = math.max(params.hammer_level or 1, 1)
   self.hammer_experience = math.max(params.hammer_experience or 0, 0)
   self.total_uses = math.max(params.total_uses or 0, 0)
end

function ItemBlacksmithHammerAspect:can_upgrade(item)
   return self.hammer_level >= Smithing.calc_required_hammer_levels_to_next_bonus(item.bonus)
end

function ItemBlacksmithHammerAspect:calc_required_exp(item)
   return Smithing.calc_hammer_required_exp(self.hammer_level)
end

function ItemBlacksmithHammerAspect:gain_level(item)
   self.hammer_level = self.hammer_level + 1
   self.hammer_experience = 0
   self.total_uses = 0
end

function ItemBlacksmithHammerAspect:upgrade(item)
   item.bonus = item.bonus + 1
   self.hammer_level = 1
   self.hammer_experience = 0
   self.total_uses = 0
end

function ItemBlacksmithHammerAspect:calc_equipment_upgrade_power(hammer, target)
   local hammer_level = self:calc(hammer, "hammer_level")
   local power = math.min(math.floor(hammer_level * 9 / 20), 900)
   if hammer_level >= 2000 then
      power = power + 50
   end
   if hammer.bonus > 0 then
      power = power + 50
   end
   return power
end

function ItemBlacksmithHammerAspect:calc_item_generation_seed(item)
   return Smithing.calc_item_generation_seed(item)
end

function ItemBlacksmithHammerAspect:on_use(item, params)
   if not params.chara:is_player() then
      Gui.mes("common.nothing_happens")
      return false
   end
   Smithing.on_use_blacksmith_hammer(item, params.chara)
end

function ItemBlacksmithHammerAspect:get_events(obj)
   return {
      {
         id = "base.on_item_build_description",
         name = "Add hammer information",

         callback = function(item, params, result)
            if item:calc("identify_state") >= Enum.IdentifyState.Quality then
               local aspect = item:get_aspect(IItemBlacksmithHammer)
               local exp_perc = aspect:exp_percent(item)
               exp_perc = ("%3.6f"):format(exp_perc):sub(1, 6)
               local text = ("[Lv: %d Exp: %s%%]"):format(aspect:calc(item, "hammer_level"), string.right_pad(tostring(exp_perc), 6))
               table.insert(result, { text = text, icon = 7 })
            end
         end
      }
   }
end

return ItemBlacksmithHammerAspect
