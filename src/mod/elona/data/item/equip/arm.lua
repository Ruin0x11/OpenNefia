local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")

--
-- Heavy Glove
--

data:add {
   _type = "base.item",
   _id = "thick_gauntlets",
   elona_id = 10,
   image = "elona.item_thick_gauntlets",
   value = 400,
   weight = 1100,
   hit_bonus = 2,
   damage_bonus = 1,
   pv = 4,
   dv = 2,
   material = "elona.metal",
   appearance = 2,
   category = 22000,
   equip_slots = { "elona.arm" },
   subcategory = 22001,
   coefficient = 100,
   categories = {
      "elona.equip_wrist_gauntlet",
      "elona.equip_wrist"
   }
}

data:add {
   _type = "base.item",
   _id = "plate_gauntlets",
   elona_id = 446,
   image = "elona.item_plate_gauntlets",
   value = 1800,
   weight = 1800,
   hit_bonus = 3,
   damage_bonus = 3,
   pv = 7,
   dv = 3,
   material = "elona.metal",
   appearance = 2,
   level = 30,
   category = 22000,
   equip_slots = { "elona.arm" },
   subcategory = 22001,
   coefficient = 100,
   categories = {
      "elona.equip_wrist_gauntlet",
      "elona.equip_wrist"
   }
}

data:add {
   _type = "base.item",
   _id = "composite_gauntlets",
   elona_id = 448,
   image = "elona.item_composite_gauntlets",
   value = 950,
   weight = 1300,
   hit_bonus = 4,
   damage_bonus = 2,
   pv = 5,
   dv = 3,
   material = "elona.metal",
   appearance = 2,
   level = 15,
   category = 22000,
   equip_slots = { "elona.arm" },
   subcategory = 22001,
   coefficient = 100,
   categories = {
      "elona.equip_wrist_gauntlet",
      "elona.equip_wrist"
   }
}

--
-- Light Glove
--

data:add {
   _type = "base.item",
   _id = "decorated_gloves",
   elona_id = 9,
   image = "elona.item_decorated_gloves",
   value = 1400,
   weight = 700,
   hit_bonus = 6,
   damage_bonus = 2,
   pv = 5,
   dv = 7,
   material = "elona.soft",
   appearance = 1,
   level = 30,
   category = 22000,
   equip_slots = { "elona.arm" },
   subcategory = 22003,
   coefficient = 100,
   categories = {
      "elona.equip_wrist_glove",
      "elona.equip_wrist"
   }
}

data:add {
   _type = "base.item",
   _id = "gloves_of_vesda",
   elona_id = 355,
   image = "elona.item_plate_gauntlets",
   value = 40000,
   weight = 1200,
   pv = 30,
   dv = 5,
   material = "elona.mithril",
   level = 20,
   fltselect = 3,
   category = 22000,
   equip_slots = { "elona.arm" },
   subcategory = 22003,
   coefficient = 100,

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   categories = {
      "elona.equip_wrist_glove",
      "elona.unique_item",
      "elona.equip_wrist"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.pierce", power = 150 },
      { _id = "elona.modify_resistance", power = 550, params = { element_id = "elona.fire" } },
      { _id = "elona.modify_attribute", power = 400, params = { skill_id = "elona.stat_strength" } },
      { _id = "elona.modify_resistance", power = 200, params = { element_id = "elona.sound" } },
      { _id = "elona.modify_skill", power = 450, params = { skill_id = "elona.dual_wield" } },
      { _id = "elona.modify_attribute", power = 500, params = { skill_id = "elona.stat_luck" } },
      { _id = "elona.res_confuse", power = 100 },
   }
}

data:add {
   _type = "base.item",
   _id = "gloves",
   elona_id = 445,
   image = "elona.item_gloves",
   value = 800,
   weight = 450,
   hit_bonus = 5,
   damage_bonus = 1,
   pv = 4,
   dv = 5,
   material = "elona.soft",
   appearance = 1,
   level = 15,
   category = 22000,
   equip_slots = { "elona.arm" },
   subcategory = 22003,
   coefficient = 100,
   categories = {
      "elona.equip_wrist_glove",
      "elona.equip_wrist"
   }
}

data:add {
   _type = "base.item",
   _id = "light_gloves",
   elona_id = 447,
   image = "elona.item_light_gloves",
   value = 280,
   weight = 200,
   hit_bonus = 3,
   pv = 3,
   dv = 3,
   material = "elona.soft",
   appearance = 1,
   category = 22000,
   equip_slots = { "elona.arm" },
   subcategory = 22003,
   coefficient = 100,
   categories = {
      "elona.equip_wrist_glove",
      "elona.equip_wrist"
   }
}
