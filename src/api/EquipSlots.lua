local ILocation = require("api.ILocation")
local pool = require("internal.pool")

--- Equipment slots for characters.
local EquipSlots = class("EquipSlots", ILocation)

function EquipSlots:init(body_parts)
   body_parts = body_parts or {}

   self.body_parts = fun.iter(body_parts):map(function(i) return { type = i } end) :to_list()

   local uids = require("internal.global.uids")
   self.pool = pool:new("base.item", uids, 1, 1)

   self.equipped = {}
end

function EquipSlots:find_free_slot(obj, body_part_type)
   local equip_slots = obj:get_equip_slots()
   if #equip_slots == 0 then
      return nil
   end

   local can_equip = table.set(equip_slots)

   local pred

   if body_part_type then
      if not can_equip[body_part_type] then
         return nil
      end

      pred = function(part)
         return part.type == body_part_type and not part.equipped
      end
   else
      pred = function(part)
         return can_equip[part.type] and not part.equipped
      end
   end

   local part = fun.iter(self.body_parts):filter(pred):nth(1)
   local slot = fun.index(part, self.body_parts)

   return slot
end

--- Puts an item into an equip slot provided it is free. Returns the
--- object on success, nil on failure.
-- @tparam IMapObject obj
-- @treturn[1] IMapObject
-- @treturn[2] nil
-- @ownership obj nil
function EquipSlots:equip(obj, slot)
   if slot == nil then
      slot = self:find_free_slot(obj)
   end

   if obj == nil or type(slot) ~= "number" then
      return nil
   end

   if slot <= 0 or slot > #self.body_parts then
      return nil
   end

   if self.equipped[obj.uid] then
      return nil
   end

   if not self.pool:take_object(obj) then
      return nil
   end

   obj.location = self
   self.equipped[obj.uid] = slot
   self.body_parts[slot].equipped = obj.uid

   return obj
end

--- Removes an item from the equip slots. Returns the object on
--- success, nil on failure.
-- @tparam IMapObject obj
-- @treturn[1] IMapObject
-- @treturn[2] nil
-- @ownership obj self
function EquipSlots:unequip(obj)
   if obj == nil then
      return nil
   end

   local slot = self.equipped[obj.uid]
   if not slot then
      return nil
   end

   if not self.pool:remove_object(obj) then
      return nil
   end

   assert(obj.location == nil)
   self.equipped[obj.uid] = nil
   self.body_parts[slot].equipped = nil

   return obj
end

--- Adds a new body part.
-- @tparam base.body_part _type
function EquipSlots:add_body_part(_type)
   self.body_parts[self.body_parts+1] = { type = _type }
end

--- Removes a body part at slot. Fails if an item is equipped there;
--- callers are expected to manage unequipping themselves.
-- @tparam int slot
-- @treturn bool
function EquipSlots:remove_body_part(slot)
   if slot <= 0 or slot > #self.body_parts then
      return false
   end

   local part = self.body_parts[slot]

   if part.equipped then
      return false
   end

   table.remove(self.body_parts, slot)

   return true
end

function EquipSlots:items_for_type(body_part_type)
   local r = {}
   for _, v in ipairs(self.body_parts) do
      if v.equipped and v.type == body_part_type then
         r[#r+1] = self.pool:get_object(v.equipped)
      end
   end
   return r
end

function EquipSlots:is_equipped_at(slot)
end

--
-- ILocation impl
--

EquipSlots:delegate("pool",
                   {
                      "move_object",
                      "objects_at_pos",
                      "get_object",
                      "has_object",
                      "iter"
                   })

function EquipSlots:is_positional()
   return false
end

function EquipSlots:is_in_bounds(x, y)
   return true
end

function EquipSlots:remove_object(obj)
   return self:unequip(obj)
end

function EquipSlots:put_into(other, obj, x, y)
   if not self:unequip(obj) then
      return nil
   end

   return other:take_object(obj, x, y)
end

function EquipSlots:can_take_object(obj)
   return self:find_free_slot(obj) ~= nil
end

function EquipSlots:take_object(obj)
   if not self:can_take_object(obj) then
      return nil
   end

   local slot = self:find_free_slot(obj)
   if not slot then
      return nil
   end

   return self:equip(obj, slot)
end

return EquipSlots
