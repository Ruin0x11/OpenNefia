local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")

--
-- Light Helm
--

data:add {
   _type = "base.item",
   _id = "magic_hat",
   elona_id = 5,
   image = "elona.item_magic_hat",
   value = 1400,
   weight = 600,
   pv = 4,
   dv = 6,
   material = "elona.soft",
   level = 15,
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12002,
   coefficient = 100,
   categories = {
      "elona.equip_head_hat",
      "elona.equip_head"
   }
}

data:add {
   _type = "base.item",
   _id = "fairy_hat",
   elona_id = 6,
   image = "elona.item_fairy_hat",
   value = 7200,
   weight = 400,
   pv = 5,
   dv = 7,
   material = "elona.soft",
   level = 30,
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12002,
   coefficient = 100,

   categories = {
      "elona.equip_head_hat",
      "elona.equip_head"
   },

   enchantments = {
      { _id = "elona.res_mutation", power = 100 },
   }
}

data:add {
   _type = "base.item",
   _id = "feather_hat",
   elona_id = 463,
   image = "elona.item_feather_hat",
   value = 400,
   weight = 500,
   pv = 1,
   dv = 5,
   material = "elona.soft",
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12002,
   coefficient = 100,
   categories = {
      "elona.equip_head_hat",
      "elona.equip_head"
   }
}

--
-- Heavy Helm
--

data:add {
   _type = "base.item",
   _id = "heavy_helm",
   elona_id = 464,
   image = "elona.item_heavy_helm",
   value = 4800,
   weight = 2400,
   pv = 7,
   dv = 4,
   material = "elona.metal",
   level = 30,
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12001,
   coefficient = 100,
   categories = {
      "elona.equip_head_helm",
      "elona.equip_head"
   }
}

data:add {
   _type = "base.item",
   _id = "knight_helm",
   elona_id = 465,
   image = "elona.item_knight_helm",
   value = 2200,
   weight = 2000,
   pv = 7,
   dv = 1,
   material = "elona.metal",
   level = 15,
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12001,
   coefficient = 100,
   categories = {
      "elona.equip_head_helm",
      "elona.equip_head"
   }
}

data:add {
   _type = "base.item",
   _id = "helm",
   elona_id = 466,
   image = "elona.item_helm",
   value = 600,
   weight = 1600,
   pv = 5,
   dv = 3,
   material = "elona.metal",
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12001,
   coefficient = 100,
   categories = {
      "elona.equip_head_helm",
      "elona.equip_head"
   }
}

data:add {
   _type = "base.item",
   _id = "composite_helm",
   elona_id = 467,
   image = "elona.item_composite_helm",
   value = 9600,
   weight = 1800,
   pv = 8,
   dv = 5,
   material = "elona.metal",
   level = 60,
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12001,
   coefficient = 100,
   categories = {
      "elona.equip_head_helm",
      "elona.equip_head"
   }
}

data:add {
   _type = "base.item",
   _id = "sages_helm",
   elona_id = 627,
   image = "elona.item_knight_helm",
   value = 40000,
   weight = 1500,
   pv = 15,
   dv = 4,
   material = "elona.mithril",
   level = 20,
   fltselect = 3,
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12001,
   coefficient = 100,

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 255, 215, 175 },

   medal_value = 55,

   categories = {
      "elona.equip_head_helm",
      "elona.unique_item",
      "elona.equip_head"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.res_confuse", power = 100 },
      { _id = "elona.see_invisi", power = 100 },
      { _id = "elona.modify_attribute", power = 200, params = { skill_id = "elona.stat_magic" } },
      { _id = "elona.modify_resistance", power = 250, params = { element_id = "elona.mind" } },
      { _id = "elona.modify_resistance", power = 150, params = { element_id = "elona.magic" } },
      { _id = "elona.modify_skill", power = 300, params = { skill_id = "elona.anatomy" } },
   }
}

data:add {
   _type = "base.item",
   _id = "five_horned_helm",
   elona_id = 757,
   image = "elona.item_knight_helm",
   value = 15000,
   weight = 2400,
   damage_bonus = 8,
   pv = 7,
   dv = 2,
   material = "elona.obsidian",
   level = 5,
   fltselect = 3,
   category = 12000,
   equip_slots = { "elona.head" },
   subcategory = 12001,
   coefficient = 100,

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 175, 175, 255 },

   categories = {
      "elona.equip_head_helm",
      "elona.unique_item",
      "elona.equip_head"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.god_detect", power = 100 },
      { _id = "elona.extra_melee", power = 200 },
      { _id = "elona.extra_shoot", power = 150 },
      { _id = "elona.damage_reflection", power = 180 },
      { _id = "elona.res_mutation", power = 100 },
   }
}
