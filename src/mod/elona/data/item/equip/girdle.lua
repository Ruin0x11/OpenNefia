local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")

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
   pv = 3,
   dv = 3,
   material = "elona.soft",
   appearance = 1,
   category = 19000,
   equip_slots = { "elona.waist" },
   subcategory = 19001,
   coefficient = 100,
   categories = {
      "elona.equip_back_girdle",
      "elona.equip_cloak"
   }
}

data:add {
   _type = "base.item",
   _id = "composite_girdle",
   elona_id = 459,
   image = "elona.item_composite_girdle",
   value = 2400,
   weight = 650,
   pv = 3,
   dv = 5,
   material = "elona.metal",
   appearance = 3,
   level = 15,
   category = 19000,
   equip_slots = { "elona.waist" },
   subcategory = 19001,
   coefficient = 100,
   categories = {
      "elona.equip_back_girdle",
      "elona.equip_cloak"
   }
}

data:add {
   _type = "base.item",
   _id = "plate_girdle",
   elona_id = 460,
   image = "elona.item_composite_girdle",
   value = 3900,
   weight = 1400,
   pv = 6,
   dv = 3,
   material = "elona.metal",
   appearance = 2,
   level = 30,
   category = 19000,
   equip_slots = { "elona.waist" },
   subcategory = 19001,
   coefficient = 100,
   categories = {
      "elona.equip_back_girdle",
      "elona.equip_cloak"
   }
}

data:add {
   _type = "base.item",
   _id = "crimson_plate",
   elona_id = 728,
   image = "elona.item_composite_girdle",
   value = 15000,
   weight = 1250,
   pv = 15,
   dv = 2,
   material = "elona.mithril",
   appearance = 2,
   level = 13,
   fltselect = 3,
   category = 19000,
   equip_slots = { "elona.waist" },
   subcategory = 19001,
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
   }
}
