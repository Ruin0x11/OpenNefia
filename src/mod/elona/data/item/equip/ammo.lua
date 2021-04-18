local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")
local IItemAmmo = require("mod.elona.api.aspect.IItemAmmo")

--
-- Arrow
--

data:add {
   _type = "base.item",
   _id = "arrow",
   elona_id = 61,
   image = "elona.item_bolt",
   value = 150,
   weight = 1200,
   material = "elona.metal",
   coefficient = 100,

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_arrow"
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.ammo" },
         hit_bonus = 2,
         damage_bonus = 1,
      },
      [IItemAmmo] = {
         skill = "elona.bow",
         dice_x = 1,
         dice_y = 8,
      }
   }
}

--
-- Bolt
--

data:add {
   _type = "base.item",
   _id = "bolt",
   elona_id = 483,
   image = "elona.item_bolt",
   value = 150,
   weight = 3500,
   material = "elona.metal",
   coefficient = 100,

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_bolt"
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.ammo" },
         hit_bonus = 2,
         damage_bonus = 1,
      },
      [IItemAmmo] = {
         skill = "elona.crossbow",
         dice_x = 1,
         dice_y = 8,
      }
   }
}

--
-- Bullet
--

data:add {
   _type = "base.item",
   _id = "bullet",
   elona_id = 62,
   image = "elona.item_bullet",
   value = 150,
   weight = 2400,
   material = "elona.metal",
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_bullet",
      "elona.tag_sf"
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.ammo" },
         hit_bonus = 4,
         damage_bonus = 1,
      },
      [IItemAmmo] = {
         skill = "elona.firearm",
         dice_x = 2,
         dice_y = 2,
      }
   }
}

--
-- Energy Cell
--

data:add {
   _type = "base.item",
   _id = "energy_cell",
   elona_id = 513,
   image = "elona.item_energy_cell",
   value = 150,
   weight = 800,
   material = "elona.metal",
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_energy_cell",
      "elona.tag_sf"
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.ammo" },
         damage_bonus = 1,
      },
      [IItemAmmo] = {
         skill = "elona.firearm",
         dice_x = 2,
         dice_y = 3,
      }
   }
}
