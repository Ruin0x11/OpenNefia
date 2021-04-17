local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")

--
-- Bow
--

data:add {
   _type = "base.item",
   _id = "long_bow",
   elona_id = 58,
   image = "elona.item_long_bow",
   value = 500,
   weight = 1200,
   dice_x = 2,
   dice_y = 7,
   hit_bonus = 4,
   damage_bonus = 8,
   material = "elona.metal",
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24001,
   coefficient = 100,

   skill = "elona.bow",

   effective_range = { 50, 90, 100, 90, 80, 80, 70, 60, 50, 20 },

   pierce_rate = 20,

   categories = {
      "elona.equip_ranged_bow",
      "elona.equip_ranged"
   }
}

data:add {
   _type = "base.item",
   _id = "bow_of_vindale",
   elona_id = 207,
   image = "elona.item_long_bow",
   value = 60000,
   weight = 1200,
   dice_x = 2,
   dice_y = 15,
   hit_bonus = 5,
   damage_bonus = 7,
   material = "elona.mithril",
   level = 35,
   fltselect = 2,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24001,
   coefficient = 100,

   skill = "elona.bow",

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 155, 154, 153 },

   effective_range = { 50, 90, 100, 90, 80, 80, 70, 60, 50, 20 },
   pierce_rate = 20,
   categories = {
      "elona.equip_ranged_bow",
      "elona.unique_weapon",
      "elona.equip_ranged"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.invoke_skill", power = 100, params = { enchantment_skill_id = "elona.draw_shadow" } },
      { _id = "elona.sustain_attribute", power = 100, params = { skill_id = "elona.stat_dexterity" } },
      { _id = "elona.sustain_attribute", power = 100, params = { skill_id = "elona.stat_perception" } },
      { _id = "elona.modify_attribute", power = 450, params = { skill_id = "elona.stat_dexterity" } },
      { _id = "elona.modify_resistance", power = 300, params = { element_id = "elona.poison" } },
      { _id = "elona.elemental_damage", power = 300, params = { element_id = "elona.poison" } },
   }
}

data:add {
   _type = "base.item",
   _id = "short_bow",
   elona_id = 230,
   image = "elona.item_long_bow",
   value = 500,
   weight = 800,
   dice_x = 3,
   dice_y = 5,
   hit_bonus = 8,
   damage_bonus = 3,
   material = "elona.metal",
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24001,
   coefficient = 100,

   skill = "elona.bow",

   effective_range = { 70, 100, 100, 80, 60, 20, 20, 20, 20, 20 },

   pierce_rate = 15,

   categories = {
      "elona.equip_ranged_bow",
      "elona.equip_ranged"
   }
}

data:add {
   _type = "base.item",
   _id = "wind_bow",
   elona_id = 673,
   image = "elona.item_long_bow",
   value = 35000,
   weight = 800,
   dice_x = 2,
   dice_y = 23,
   hit_bonus = 4,
   damage_bonus = 11,
   material = "elona.ether",
   level = 60,
   fltselect = 3,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24001,
   coefficient = 100,

   skill = "elona.bow",

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 225, 225, 255 },

   effective_range = { 50, 90, 100, 90, 80, 80, 70, 60, 50, 20 },
   pierce_rate = 20,

   categories = {
      "elona.equip_ranged_bow",
      "elona.unique_item",
      "elona.equip_ranged"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.invoke_skill", power = 200, params = { enchantment_skill_id = "elona.speed" } },
      { _id = "elona.invoke_skill", power = 200, params = { enchantment_skill_id = "elona.lulwys_trick" } },
      { _id = "elona.modify_attribute", power = 250, params = { skill_id = "elona.stat_speed" } },
      { _id = "elona.modify_resistance", power = 300, params = { element_id = "elona.lightning" } },
   }
}

