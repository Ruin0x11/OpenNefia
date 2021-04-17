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
   dice_x = 1,
   dice_y = 8,
   hit_bonus = 2,
   damage_bonus = 1,
   material = "elona.metal",
   category = 25000,
   equip_slots = { "elona.ammo" },
   subcategory = 25001,
   coefficient = 100,

   skill = "elona.bow",

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_arrow"
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
   dice_x = 1,
   dice_y = 8,
   hit_bonus = 2,
   damage_bonus = 1,
   material = "elona.metal",
   category = 25000,
   equip_slots = { "elona.ammo" },
   subcategory = 25002,
   coefficient = 100,

   skill = "elona.crossbow",

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_bolt"
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
   dice_x = 2,
   dice_y = 2,
   hit_bonus = 4,
   damage_bonus = 1,
   material = "elona.metal",
   category = 25000,
   equip_slots = { "elona.ammo" },
   subcategory = 25020,
   coefficient = 100,

   skill = "elona.firearm",

   tags = { "sf" },

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_bullet",
      "elona.tag_sf"
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
   dice_x = 2,
   dice_y = 3,
   damage_bonus = 1,
   material = "elona.metal",
   category = 25000,
   equip_slots = { "elona.ammo" },
   subcategory = 25030,
   coefficient = 100,

   skill = "elona.firearm",

   tags = { "sf" },

   categories = {
      "elona.equip_ammo",
      "elona.equip_ammo_energy_cell",
      "elona.tag_sf"
   }
}
