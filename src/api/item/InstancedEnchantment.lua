local I18N = require("api.I18N")
local data = require("internal.data")
local InstancedEnchantment = class.class("InstancedEnchantment")

local SOURCES = table.set { "item", "material", "generated", "ego", "ego_minor", "special" }

function InstancedEnchantment:init(_id, power, params, curse_power, source)
   assert(type(power) == "number", "Enchantment power must be number")
   assert(params == "randomized" or type(params) == "table", "Params must be 'randomized' or table")
   curse_power = curse_power or 0
   assert(type(curse_power) == "number", "Curse power must be number")
   source = source or "generated"
   assert(SOURCES[source], "Must include source")
   self._id = _id
   self.power = power

   self.proto = data["base.enchantment"]:ensure(_id)
   self.source = source

   -- NOTE: unused in vanilla
   self.is_inheritable = true

   if params == "randomized" then
      self.params = {}
      self:on_generate(self, {curse_power=curse_power})
   else
      self.params = params
   end
   self:on_initialize(self, {curse_power=curse_power})
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

function InstancedEnchantment:on_initialize(item, params)
   if self.proto.on_initialize then
      return self.proto.on_initialize(self, item, params)
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

function InstancedEnchantment:compare_params(other_params)
   local cmp = table.deepcompare
   if self.proto.compare then
      cmp = self.proto.compare
   end

   return not not cmp(self.params, other_params)
end

function InstancedEnchantment:is_same_as(other)
   if self.proto._id ~= other.proto._id then
      return false
   end

   return self:compare_params(other.params)
end

function InstancedEnchantment:can_merge_with(other)
   if self.proto.no_merge then
      return false
   end

   return self:is_same_as(other)
end

function InstancedEnchantment:__lt(other)
   -- >>>>>>>> shade2/item_data.hsp:496 	#deffunc sortEnc int id ...
   local my_ordering = self.ordering or (self.proto.elona_id and self.proto.elona_id * 10000) or 0
   local their_ordering = other.ordering or (other.proto.elona_id and other.proto.elona_id * 10000) or 0
   return my_ordering < their_ordering
   -- <<<<<<<< shade2/item_data.hsp:513 	#global  ..
end

return InstancedEnchantment
