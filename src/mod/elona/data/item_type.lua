local categories = {
   {
      _id = "equip_melee",
      _ordering = 10000,
      is_major = true
   },
   {
      _id = "equip_head",
      _ordering = 12000,
      is_major = true
   },
   {
      _id = "equip_shield",
      _ordering = 14000,
      is_major = true
   },
   {
      _id = "equip_body",
      _ordering = 16000,
      is_major = true
   },
   {
      _id = "equip_leg",
      _ordering = 18000,
      is_major = true
   },
   {
      _id = "equip_cloak",
      _ordering = 19000,
      is_major = true
   },
   {
      _id = "equip_back",
      _ordering = 20000,
      is_major = true
   },
   {
      _id = "equip_wrist",
      _ordering = 22000,
      is_major = true
   },
   {
      _id = "equip_ranged",
      _ordering = 24000,
      is_major = true
   },
   {
      _id = "equip_ammo",
      _ordering = 25000,
      is_major = true
   },
   {
      _id = "equip_ring",
      _ordering = 32000,
      is_major = true
   },
   {
      _id = "equip_neck",
      _ordering = 34000,
      is_major = true
   },
   {
      _id = "drink",
      _ordering = 52000,
      is_major = true
   },
   {
      _id = "scroll",
      _ordering = 53000,
      is_major = true
   },
   {
      _id = "spellbook",
      _ordering = 54000,
      is_major = true
   },
   {
      _id = "book",
      _ordering = 55000,
      is_major = true
   },
   {
      _id = "rod",
      _ordering = 56000,
      is_major = true
   },
   {
      _id = "food",
      _ordering = 57000,
      is_major = true
   },
   {
      _id = "misc_item",
      _ordering = 59000,
      is_major = true
   },
   {
      _id = "furniture",
      _ordering = 60000,
      is_major = true
   },
   {
      _id = "furniture_well",
      _ordering = 60001,
   },
   {
      _id = "furniture_altar",
      _ordering = 60002,
      is_major = true
   },
   {
      _id = "remains",
      _ordering = 62000,
      is_major = true
   },
   {
      _id = "junk",
      _ordering = 64000,
      is_major = true
   },
   {
      _id = "gold",
      _ordering = 68000,
      is_major = true
   },
   {
      _id = "platinum",
      _ordering = 69000,
      is_major = true
   },
   {
      _id = "container",
      _ordering = 72000,
      is_major = true
   },
   {
      _id = "ore",
      _ordering = 77000,
      is_major = true
   },
   {
      _id = "tree",
      _ordering = 80000,
      is_major = true
   },
   {
      _id = "cargo_food",
      _ordering = 91000,
      is_major = true
   },
   {
      _id = "cargo",
      _ordering = 92000,
      is_major = true
   },
   {
      _id = "bug",
      _ordering = 99999999,
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
      _ordering = 10001,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_long_sword",
      _ordering = 10002,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_short_sword",
      _ordering = 10003,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_club",
      _ordering = 10004,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_hammer",
      _ordering = 10005,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_staff",
      _ordering = 10006,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_lance",
      _ordering = 10007,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_halberd",
      _ordering = 10008,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_hand_axe",
      _ordering = 10009,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_axe",
      _ordering = 10010,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_scythe",
      _ordering = 10011,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_head_helm",
      _ordering = 12001,
      parents = {
         "elona.equip_head"
      }
   },
   {
      _id = "equip_head_hat",
      _ordering = 12002,
      parents = {
         "elona.equip_head"
      }
   },
   {
      _id = "equip_shield_shield",
      _ordering = 14003,
      parents = {
         "elona.equip_shield"
      }
   },
   {
      _id = "equip_body_mail",
      _ordering = 16001,
      parents = {
         "elona.equip_body"
      }
   },
   {
      _id = "equip_body_robe",
      _ordering = 16003,
      parents = {
         "elona.equip_body"
      }
   },
   {
      _id = "equip_leg_heavy_boots",
      _ordering = 18001,
      parents = {
         "elona.equip_leg"
      }
   },
   {
      _id = "equip_leg_shoes",
      _ordering = 18002,
      parents = {
         "elona.equip_leg"
      }
   },
   {
      _id = "equip_back_girdle",
      _ordering = 19001,
      parents = {
         "elona.equip_cloak"
      }
   },
   {
      _id = "equip_back_cloak",
      _ordering = 20001,
      parents = {
         "elona.equip_back"
      }
   },
   {
      _id = "equip_wrist_gauntlet",
      _ordering = 22001,
      parents = {
         "elona.equip_wrist"
      }
   },
   {
      _id = "equip_wrist_glove",
      _ordering = 22003,
      parents = {
         "elona.equip_wrist"
      }
   },
   {
      _id = "equip_ranged_bow",
      _ordering = 24001,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_crossbow",
      _ordering = 24003,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_gun",
      _ordering = 24020,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_laser_gun",
      _ordering = 24021,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_thrown",
      _ordering = 24030,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ammo_arrow",
      _ordering = 25001,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_bolt",
      _ordering = 25002,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_bullet",
      _ordering = 25020,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_energy_cell",
      _ordering = 25030,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ring_ring",
      _ordering = 32001,
      parents = {
         "elona.equip_ring"
      }
   },
   {
      _id = "equip_neck_armor",
      _ordering = 34001,
      parents = {
         "elona.equip_neck"
      }
   },
   {
      _id = "drink_potion",
      _ordering = 52001,
      parents = {
         "elona.drink"
      }
   },
   {
      _id = "drink_alcohol",
      _ordering = 52002,
      parents = {
         "elona.drink"
      }
   },
   {
      _id = "scroll_deed",
      _ordering = 53100,
      parents = {
         "elona.scroll"
      }
   },
   {
      _id = "food_flour",
      _ordering = 57001,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_noodle",
      _ordering = 57002,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_vegetable",
      _ordering = 57003,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_fruit",
      _ordering = 57004,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "crop_herb",
      _ordering = 58005,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "crop_seed",
      _ordering = 58500,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "misc_item_crafting",
      _ordering = 59500,
      parents = {
         "elona.misc_item"
      }
   },
   {
      _id = "furniture_bed", -- sleeping bag/furniture
      _ordering = 60004, -- sleeping bag/furniture
   },
   {
      _id = "furniture_instrument",
      _ordering = 60005,
      parents = {
         "elona.furniture"
      }
   },
   {
      -- This is only used to generate items that appear in random
      -- overworld field maps.
      _id = "junk_in_field", -- subcategory 64000
      _ordering = 64000, -- subcategory 64000
   },
   {
      _id = "junk_town",
      _ordering = 64100,
      parents = {
         "elona.junk"
      }
   },
   {
      _id = "ore_valuable",
      _ordering = 77001,
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

-- Special categories for god offerings where a blanket whitelist doesn't work.
-- For example, some items tagged "fish" can't be offered to Ehekatl (wood
-- piece, garbage, etc.)

-- Mani
data:add {
   _type = "base.item_type",
   _id = "offering_sf",
}

-- Ehekatl
data:add {
   _type = "base.item_type",
   _id = "offering_fish",
}

-- Kumiromi
data:add {
   _type = "base.item_type",
   _id = "offering_vegetable",
}

-- Jure/Opatos
data:add {
   _type = "base.item_type",
   _id = "offering_ore",
}
