local categories = {
   {
      _id = "equip_melee",
      ordering = 10000,
      is_major = true
   },
   {
      _id = "equip_head",
      ordering = 12000,
      is_major = true
   },
   {
      _id = "equip_shield",
      ordering = 14000,
      is_major = true
   },
   {
      _id = "equip_body",
      ordering = 16000,
      is_major = true
   },
   {
      _id = "equip_leg",
      ordering = 18000,
      is_major = true
   },
   {
      _id = "equip_cloak",
      ordering = 19000,
      is_major = true
   },
   {
      _id = "equip_back",
      ordering = 20000,
      is_major = true
   },
   {
      _id = "equip_wrist",
      ordering = 22000,
      is_major = true
   },
   {
      _id = "equip_ranged",
      ordering = 24000,
      is_major = true
   },
   {
      _id = "equip_ammo",
      ordering = 25000,
      is_major = true
   },
   {
      _id = "equip_ring",
      ordering = 32000,
      is_major = true
   },
   {
      _id = "equip_neck",
      ordering = 34000,
      is_major = true
   },
   {
      _id = "drink",
      ordering = 52000,
      is_major = true
   },
   {
      _id = "scroll",
      ordering = 53000,
      is_major = true
   },
   {
      _id = "spellbook",
      ordering = 54000,
      is_major = true
   },
   {
      _id = "book",
      ordering = 55000,
      is_major = true
   },
   {
      _id = "rod",
      ordering = 56000,
      is_major = true
   },
   {
      _id = "food",
      ordering = 57000,
      is_major = true
   },
   {
      _id = "misc_item",
      ordering = 59000,
      is_major = true
   },
   {
      _id = "furniture",
      ordering = 60000,
      is_major = true
   },
   {
      _id = "furniture_well",
      ordering = 60001,
   },
   {
      _id = "furniture_altar",
      ordering = 60002,
      is_major = true
   },
   {
      _id = "remains",
      ordering = 62000,
      is_major = true
   },
   {
      _id = "junk",
      ordering = 64000,
      is_major = true
   },
   {
      _id = "gold",
      ordering = 68000,
      is_major = true
   },
   {
      _id = "platinum",
      ordering = 69000,
      is_major = true
   },
   {
      _id = "container",
      ordering = 72000,
      is_major = true
   },
   {
      _id = "ore",
      ordering = 77000,
      is_major = true
   },
   {
      _id = "tree",
      ordering = 80000,
      is_major = true
   },
   {
      _id = "cargo_food",
      ordering = 91000,
      is_major = true
   },
   {
      _id = "cargo",
      ordering = 92000,
      is_major = true
   },
   {
      _id = "bug",
      ordering = 99999999,
      parents = {
         "elona.bug"
      }
   },
   {
      _id = "equip_armor"
      -- (refType<fltHeadArmor)or(refType>=fltHeadRange) : if (refType<fltHeadRing)or(refType>=fltHeadItem) :continue
   }
}