data:add {
   _type = "base.item",
   _id = "skull_bow",
   elona_id = 788,
   image = "elona.item_skull_bow",
   value = 2000,
   weight = 700,
   dice_x = 1,
   dice_y = 17,
   hit_bonus = -18,
   damage_bonus = 10,
   material = "elona.metal",
   level = 15,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24001,
   rarity = 50000,
   coefficient = 100,

   skill = "elona.bow",

   effective_range = { 60, 90, 100, 100, 80, 60, 20, 20, 20, 20 },

   pierce_rate = 15,

   categories = {
      "elona.equip_ranged_bow",
      "elona.equip_ranged"
   }
}

--
-- Crossbow
--

data:add {
   _type = "base.item",
   _id = "crossbow",
   elona_id = 482,
   image = "elona.item_crossbow",
   value = 500,
   weight = 2800,
   dice_x = 1,
   dice_y = 18,
   hit_bonus = 4,
   damage_bonus = 6,
   material = "elona.metal",
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24003,
   coefficient = 100,

   skill = "elona.crossbow",

   effective_range = { 80, 100, 90, 80, 70, 60, 50, 20, 20, 20 },

   pierce_rate = 25,

   categories = {
      "elona.equip_ranged_crossbow",
      "elona.equip_ranged"
   }
}

--
-- Gun
--

