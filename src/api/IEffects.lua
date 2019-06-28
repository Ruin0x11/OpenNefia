local IObject = require("api.IObject")

local IEffects = interface("IEffects", {}, IObject)

function IEffects:init()
   self.effects = {}
   self.effect_order = {}
   self.effect_index = 1
end

function IEffects:on_refresh()
   self:apply_effects()
end

function IEffects:apply_effects()
   -- TODO: bad. this will not allow configuration of effect
   -- application order.
   for _, idx in ipairs(self.effect_order) do
      local effect = self.effects[idx]
      assert(effect)

      effect:on_apply(self)

      assert(effect ~= self)
      local method = effect:calc("method")
      for k, v in pairs(effect:calc("delta")) do
         self:mod(k, v, method)
      end
   end
end

function IEffects:add_effect(effect)
   local idx = self.effect_index
   self.effects[idx] = effect
   table.insert(self.effect_order, idx)
   self.effect_index = idx + 1
   effect:on_add(self)
   effect:refresh()

   return idx
end

function IEffects:remove_effect(effect_index)
   local effect = self.effects[effect_index]
   if effect then
      table.iremove_value(self.effect_order, effect_index)
      effect:on_remove(self)
      self.effects[effect_index] = nil
   end
end

return IEffects
