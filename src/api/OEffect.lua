local IEffects = require("api.IEffects")
local IObject = require("api.IObject")

local OEffect = class.interface("OEffect", {}, {IObject, IEffects})

OEffect._type = "base.effect"

function OEffect:build()
   IObject.init(self)
   IEffects.init(self)

   self.delta = self.delta or {}
   self.orientation = self.orientation or "neutral"
end

function OEffect:refresh()
   IObject.on_refresh(self)
   IEffects.on_refresh(self)
   self:on_refresh()
end

function OEffect:on_add(obj)
end

function OEffect:on_remove(obj)
   if self.proto.on_remove then
      self.proto.on_remove(self, obj)
   end
end

function OEffect:on_refresh()
end

function OEffect:on_apply(obj)
end

function OEffect:can_merge(other)
   return false
end

function OEffect:on_merge(other)
end

return OEffect
