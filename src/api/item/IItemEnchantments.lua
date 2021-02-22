local IObject = require("api.IObject")
local Const = require("api.Const")
local InstancedEnchantment = require("api.item.InstancedEnchantment")

--- How enchantments work in vanilla:
---
--- - Each item has a list of enchantments, iEnc(enc_id, item_id). This is an
---   array of integers, one for each enchantment. The type and - parameters get
---   added together like: (type*10000+param). `param` is - something like a
---   skill or magic ID, which are integers in vanilla.
---
--- - Each item may only ever have one enchantment of a given type. If the item
---   already has an enchantment with the exact same ID *and* special parameters
---   (modified skill/attribute ID, etc.), then it is merged with the one that
---   exists already. If the enchantment to merge does not come from the item's
---   material, its power is halved. Ammo enchantments do not get merged.
---
--- - There are certain "special" enchantment types that correspond to another
---   enchantment type. For example, when an the enchantment of type
---   `encModAttb` gets added, a "modify attribute" enchantment of a random type
---   will get added instead.
---
--- - iAmmo(ci) holds the index into iEnc(enc_id, ci) for the item's current
---   ammo enchantment.
---
--- How enchantments work in OpenNefia:
---
--- - Enchantment ID and parameters are separate. ID is a string, parameters is
---   a table.
---
--- - Enchantments are never merged. Instead, you are able to iterate through
---   each unmerged enchantment and see the individual power contribution of
---   each. To get the combined total power for an enchantment ID, you call
---   IItemEnchantments:enchantment_power(_id). This is useful to, for example,
---   calculate an item's enchantment power excluding the power contributed by
---   the item's material (oomSEST's smithing mechanic does this in a hackish
---   way, checking the hardcoded list of enchantments of the item's material,
---   and subtracting the power of those from the power totals saved on the
---   item).
---
--- - To determine which enchantments are the same as one another for the
---   purpose of summing their power levels together, you can define a
---   ":compare()" callback on the "base.enchantment" data entry. Otherwise,
---   a `deepcompare` function is used.
---
--- - If an enchantment's parameters table is nil when the enchantment is
---   created, that means "generate a random version of this enchantment." If a
---   table of any kind is passed to :add_enchantment(id, power, params)
---   instead, then that params table will be used.
---
--- - It is possible to have temporary enchantments on items, which can be added
---   to after the item is refreshed. This is tracked by the temporary values
---   system (`IModdable`).
---
--- - iAmmo(ci) is now `ci.params.ammo_loaded`. This is a reference to an
---   InstancedEnchantment object in the item's enchantment list. See
---   ElonaCommand.ammo() for more information about how ammo enchantments work
---   with temporary enchantments.
---
local IItemEnchantments = class.interface("IItemEnchantments", {}, IObject)

function IItemEnchantments:init()
   self.enchantments = {}
   self._merged_enchantments = nil

   self:add_enchantments_from_proto()
end

function IItemEnchantments:__serialize()
   self._merged_enchantments = nil
end

function IItemEnchantments:mod_base_enchantment_power(enc, params, power_delta)
   assert(type(power_delta) == "number", "power delta must be number")

   if type(enc) == "string" then
      assert(type(params) == "table", "specify the enchantment ID with params to modify")

      local _id = enc
      -- We want to make sure we don't try to modify an enchantment that comes
      -- from the item or the material, as those can get overwritten.
      -- "generated" enchantments are always optionally created, so we can pick
      -- one and add the power delta there.
      enc = self:find_base_enchantment(_id, params, "generated")
      if enc == nil then
         -- For convenience, create a new enchantment. All we really want is the
         -- enchantment's power to increase by a set level, regardless of what's
         -- under the hood.
         local err
         enc, err = self:add_enchantment(_id, 0, params, 0, "generated")
         if not enc then
            return false, err
         end
      end
   else
      class.assert_is_an(InstancedEnchantment, enc)
   end

   local idx = table.index_of(self.enchantments, enc)
   if idx == nil then
      return false, "item does not have enchantment"
   end

   enc.power = math.floor(enc.power + power_delta)
   self._merged_enchantments = nil

   return true
