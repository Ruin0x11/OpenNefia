local ICharaEquipStyle = require("api.chara.aspect.ICharaEquipStyle")

local CharaEquipStyleAspect = class.class("CharaEquipStyleAspect", ICharaEquipStyle)

function CharaEquipStyleAspect:init(item, params)
   self.is_wielding_shield = false
   self.is_wielding_two_handed = false
   self.is_dual_wielding = false
end

function CharaEquipStyleAspect:refresh_melee_equip_style(chara)
   local attack_count = 0
   for _, part in chara:iter_equipped_body_parts() do
      local item = assert(part.equipped)

      if part.body_part._id == "elona.hand" then
         attack_count = attack_count + 1
      end

      if item:has_category("elona.equip_shield") then
         self:mod(chara, "is_wielding_shield", true)
      end
   end

   -- >>>>>>>> shade2/calculation.hsp:530 	if cAttackStyle(r1)&styleShield{ ..
   if self:calc(chara, "is_wielding_shield") then
      local pv = chara:calc("pv")
      if pv > 0 then
         chara:mod("pv", pv * math.floor(120 + math.sqrt(chara:skill_level("elona.shield")) * 2) / 100)
      end
   else
      if attack_count == 1 then
         self:mod(chara, "is_wielding_two_handed", true)
      elseif attack_count > 0 then
         self:mod(chara, "is_dual_wielding", true)
      end
   end
   -- <<<<<<<< shade2/calculation.hsp:534 		} ..
end

return CharaEquipStyleAspect
