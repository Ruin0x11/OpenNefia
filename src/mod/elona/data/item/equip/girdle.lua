local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

--
-- Girdle
--

data:add {
   _type = "base.item",
   _id = "girdle",
   elona_id = 66,
   image = "elona.item_girdle",
   value = 300,
   weight = 900,
   material = "elona.soft",
   coefficient = 100,
   categories = {
      "elona.equip_back_girdle",
      "elona.equip_cloak"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.waist" },
         dv = 3,
         pv = 3,
         pcc_part = 1,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "composite_girdle",
   elona_id = 459,
   image = "elona.item_composite_girdle",
   value = 2400,
   weight = 650,
   material = "elona.metal",
   level = 15,
   coefficient = 100,
   categories = {
      "elona.equip_back_girdle",
      "elona.equip_cloak"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.waist" },
         dv = 5,
         pv = 3,
         pcc_part = 3,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "plate_girdle",
   elona_id = 460,
   image = "elona.item_composite_girdle",
   value = 3900,
   weight = 1400,
   material = "elona.metal",
   level = 30,
   coefficient = 100,
   categories = {
      "elona.equip_back_girdle",
      "elona.equip_cloak"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.waist" },
         dv = 3,
         pv = 6,
         pcc_part = 2,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "crimson_plate",
   elona_id = 728,
   image = "elona.item_composite_girdle",
   value = 15000,
   weight = 1250,
   material = "elona.mithril",
   level = 13,
   fltselect = 3,
   coefficient = 100,

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   categories = {
      "elona.equip_back_girdle",
      "elona.unique_item",
      "elona.equip_cloak"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.cure_bleeding", power = 100 },
      { _id = "elona.modify_resistance", power = 450, params = { element_id = "elona.nether" } },
      { _id = "elona.modify_resistance", power = 350, params = { element_id = "elona.fire" } },
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.waist" },
         dv = 2,
         pv = 15,
         pcc_part = 2,
      }
   }
}