end

--- For all enchantments in `iter`, sums the powers between the ones with
--- similar parameters.
---
--- `iter` should iterate in the order the enchantments were added. The first
--- enchantment in the iterator gets full power; the rest that get merged with
--- it will have half power (or full power if they're from the item's material).
---
--- @tparam Iterator(InstancedEnchantment) iter
--- @treturn {{_id=id:base.enchantment,proto=data:base.enchantment,params=table=total_power=number,is_inheritable=boolean},...}
function IItemEnchantments.calc_total_enchantment_powers(iter)
   local unique_encs_found = {}

   -- We don't have a Set class that can check equivalence with a custom
   -- comparator, so this will have to do...
   for _, enc in iter:unwrap() do
      local found = false
      for unique_enc, power in pairs(unique_encs_found) do
         if unique_enc:can_merge_with(enc) then
            -- >>>>>>>> shade2/item_data.hsp:613 		if mat:else:encP/=2 ...
            local merged_power = enc.power
            if enc.source ~= "material" then
               merged_power = math.floor(merged_power / 2)
            end
            -- <<<<<<<< shade2/item_data.hsp:613 		if mat:else:encP/=2 ..

            -- >>>>>>>> shade2/item_data.hsp:618 	if iEnc(i,id)=Enc{ ...
            unique_encs_found[unique_enc] = power + merged_power
            -- <<<<<<<< shade2/item_data.hsp:620 		} ..

            found = true
            break
         end
      end
      if not found then
         unique_encs_found[enc] = enc.power
      end
   end

   local result = {}

   local order = table.keys(unique_encs_found)
   table.sort(order, InstancedEnchantment.__lt)

   for _, enc in ipairs(order) do
      local power = unique_encs_found[enc]
      result[#result+1] = {
         _id = enc._id,
         proto = enc.proto,
         params = table.deepcopy(enc.params),
         total_power = power,
         is_inheritable = enc.is_inheritable
      }
   end

   return result
end

function IItemEnchantments:add_enchantment(enc, power, params, curse_power, source)
   -- >>>>>>>> shade2/item_data.hsp:603  ..
   if type(enc) == "string" then
      local _id = enc
      curse_power = curse_power or 0
      source = source or "generated"

      enc = InstancedEnchantment:new(_id, power, params, curse_power, source)
   else
      class.assert_is_an(InstancedEnchantment, enc)
   end

   if enc.params == "randomized" then
      local success, err = enc:on_generate(self)
      if not success then
         return nil, err
      end
   end
   enc:on_initialize(self)

   for _, existing_enc in ipairs(self.enchantments) do
      if enc == existing_enc then
         return nil, "item already has enchantment"
      end
   end

   -- We want at most MAX_ENCHANTMENTS enchantments of differing types/params,
   -- but you can have unlimited enchantments of the same type and params (they
   -- all get combined together). This is an artificial restriction at this
   -- point; we might want to remove it later.
   local base_encs = fun.wrap(ipairs(self.enchantments))
   local unique_encs_count = #IItemEnchantments.calc_total_enchantment_powers(base_encs)

   if unique_encs_count >= Const.MAX_ENCHANTMENTS then
      return nil, "max_enchantments"
   end

   table.insert(self.enchantments, enc)
   self._merged_enchantments = nil

   local adjusted_value = math.floor(self.value * enc.proto.value / 100)
   if adjusted_value > 0 then
      self.value = adjusted_value
   end

   table.insertion_sort(self.enchantments, InstancedEnchantment.__lt)

   self:emit("base.on_item_add_enchantment", {enchantment=enc})
   self:refresh()

   return enc
   -- <<<<<<<< shade2/item_data.hsp:627 	return true ..
end

local function gen_filter(_id, params, source)
   return function(enc)
      if _id then
         if enc._id ~= _id then
            return false
         end
         if params and not enc:compare_params(params) then
            return false
         end
      end

      if source and enc.source ~= source then
         return false
      end

      return true
   end
