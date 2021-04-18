local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

local ItemEquipmentAspect = class.class("ItemEquipmentAspect", IItemEquipment)

function ItemEquipmentAspect:init(item, params)
   self.dv = params.dv or 0
   self.pv = params.pv or 0
   self.hit_bonus = params.hit_bonus or 0
   self.damage_bonus = params.damage_bonus or 0
   self.equip_slots = params.equip_slots or {}
   self.pcc_part = params.pcc_part or nil
end

return ItemEquipmentAspect
