local IFactioned = require("api.IFactioned")

local ICharaAi = class.interface("ICharaAi", {}, { IFactioned })

--- Resets the AI state of this character.
function ICharaAi:reset_ai()
   self.target = nil
   self.aggro = 0

   self.ai_state = {
      item_to_use = nil,
      wants_movement = 0,
      last_target_x = 0,
      last_target_y = 0,
      anchor_x = nil,
      anchor_y = nil,
      is_anchored = false,
   }

   self:reset_all_relations()
end

function ICharaAi:set_aggro(target, amount)
   assert(target == nil or (type(target) == "table" and target._type == "base.chara"))
   self.aggro = math.max(amount, 0)
end

function ICharaAi:get_aggro(target)
   return self.aggro
end

function ICharaAi:reset_aggro(target)
   self.aggro = 0
end

--- Sets or clears the AI target of this character.
---
--- @tparam[opt] IChara target
function ICharaAi:set_target(target, aggro)
   if target == nil then
      self.target = nil
      self.aggro = 0
   else
      assert(type(target) == "table" and target._type == "base.chara")
      self.target = target.uid
   end
   if aggro then
      self:set_aggro(target, aggro)
   end
end

--- @treturn[opt]  Chara
function ICharaAi:get_target()
   if self.target == nil then
      return nil
   end
   local map = self:current_map()
   return map:get_object_of_type("base.chara", self.target)
end

return ICharaAi