local subcategories = {
   {
      _id = "equip_melee_broadsword",
      ordering = 10001,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_long_sword",
      ordering = 10002,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_short_sword",
      ordering = 10003,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_club",
      ordering = 10004,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_hammer",
      ordering = 10005,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_staff",
      ordering = 10006,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_lance",
      ordering = 10007,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_halberd",
      ordering = 10008,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_hand_axe",
      ordering = 10009,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_axe",
      ordering = 10010,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_scythe",
      ordering = 10011,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_head_helm",
      ordering = 12001,
      parents = {
         "elona.equip_head"
      }
   },
   {
      _id = "equip_head_hat",
      ordering = 12002,
      parents = {
         "elona.equip_head"
      }
   },
   {
      _id = "equip_shield_shield",
      ordering = 14003,
      parents = {
         "elona.equip_shield"
      }
   },
   {
      _id = "equip_body_mail",
      ordering = 16001,
      parents = {
         "elona.equip_body"
      }
   },
   {
      _id = "equip_body_robe",
      ordering = 16003,
      parents = {
         "elona.equip_body"
      }
   },
   {
      _id = "equip_leg_heavy_boots",
      ordering = 18001,
      parents = {
         "elona.equip_leg"
      }
   },
   {
      _id = "equip_leg_shoes",
      ordering = 18002,
      parents = {
         "elona.equip_leg"
      }
   },
   {
      _id = "equip_back_girdle",
      ordering = 19001,
      parents = {
         "elona.equip_cloak"
      }
   },
   {
      _id = "equip_back_cloak",
      ordering = 20001,
      parents = {
         "elona.equip_back"
      }
   },
   {
      _id = "equip_wrist_gauntlet",
      ordering = 22001,
      parents = {
         "elona.equip_wrist"
      }
   },
   {
      _id = "equip_wrist_glove",
      ordering = 22003,
      parents = {
         "elona.equip_wrist"
      }
   },
   {
      _id = "equip_ranged_bow",
      ordering = 24001,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_crossbow",
      ordering = 24003,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_gun",
      ordering = 24020,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_laser_gun",
      ordering = 24021,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_thrown",
      ordering = 24030,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ammo_arrow",
      ordering = 25001,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_bolt",
      ordering = 25002,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_bullet",
      ordering = 25020,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_energy_cell",
      ordering = 25030,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ring_ring",
      ordering = 32001,
      parents = {
         "elona.equip_ring"
      }
   },
   {
      _id = "equip_neck_armor",
      ordering = 34001,
      parents = {
         "elona.equip_neck"
      }
   },
   {
      _id = "drink_potion",
      ordering = 52001,
      parents = {
         "elona.drink"
      }
   },
   {
      _id = "drink_alcohol",
      ordering = 52002,
      parents = {
         "elona.drink"
      }
   },
   {
      _id = "scroll_deed",
      ordering = 53100,
      parents = {
         "elona.scroll"
      }
   },
   {
      _id = "food_flour",
      ordering = 57001,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_noodle",
      ordering = 57002,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_vegetable",
      ordering = 57003,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_fruit",
      ordering = 57004,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "crop_herb",
      ordering = 58005,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "crop_seed",
      ordering = 58500,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "misc_item_crafting",
      ordering = 59500,
      parents = {
         "elona.misc_item"
      }
   },
   {
      _id = "furniture_bed", -- sleeping bag/furniture
      ordering = 60004, -- sleeping bag/furniture
   },
   {
      _id = "furniture_instrument",
      ordering = 60005,
      parents = {
         "elona.furniture"
      }
   },
   {
      -- This is only used to generate items that appear in random
      -- overworld field maps.
      _id = "junk_in_field", -- subcategory 64000
      ordering = 64000, -- subcategory 64000
   },
   {
      _id = "junk_town",
      ordering = 64100,
      parents = {
         "elona.junk"
      }
   },
   {
      _id = "ore_valuable",
      ordering = 77001,
      parents = {
         "elona.ore"
      }
   },
}

local tags = {
   {
      _id = "tag_sf"
   },
   {
      _id = "tag_fish"
   },
   {
      _id = "tag_neg"
   },
   {
      _id = "tag_noshop"
   },
   {
      _id = "tag_spshop"
   },
   {
      _id = "tag_fest"
   },
   {
      _id = "tag_nogive"
   },
}

local categories3 = {
   {
      _id = "no_generate",
      no_generate = true
   },
   {
      _id = "unique_weapon",
      no_generate = true
   },
   {
      _id = "unique_item",
      no_generate = true
   },
   {
      _id = "snow_tree",
      no_generate = true
   },
}

data:add_multi("base.item_type", categories)
data:add_multi("base.item_type", subcategories)
data:add_multi("base.item_type", tags)
data:add_multi("base.item_type", categories3)
