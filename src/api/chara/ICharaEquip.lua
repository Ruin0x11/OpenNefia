local EquipSlots = require("api.EquipSlots")
local ICharaInventory = require("api.chara.ICharaInventory")
local ILocation = require("api.ILocation")

local ICharaEquip = interface("ICharaEquip", {}, ICharaInventory)

function ICharaEquip:init()
   -- TODO resolver
   self.equip = EquipSlots:new(self.body_parts or {})
   self.body_parts = nil
end

function ICharaEquip:refresh()
end

function ICharaEquip:equip_item(item, force)
   if not (self:has_item(item) or force) then
      return nil
   end

   local result = self.equip:equip(item)

   self:refresh()

   return result
end

function ICharaEquip:has_item_equipped(item)
   return self.equip:has_object(item)
end

-- Returns true if the given item is equipped or in the character's
-- inventory.
function ICharaEquip:has_item(item)
   return self:has_item_in_inventory(item) or self:has_item_equipped(item)
end

function ICharaEquip:unequip_item(item)
   if not self.equip:has_object(item) then
      return nil
   end

   local result = self:take_item(item)

   self:refresh()

   return result
end

-- Iterates all body parts on this character, including empty slots.
-- @treturn iterator
function ICharaEquip:iter_body_parts()
   return self.equip:iter_body_parts()
end

-- Iterates the items that are equipped on this character.
-- @treturn iterator
function ICharaEquip:iter_equipment()
   return self.equip:iter()
end

function ICharaEquip:has_body_part_for(item)
   return self.equip:has_body_part_for(item)
end

-- Adds a new body part to this character.
-- @tparam base.body_part _type
function ICharaEquip:add_body_part(_type)
   -- TODO
end

-- Attempts to remove a body part. If something is equipped there,
-- this function fails unless `force` is true. If `force` is true when
-- an item is equipped there, removes the item, makes it ownerless and
-- returns it. If unsuccessful, no state is changed.
-- @tparam int|string type_or_slot
-- @tparam bool force
-- @treturn[1] nil
-- @treturn[2] IItem
-- @retval_ownership nil
function ICharaEquip:remove_body_part(type_or_slot, force)
   -- TODO
end

-- Marks a slot or body part as "blocked" for use as a refreshed
-- value. It will be hidden in the equipment menu for the character.
function ICharaEquip:temp_block_body_part()
   -- TODO
end

return ICharaEquip
