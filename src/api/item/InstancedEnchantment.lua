local I18N = require("api.I18N")
local data = require("internal.data")
local InstancedEnchantment = class.class("InstancedEnchantment")

local SOURCES = table.set { "item", "material", "generated" }

function InstancedEnchantment:init(_id, power, params, source)
   assert(type(power) == "number", "Enchantment power must be number")
   assert(SOURCES[source], "Must include source")
   self._id = _id
   self.power = power
   self.params = params or {}
   self.proto = data["base.enchantment"]:ensure(_id)
   self.source = source
   self.is_temporary = false

   -- NOTE: unused in vanilla
   self.is_inheritable = true
end

function InstancedEnchantment:serialize()
   self.proto = nil
end

function InstancedEnchantment:deserialize()
   self.proto = data["base.enchantment"]:ensure(self._id)
end

function InstancedEnchantment:on_generate(item, params)
   if self.proto.on_generate then
      return self.proto.on_generate(self, item, params)
   end
end

function InstancedEnchantment:on_refresh(item, chara)
   if self.proto.on_refresh then
      return self.proto.on_refresh(self, item, chara)
   end
end

function InstancedEnchantment:on_attack_hit(chara, params)
   if self.proto.on_attack_hit then
      return self.proto.on_attack_hit(self, chara, params)
   end
end

function InstancedEnchantment:on_turns_passed(item, chara)
   if self.proto.on_turns_passed then
      return self.proto.on_turns_passed(self, item, chara)
   end
end

function InstancedEnchantment:alignment()
   if type(self.proto.alignment) == "function" then
      return self.proto.alignment(self)
   end

   return self.proto.alignment or "positive"
end

function InstancedEnchantment:adjusted_power()
   if self.proto.adjusted_power then
      return self.proto.adjusted_power(self)
   end

   return self.power
end

function InstancedEnchantment:localize(item)
   if self.proto.localize then
      return self.proto.localize(self, item)
   end

   return I18N.get("_.base.enchantment." .. self._id .. ".description")
end

return InstancedEnchantment
