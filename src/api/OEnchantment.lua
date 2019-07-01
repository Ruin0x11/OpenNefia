local IEffects = require("api.IEffects")
local IObject = require("api.IObject")
local Object = require("api.Object")

local OEnchantment = class.interface("OEnchantment", {}, IObject)

OEnchantment._type = "base.enchantment"

function OEnchantment:create(proto, params)
   return Object.generate_from(proto, OEnchantment, params)
end

function OEnchantment:build()
   IObject.init(self)

   self.orientation = self.orientation or "neutral"
end

function OEnchantment:refresh()
   IObject.on_refresh(self)

   self:on_refresh()
end

--
-- Prototypes
--

function OEnchantment:on_add(obj)
end

function OEnchantment:on_remove(obj)
end

function OEnchantment:on_refresh()
end

function OEnchantment:on_apply(obj)
end

function OEnchantment:when_wielding(obj)
end

function OEnchantment:can_merge(other)
   return false
end

function OEnchantment:on_merge(other)
end

return OEnchantment
