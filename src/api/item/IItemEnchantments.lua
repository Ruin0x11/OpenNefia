local IObject = require("api.IObject")
local data = require("internal.data")
local Const = require("api.Const")

local IItemEnchantments = class.interface("IItemEnchantments", {}, IObject)

function IItemEnchantments:init()
   self.enchantments = {}
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
   local enc_data = data["base.enchantment"]:ensure(enc._id)
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

   self.enchantments[idx] = enc

   local adjusted_value = math.floor(self.value * enc_data.value / 100)
   if adjusted_value > 0 then
      self.value = adjusted_value
   end

   table.insertion_sort(self.enchantments, sort_enchantments)

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

   if idx then
      table.remove(self.enchantments, idx)
   end

   table.insertion_sort(self.enchantments, sort_enchantments)

   self:refresh()
   -- <<<<<<<< shade2/item_data.hsp:536 	return ..
end

local function add_fixed_enchantment(item, fixed_enc)
   data["base.enchantment"]:ensure(fixed_enc._id)

   local enc = {
      _id = fixed_enc._id,
      power = fixed_enc.power,
      params = table.deepcopy(fixed_enc.params or {}),
   }

   table.insert(item.temp["enchantments"], enc)
end

local function refresh_temporary_enchantments(item)
   item.temp["enchantments"] = table.deepcopy(item.enchantments)

   if item.proto.fixed_enchantments then
      for _, fixed_enc in ipairs(item.proto.fixed_enchantments) do
         add_fixed_enchantment(item, fixed_enc)
      end
   end

   local material = item:calc("material")
   local material_data = data["base.material"]:ensure(material)
   if material_data.fixed_enchantments then
      for _, fixed_enc in ipairs(material_data.fixed_enchantments) do
         add_fixed_enchantment(item, fixed_enc)
      end
   end

   table.insertion_sort(item.temp["enchantments"], sort_enchantments)
end

function IItemEnchantments:get_enchantment(_id)
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
