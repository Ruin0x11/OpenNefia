local Event = require("api.Event")
local EquipSlots = require("api.EquipSlots")
local ICharaInventory = require("api.chara.ICharaInventory")
local ILocation = require("api.ILocation")

local ICharaEquip = class.interface("ICharaEquip", {}, ICharaInventory)

function ICharaEquip:init()
   self.body_parts = self.body_parts or {}
   -- TODO resolver
   self.equip = EquipSlots:new(self.body_parts)
   self.equipment_weight = 0
end

function ICharaEquip:on_refresh()
   for _, part in self:iter_body_parts() do
      local item = part.equipped
      if item then
         item:refresh()

         self:apply_item_stats(item)
      end
   end
end

function ICharaEquip:apply_item_stats(item)
   self:mod("equipment_weight", item:calc("weight"))
   self:mod("dv", item:calc("dv"))
   self:mod("pv", item:calc("pv"))
   self:mod("hit_bonus", item:calc("hit_bonus"))
   self:mod("damage_bonus", item:calc("damage_bonus"))

   if item:calc("is_melee_weapon") then
      self:mod("number_of_weapons", 1, "add")
   elseif item:calc("is_armor") then
      local bonus = 0
      if item:is_blessed() then
         bonus = 2
      end
      self:mod("pv", item:calc("bonus") * 2 + bonus)
   end

   local curse_state = item:calc("curse_state")
   if curse_state == "cursed" then
      self:mod("curse_power", 20)
   elseif curse_state == "cursed" then
      self:mod("curse_power", 100)
   end

   local is_ether = false
   if is_ether then
      self:mod("ether_disease_speed", 5)
   end

   item:apply_enchantments_to_wielder(self)

   Event.trigger("base.on_calc_chara_equipment_stats", {chara=self,item=item})
end

function ICharaEquip:equip_item(item, force)
   if not (self:has_item(item) or force) then
      return nil, "not_owned"
   end

   local result = self.equip:equip(item)
   item:refresh()

   return result
end

function ICharaEquip:has_item_equipped(item)
   return self.equip:has_object(item)
end

function ICharaEquip:has_enchantment(id)
   return false
end

function ICharaEquip:items_equipped_at(body_part_type)
   return self.equip:items_equipped_at(body_part_type)
end

function ICharaEquip:find_equip_slot_for(item, body_part_type)
   return self.equip:find_free_slot(item, body_part_type)
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
   item:refresh()

   return result
end

-- Iterates all body parts on this character, including empty slots.
-- @treturn iterator
function ICharaEquip:iter_body_parts(also_empty)
   return self.equip:iter_body_parts(also_empty)
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
