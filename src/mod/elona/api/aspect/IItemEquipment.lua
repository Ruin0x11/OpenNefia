local IAspect = require("api.IAspect")

local IItemEquipment = class.interface("IItemEquipment", {
                                          dv = "number",
                                          pv = "number",
                                          hit_bonus = "number",
                                          damage_bonus = "number",
                                          equip_slots = "table",
                                          pcc_part = { type = "number", optional = true },
                                                         }, { IAspect })

IItemEquipment.default_impl = "mod.elona.api.aspect.ItemEquipmentAspect"

return IItemEquipment
