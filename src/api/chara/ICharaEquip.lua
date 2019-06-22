local EquipSlots = require("api.EquipSlots")
local ILocation = require("api.ILocation")

local ICharaEquip = interface("ICharaEquip")

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

function ICharaEquip:is_equipped(item)
   return self.equip:has_object(item)
end

function ICharaEquip:unequip_item(item)
   if not self.equip:has_object(item) then
      return nil
   end

   local result = self:take_item(item)

   self:refresh()

   return result
end

function ICharaEquip:iter_equipment()
   return self.equip:iter_objects()
end

return ICharaEquip
