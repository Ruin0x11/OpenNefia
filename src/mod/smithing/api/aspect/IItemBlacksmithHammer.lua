local IAspect = require("api.IAspect")
local IItemUseable = require("mod.elona.api.aspect.IItemUseable")
local IEvented = require("mod.elona.api.aspect.IEvented")
local SmithingFormula = require("mod.smithing.api.SmithingFormula")
local Gui = require("api.Gui")
local Enum = require("api.Enum")
local Calc = require("mod.elona.api.Calc")
local I18N = require("api.I18N")

local IItemBlacksmithHammer = class.interface("IItemBlacksmithHammer",
                                  {
                                     hammer_level = "number",
                                     hammer_experience = "number",
                                     total_uses = "number",
                                  },
                                  { IAspect, IItemUseable, IEvented })

IItemBlacksmithHammer.default_impl = "mod.smithing.api.aspect.ItemBlacksmithHammerAspect"


function IItemBlacksmithHammer:localize_action()
   return "base:aspect._.elona.IItemBlacksmithHammer.action_name"
end

function IItemBlacksmithHammer:calc_required_levels_to_next_bonus(hammer)
   local bonus = hammer
   if type(hammer) == "table" then
      bonus = hammer.bonus
   end
   return 2000 * (bonus + 1)
end

function IItemBlacksmithHammer:can_upgrade(item)
   return self.hammer_level >= self:calc_required_levels_to_next_bonus(item)
end

function IItemBlacksmithHammer:calc_required_exp(item)
   return Calc.calc_living_weapon_required_exp(self.hammer_level)
end

-- >>>>>>>> oomSEST/src/southtyris.hsp:104907 #deffunc modexpsmith int __fff, int __ggg ..
function IItemBlacksmithHammer:gain_experience(hammer, amount)
   amount = math.floor(amount)

   local level = self.hammer_level
   local cur_exp = self.hammer_experience
   local req_exp = self:calc_required_exp(hammer)

   if self:can_upgrade(hammer) then
      self.hammer_experience = (cur_exp + amount) % req_exp
      return false
   end

   if level <= self:calc_required_levels_to_next_bonus(hammer.bonus-1) then
      amount = amount * 100 * hammer.bonus
   end

   if cur_exp < req_exp then
      cur_exp = math.max(cur_exp, 0)
      self.hammer_experience = cur_exp + amount
   end

   if self.hammer_experience >= req_exp then
      self:gain_level(hammer)
      Gui.play_sound("base.ding3")
      Gui.mes_c("smithing.blacksmith_hammer.skill_increases", "Green")
   end

   local exp_perc = self:exp_percent(hammer)
   exp_perc = ("%3.6f"):format(exp_perc):sub(1, 6)
   Gui.mes(("%s(Lv: %d Exp:%s%%)"):format(I18N.space(), self.hammer_level, string.right_pad(tostring(exp_perc), 6)))

   return true
end
-- <<<<<<<< oomSEST/src/southtyris.hsp:104931 	return 1 ..

function IItemBlacksmithHammer:gain_level(item)
   self.hammer_level = self.hammer_level + 1
   self.hammer_experience = 0
   self.total_uses = 0
end

function IItemBlacksmithHammer:upgrade(item)
   item.bonus = item.bonus + 1
   self.hammer_level = 1
   self.hammer_experience = 0
   self.total_uses = 0
end

function IItemBlacksmithHammer:calc_equipment_upgrade_power(hammer, target)
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

function IItemBlacksmithHammer:calc_item_generation_seed(item)
   return self.hammer_level * 1000000 + self.hammer_experience
end

function IItemBlacksmithHammer:exp_percent(item)
   return (self.hammer_experience * 100.0) / self:calc_required_exp(item)
end

function IItemBlacksmithHammer:on_use(item, params)
   if not params.chara:is_player() then
      Gui.mes("common.nothing_happens")
      return false
   end

   local Smithing = require("mod.smithing.api.Smithing")
   Smithing.on_use_blacksmith_hammer(item, params.chara)
end

function IItemBlacksmithHammer:get_events(obj)
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

return IItemBlacksmithHammer