end

function IItemEnchantments:iter_base_enchantments(_id, params, source)
   return fun.iter(self.enchantments):filter(gen_filter(_id, params, source))
end

function IItemEnchantments:iter_enchantments(_id, params, source)
   return fun.iter(self.temp["enchantments"]):filter(gen_filter(_id, params, source))
end

function IItemEnchantments:iter_merged_enchantments(_id, params, source)
   if self._merged_enchantments == nil then
      local all_encs = fun.wrap(ipairs(self.temp["enchantments"]))
      self._merged_enchantments = IItemEnchantments.calc_total_enchantment_powers(all_encs)
   end
   return fun.iter(self._merged_enchantments)
end

function IItemEnchantments:add_temporary_enchantment(enc)
   -- TODO
   self._merged_enchantments = nil
end

function IItemEnchantments:enchantment_power(_id, params, source)
   return self:iter_enchantments(_id, params, source):extract("power"):sum()
end

function IItemEnchantments:find_enchantment(_id, params, source)
   if source == nil then
      local generated = self:iter_enchantments(_id, params, "generated"):nth(1)
      if generated then
         return generated
      end
   end
   return self:iter_enchantments(_id, params, source):nth(1)
end

function IItemEnchantments:find_base_enchantment(_id, params, source)
   if source == nil then
      local generated = self:iter_base_enchantments(_id, params, "generated"):nth(1)
      if generated then
         return generated
      end
   end
   return self:iter_base_enchantments(_id, params, source):nth(1)
end

function IItemEnchantments:remove_enchantment(enc, params, source)
   -- >>>>>>>> shade2/item_data.hsp:518 	#deffunc encRemove int id,int EncOrg,int encPorg ..
   if type(enc) == "string" then
      local _id = enc
      enc = self:find_base_enchantment(_id, params, source or "generated")
      if enc == nil then
         return nil, "no matching enchantment found"
      end
   else
      class.assert_is_an(InstancedEnchantment, enc)
   end

   local idx = table.index_of(self.enchantments, enc)
   if idx == nil then
      return nil, "item does not have enchantment"
   end

   assert(table.iremove_value(self.enchantments, enc))
   self._merged_enchantments = nil

   table.insertion_sort(self.enchantments, InstancedEnchantment.__Lt)
   self:emit("base.on_item_remove_enchantment", {index=idx, enchantment=enc})
   self:refresh()

   return enc
   -- <<<<<<<< shade2/item_data.hsp:536 	return ..
end

-- NOTE: Only call this if the item's prototype has changed, to preserve the
-- state of things like ammo.
function IItemEnchantments:add_enchantments_from_proto()
   local remove = {}
   for i, enc in ipairs(self.enchantments) do
      if enc.source == "item" then
         remove[#remove+1] = i
      end
   end
   table.remove_indices(self.enchantments, remove)

   for _, fixed_enc in ipairs(self.proto.enchantments or {}) do
      local params = fixed_enc.params and table.deepcopy(fixed_enc.params) or "randomized"
      self:add_enchantment(fixed_enc._id, fixed_enc.power, params, 0, "item")
   end

   self._merged_enchantments = nil
end

local function refresh_temporary_enchantments(item)
   -- Temporary enchantments will be references to their original copies in
   -- item.enchantments if available.
   --
   -- WARNING: when adding a temporary enchantment, you must not allocate a new
   -- table every time, because some comparisons are done by reference (ammo
   -- enchantment). Instead, you need to save the enchantment somewhere else,
   -- like in _ext, then copy its reference to temp.enchantments each refresh.
   item.temp["enchantments"] = table.shallow_copy(item.enchantments)

   table.insertion_sort(item.temp["enchantments"], InstancedEnchantment.__lt)
end

function IItemEnchantments:on_refresh()
   self._merged_enchantments = nil
   refresh_temporary_enchantments(self)
end

return IItemEnchantments
