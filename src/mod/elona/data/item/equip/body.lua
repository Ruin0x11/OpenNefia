local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

--
-- Heavy Armor
--

data:add {
   _type = "base.item",
   _id = "breastplate",
   elona_id = 7,
   image = "elona.item_breastplate",
   value = 600,
   weight = 4500,
   material = "elona.metal",
   coefficient = 100,
   categories = {
      "elona.equip_body_mail",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 6,
         pv = 10,
         pcc_part = 1,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "banded_mail",
   elona_id = 435,
   image = "elona.item_banded_mail",
   value = 1500,
   weight = 6500,
   material = "elona.metal",
   level = 10,
   coefficient = 100,
   categories = {
      "elona.equip_body_mail",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 5,
         pv = 12,
         pcc_part = 2,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "plate_mail",
   elona_id = 436,
   image = "elona.item_plate_mail",
   value = 12500,
   weight = 7500,
   material = "elona.metal",
   level = 50,
   coefficient = 100,
   categories = {
      "elona.equip_body_mail",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 6,
         pv = 21,
         pcc_part = 7,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "ring_mail",
   elona_id = 437,
   image = "elona.item_ring_mail",
   value = 2400,
   weight = 5000,
   material = "elona.metal",
   level = 20,
   coefficient = 100,
   categories = {
      "elona.equip_body_mail",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 6,
         pv = 14,
         pcc_part = 2,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "composite_mail",
   elona_id = 438,
   image = "elona.item_composite_mail",
   value = 4500,
   weight = 5500,
   material = "elona.metal",
   level = 30,
   coefficient = 100,
   categories = {
      "elona.equip_body_mail",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 7,
         pv = 17,
         pcc_part = 6,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "chain_mail",
   elona_id = 439,
   image = "elona.item_chain_mail",
   value = 8000,
   weight = 5200,
   material = "elona.metal",
   level = 40,
   coefficient = 100,
   categories = {
      "elona.equip_body_mail",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 7,
         pv = 19,
         pcc_part = 6,
      }
   }
}

--
-- Light Armor
--

data:add {
   _type = "base.item",
   _id = "robe",
   elona_id = 8,
   image = "elona.item_robe",
   value = 450,
   weight = 800,
   material = "elona.soft",
   coefficient = 100,
   categories = {
      "elona.equip_body_robe",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 11,
         pv = 3,
         pcc_part = 3,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "pope_robe",
   elona_id = 440,
   image = "elona.item_pope_robe",
   value = 9500,
   weight = 1200,
   material = "elona.soft",
   level = 45,
   coefficient = 100,
   categories = {
      "elona.equip_body_robe",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 18,
         pv = 8,
         pcc_part = 4,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "light_mail",
   elona_id = 441,
   image = "elona.item_light_mail",
   value = 1200,
   weight = 1800,
   material = "elona.soft",
   level = 10,
   coefficient = 100,
   categories = {
      "elona.equip_body_robe",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 10,
         pv = 8,
         pcc_part = 2,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "coat",
   elona_id = 442,
   image = "elona.item_coat",
   value = 2000,
   weight = 1500,
   material = "elona.soft",
   level = 20,
   coefficient = 100,
   categories = {
      "elona.equip_body_robe",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 13,
         pv = 9,
         pcc_part = 5,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "breast_plate",
   elona_id = 443,
   image = "elona.item_breast_plate",
   value = 5500,
   weight = 2800,
   material = "elona.soft",
   level = 25,
   coefficient = 100,
   categories = {
      "elona.equip_body_robe",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 15,
         pv = 11,
         pcc_part = 2,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "bulletproof_jacket",
   elona_id = 444,
   image = "elona.item_bulletproof_jacket",
   value = 7200,
   weight = 1600,
   material = "elona.soft",
   level = 35,
   coefficient = 100,
   categories = {
      "elona.equip_body_robe",
      "elona.equip_body"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.body" },
         dv = 14,
         pv = 15,
         pcc_part = 5,
      }
   }
}