data:add {
   _type = "base.item",
   _id = "pistol",
   elona_id = 60,
   image = "elona.item_pistol",
   value = 500,
   weight = 800,
   dice_x = 1,
   dice_y = 22,
   hit_bonus = 7,
   damage_bonus = 1,
   material = "elona.metal",
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24020,
   coefficient = 100,

   skill = "elona.firearm",

   tags = { "sf" },

   effective_range = { 100, 90, 70, 50, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 10,
   categories = {
      "elona.equip_ranged_gun",
      "elona.tag_sf",
      "elona.equip_ranged"
   }
}

data:add {
   _type = "base.item",
   _id = "machine_gun",
   elona_id = 231,
   image = "elona.item_machine_gun",
   value = 500,
   weight = 1800,
   dice_x = 10,
   dice_y = 3,
   hit_bonus = 10,
   damage_bonus = 1,
   material = "elona.metal",
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24020,
   coefficient = 100,

   skill = "elona.firearm",

   tags = { "sf" },

   effective_range = { 80, 100, 100, 90, 80, 70, 20, 20, 20, 20 },
   pierce_rate = 0,
   categories = {
      "elona.equip_ranged_gun",
      "elona.tag_sf",
      "elona.equip_ranged"
   }
}

data:add {
   _type = "base.item",
   _id = "shot_gun",
   elona_id = 496,
   image = "elona.item_shot_gun",
   value = 800,
   weight = 1500,
   dice_x = 4,
   dice_y = 8,
   hit_bonus = 4,
   damage_bonus = 6,
   material = "elona.metal",
   level = 10,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24020,
   coefficient = 100,

   skill = "elona.firearm",

   tags = { "sf" },

   effective_range = { 100, 60, 20, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 30,
   categories = {
      "elona.equip_ranged_gun",
      "elona.tag_sf",
      "elona.equip_ranged"
   }
}

data:add {
   _type = "base.item",
   _id = "winchester_premium",
   elona_id = 674,
   image = "elona.item_shot_gun",
   value = 35000,
   weight = 2800,
   dice_x = 8,
   dice_y = 9,
   hit_bonus = 7,
   damage_bonus = 2,
   material = "elona.diamond",
   level = 60,
   fltselect = 3,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24020,
   coefficient = 100,

   skill = "elona.firearm",

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   effective_range = { 100, 40, 20, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 30,

   categories = {
      "elona.equip_ranged_gun",
      "elona.unique_item",
      "elona.equip_ranged"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.invoke_skill", power = 350, params = { enchantment_skill_id = "elona.mist_of_silence" } },
      { _id = "elona.res_curse", power = 200 },
      { _id = "elona.modify_skill", power = 450, params = { skill_id = "elona.marksman" } },
      { _id = "elona.modify_resistance", power = 350, params = { element_id = "elona.sound" } },
   }
}

data:add {
   _type = "base.item",
   _id = "mauser_c96_custom",
   elona_id = 758,
   image = "elona.item_pistol",
   value = 25000,
   weight = 950,
   dice_x = 1,
   dice_y = 24,
   hit_bonus = 14,
   damage_bonus = 26,
   material = "elona.iron",
   fltselect = 3,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24020,
   coefficient = 100,

   skill = "elona.firearm",

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   tags = { "sf" },
   color = { 155, 154, 153 },
   effective_range = { 100, 90, 70, 50, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 35,

   categories = {
      "elona.equip_ranged_gun",
      "elona.tag_sf",
      "elona.unique_item",
      "elona.equip_ranged"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.see_invisi", power = 100 },
   }
}

--
-- Laser Gun
--

data:add {
   _type = "base.item",
   _id = "laser_gun",
   elona_id = 512,
   image = "elona.item_laser_gun",
   value = 1500,
   weight = 1200,
   dice_x = 2,
   dice_y = 12,
   hit_bonus = 5,
   damage_bonus = 5,
   material = "elona.metal",
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24021,
   rarity = 200000,
   coefficient = 100,

   skill = "elona.firearm",

   tags = { "sf" },

   effective_range = { 100, 100, 100, 100, 100, 100, 100, 20, 20, 20 },
   pierce_rate = 5,
   categories = {
      "elona.equip_ranged_laser_gun",
      "elona.tag_sf",
      "elona.equip_ranged",
   }
}

data:add {
   _type = "base.item",
   _id = "rail_gun",
   elona_id = 514,
   image = "elona.item_laser_gun",
   value = 60000,
   weight = 8500,
   dice_x = 4,
   dice_y = 10,
   hit_bonus = -20,
   damage_bonus = 15,
   material = "elona.ether",
   level = 80,
   fltselect = 3,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24021,
   rarity = 200000,
   coefficient = 100,

   skill = "elona.firearm",

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   tags = { "sf" },

   effective_range = { 100, 100, 100, 100, 100, 100, 100, 50, 20, 20 },
   pierce_rate = 5,

   categories = {
      "elona.equip_ranged_laser_gun",
      "elona.tag_sf",
      "elona.unique_item",
      "elona.equip_ranged"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.invoke_skill", power = 350, params = { enchantment_skill_id = "elona.raging_roar" } },
      { _id = "elona.invoke_skill", power = 300, params = { enchantment_skill_id = "elona.chaos_ball" } },
      { _id = "elona.elemental_damage", power = 300, params = { element_id = "elona.nerve" } },
      { _id = "elona.modify_resistance", power = 300, params = { element_id = "elona.sound" } },
      { _id = "elona.modify_resistance", power = 300, params = { element_id = "elona.chaos" } },
   }
}

--
-- Throwing
--

data:add {
   _type = "base.item",
   _id = "stone",
   elona_id = 210,
   image = "elona.item_stone",
   value = 180,
   weight = 2000,
   dice_x = 1,
   dice_y = 12,
   material = "elona.iron",
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24030,
   coefficient = 100,

   skill = "elona.throwing",

   effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 5,
   categories = {
      "elona.equip_ranged_thrown",
      "elona.equip_ranged"
   }
}

data:add {
   _type = "base.item",
   _id = "shuriken",
   elona_id = 713,
   image = "elona.item_shuriken",
   value = 750,
   weight = 400,
   dice_x = 1,
   dice_y = 20,
   hit_bonus = 4,
   material = "elona.metal",
   level = 5,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24030,
   rarity = 200000,
   coefficient = 100,

   skill = "elona.throwing",
   effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 15,

   categories = {
      "elona.equip_ranged_thrown",
      "elona.equip_ranged"
   },

   enchantments = {
      { _id = "elona.elemental_damage", power = 100, params = { element_id = "elona.cut" } },
   }
}

data:add {
   _type = "base.item",
   _id = "grenade",
   elona_id = 714,
   image = "elona.item_grenade",
   value = 550,
   weight = 850,
   dice_x = 1,
   dice_y = 6,
   material = "elona.metal",
   level = 10,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24030,
   rarity = 100000,
   coefficient = 100,

   skill = "elona.throwing",
   effective_range = { 80, 100, 90, 80, 60, 20, 20, 20, 20, 20 },
   pierce_rate = 0,

   categories = {
      "elona.equip_ranged_thrown",
      "elona.equip_ranged"
   },

   enchantments = {
      { _id = "elona.invoke_skill", power = 100, params = { enchantment_skill_id = "elona.grenade" } },
   }
}

data:add {
   _type = "base.item",
   _id = "vanilla_rock",
   elona_id = 716,
   image = "elona.item_stone",
   value = 9500,
   weight = 7500,
   dice_x = 1,
   dice_y = 42,
   material = "elona.adamantium",
   level = 15,
   fltselect = 3,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24030,
   coefficient = 100,

   skill = "elona.throwing",
   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,
   effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 50,categories = {
      "elona.equip_ranged_thrown",
      "elona.unique_item",
      "elona.equip_ranged"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "kill_kill_piano",
   elona_id = 725,
   image = "elona.item_goulds_piano",
   value = 25000,
   weight = 75000,
   dice_x = 1,
   dice_y = 112,
   hit_bonus = -28,
   material = "elona.gold",
   level = 25,
   fltselect = 3,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24030,
   coefficient = 100,

   skill = "elona.throwing",

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 255, 215, 175 },

   effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 0,

   categories = {
      "elona.equip_ranged_thrown",
      "elona.unique_item",
      "elona.equip_ranged"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.elemental_damage", power = 400, params = { element_id = "elona.chaos" } },
      { _id = "elona.modify_skill", power = -700, params = { skill_id = "elona.performer" } },
      { _id = "elona.crit", power = 450 },
   }
}

data:add {
   _type = "base.item",
   _id = "panty",
   elona_id = 633,
   image = "elona.item_panty",
   value = 25000,
   weight = 500,
   dice_x = 1,
   dice_y = 35,
   material = "elona.soft",
   level = 5,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24030,
   rarity = 10000,
   coefficient = 100,

   skill = "elona.throwing",
   effective_range = { 50, 100, 50, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 5,

   categories = {
      "elona.equip_ranged_thrown",
      "elona.equip_ranged"
   },

   enchantments = {
      { _id = "elona.elemental_damage", power = 800, params = { element_id = "elona.mind" } },
   }
}

data:add {
   _type = "base.item",
   _id = "shenas_panty",
   elona_id = 718,
   image = "elona.item_panty",
   value = 94000,
   weight = 250,
   dice_x = 1,
   dice_y = 47,
   hit_bonus = 7,
   damage_bonus = 4,
   material = "elona.silk",
   level = 40,
   fltselect = 3,
   category = 24000,
   equip_slots = { "elona.ranged" },
   subcategory = 24030,
   coefficient = 100,

   skill = "elona.throwing",

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   effective_range = { 50, 100, 50, 20, 20, 20, 20, 20, 20, 20 },
   pierce_rate = 5,

   categories = {
      "elona.equip_ranged_thrown",
      "elona.unique_item",
      "elona.equip_ranged"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.stop_time", power = 350 },
      { _id = "elona.elemental_damage", power = 1200, params = { element_id = "elona.mind" } },
      { _id = "elona.modify_attribute", power = 450, params = { skill_id = "elona.stat_charisma" } },
      { _id = "elona.res_pregnancy", power = 100 },
      { _id = "elona.res_etherwind", power = 500 },
   }
}
