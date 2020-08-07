local IObject = require("api.IObject")
local data = require("internal.data")
local Const = require("api.Const")
local InstancedEnchantment = require("api.item.InstancedEnchantment")

local IItemEnchantments = class.interface("IItemEnchantments", {}, IObject)

function IItemEnchantments:init()
   self.enchantments = {}

   self:rebuild_enchantments_from_proto()
end

local function sort_enchantments(a, b)
   -- >>>>>>>> shade2/item_data.hsp:496 	#deffunc sortEnc int id ..
   local enc_data_a = data["base.enchantment"]:ensure(a._id)
   local enc_data_b = data["base.enchantment"]:ensure(b._id)

   -- TODO ordering
   local ord_a = enc_data_a.elona_id or 0
   local ord_b = enc_data_b.elona_id or 0

   return ord_a < ord_b
   -- <<<<<<<< shade2/item_data.hsp:510 	return ..
end

function IItemEnchantments:add_enchantment(enc)
   -- >>>>>>>> shade2/item_data.hsp:603  ..
   assert(class.is_an(InstancedEnchantment, enc))
   assert(type(enc.power) == "number")

   local idx
   for i, v in ipairs(self.enchantments) do
      if v._id == enc._id then
         idx = i
      end
   end

   if idx == nil then
      if #self.enchantments >= Const.MAX_ENCHANTMENTS then
         return false
      end

      idx = #self.enchantments + 1
   end

   if self.enchantments[idx] then
      enc.power = enc.power + self.enchantments[idx].power
   end

   enc.is_temporary = false
   self.enchantments[idx] = enc

   local adjusted_value = math.floor(self.value * enc.proto.value / 100)
   if adjusted_value > 0 then
      self.value = adjusted_value
   end

   table.insertion_sort(self.enchantments, sort_enchantments)

   self:emit("base.on_item_add_enchantment", {index=idx, enchantment=enc})
   self:refresh()

   return true
   -- <<<<<<<< shade2/item_data.hsp:627 	return true ..
end

function IItemEnchantments:remove_enchantment(_id, power)
   -- >>>>>>>> shade2/item_data.hsp:518 	#deffunc encRemove int id,int EncOrg,int encPorg ..
   local idx = nil

   for i, enc in ipairs(self.enchantments) do
      if enc._id == _id then
         enc.power = enc.power - power
         if enc.power <= 0 then
            idx = i
         end
         break
      end
   end

   local enc
   if idx then
      enc = table.remove(self.enchantments, idx)
   end

   if enc then
      table.insertion_sort(self.enchantments, sort_enchantments)
      self:emit("base.on_item_remove_enchantment", {index=idx, enchantment=enc})
      self:refresh()
   end
   -- <<<<<<<< shade2/item_data.hsp:536 	return ..
end

-- NOTE: Only call this if the item's prototype has changed, to preserve the
-- state of things like ammo.
function IItemEnchantments:rebuild_enchantments_from_proto()
   local remove = {}
   for i, enc in ipairs(self.enchantments) do
      if enc.source == "item" then
         remove[#remove+1] = i
      end
   end
   table.remove_indices(self.enchantments, remove)

   for _, fixed_enc in ipairs(self.proto.enchantments or {}) do
      local enc = InstancedEnchantment:new(
         fixed_enc._id,
         fixed_enc.power,
         table.deepcopy(fixed_enc.params or {}),
         "item"
      )
      self:add_enchantment(enc)
   end
end

local function refresh_temporary_enchantments(item)
   -- Temporary enchantments will be references to their original copies in
   -- item.enchantments if available.
   item.temp["enchantments"] = table.shallow_copy(item.enchantments)

   table.insertion_sort(item.temp["enchantments"], sort_enchantments)
end

function IItemEnchantments:find_enchantment(_id)
   return self:iter_enchantments():filter(function(enc) return enc._id == _id end):nth(1)
end

function IItemEnchantments:on_refresh()
   refresh_temporary_enchantments(self)
end

function IItemEnchantments:iter_enchantments()
   if self.temp["enchantments"] == nil then
      self:refresh()
   end

   return fun.iter(self.temp["enchantments"])
end

return IItemEnchantments
