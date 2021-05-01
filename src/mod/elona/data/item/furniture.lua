local light = require("mod.elona.data.item.light")
local Magic = require("mod.elona_sys.api.Magic")
local Log = require("api.Log")
local Rand = require("api.Rand")
local Area = require("api.Area")
local Map = require("api.Map")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Enum = require("api.Enum")
local IItemCookingTool = require("mod.elona.api.aspect.IItemCookingTool")
local IItemWell = require("mod.elona.api.aspect.IItemWell")
local ItemHolyWellAspect = require("mod.elona.api.aspect.ItemHolyWellAspect")
local IItemChair = require("mod.elona.api.aspect.IItemChair")

--
-- Furniture
--

data:add {
   _type = "base.item",
   _id = "round_chair",
   elona_id = 77,
   image = "elona.item_round_chair",
   value = 80,
   weight = 900,
   coefficient = 100,

   _ext = {
      IItemChair
   },

   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "bookshelf",
   elona_id = 78,
   image = "elona.item_bookshelf",
   value = 1800,
   weight = 10200,
   level = 12,
   rarity = 600000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "luxury_drawer",
   elona_id = 79,
   image = "elona.item_luxury_drawer",
   value = 6400,
   weight = 8900,
   level = 20,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "rag_doll",
   elona_id = 81,
   image = "elona.item_rag_doll",
   value = 240,
   weight = 350,
   coefficient = 100,

   _ext = {
      IItemChair
   },

   tags = { "fest" },
   random_color = "Furniture",
   categories = {
      "elona.tag_fest",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "toy",
   elona_id = 82,
   image = "elona.item_noble_toy",
   value = 320,
   weight = 320,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "modern_table",
   elona_id = 83,
   image = "elona.item_modern_table",
   value = 2400,
   weight = 6800,
   level = 7,
   rarity = 400000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "dining_table",
   elona_id = 84,
   image = "elona.item_dining_table",
   value = 3800,
   weight = 7000,
   level = 18,
   rarity = 200000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "armor",
   elona_id = 85,
   image = "elona.item_armor",
   value = 1600,
   weight = 8400,
   level = 15,
   rarity = 300000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "lot_of_goods",
   elona_id = 86,
   image = "elona.item_lot_of_goods",
   value = 450,
   weight = 800,
   level = 5,
   coefficient = 100,
   originalnameref2 = "lot",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "lot_of_accessories",
   elona_id = 87,
   image = "elona.item_lot_of_accessories",
   value = 720,
   weight = 750,
   level = 5,
   coefficient = 100,
   originalnameref2 = "lot",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "bar_table_alpha",
   elona_id = 89,
   image = "elona.item_bar_table_alpha",
   value = 1200,
   weight = 7900,
   level = 12,
   rarity = 500000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "bar_table_beta",
   elona_id = 90,
   image = "elona.item_bar_table_beta",
   value = 1200,
   weight = 7900,
   level = 12,
   rarity = 500000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "barrel",
   elona_id = 91,
   image = "elona.item_barrel",
   value = 180,
   weight = 3400,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "modern_chair",
   elona_id = 92,
   image = "elona.item_modern_chair",
   value = 750,
   weight = 1100,
   level = 3,
   rarity = 600000,
   coefficient = 100,

   _ext = {
      IItemChair
   },

   tags = { "sf" },
   random_color = "Furniture",
   categories = {
      "elona.tag_sf",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "pick",
   elona_id = 93,
   image = "elona.item_pick",
   value = 160,
   weight = 1200,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "lantern",
   elona_id = 94,
   image = "elona.item_lantern",
   value = 120,
   weight = 400,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   },
   light = light.lantern
}

data:add {
   _type = "base.item",
   _id = "decorative_armor",
   elona_id = 95,
   image = "elona.item_decorative_armor",
   value = 4200,
   weight = 3800,
   level = 7,
   rarity = 100000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "anvil",
   elona_id = 96,
   image = "elona.item_anvil",
   value = 3500,
   weight = 9500,
   level = 9,
   rarity = 300000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "closed_pot",
   elona_id = 97,
   image = "elona.item_closed_pot",
   value = 140,
   weight = 420,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "open_pot",
   elona_id = 98,
   image = "elona.item_open_pot",
   value = 120,
   weight = 540,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "academic_table",
   elona_id = 99,
   image = "elona.item_academic_table",
   value = 1050,
   weight = 4200,
   rarity = 200000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "rack_of_potions",
   elona_id = 100,
   image = "elona.item_rack_of_potions",
   value = 3800,
   weight = 80,
   level = 13,
   rarity = 200000,
   coefficient = 100,
   originalnameref2 = "rack",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "square_chair",
   elona_id = 101,
   image = "elona.item_square_chair",
   value = 360,
   weight = 1200,
   coefficient = 100,
   random_color = "Furniture",

   _ext = {
      IItemChair
   },

   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "cheap_chair",
   elona_id = 102,
   image = "elona.item_cheap_chair",
   value = 120,
   weight = 6800,
   coefficient = 100,
   random_color = "Furniture",

   _ext = {
      IItemChair
   },

   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "cupboard",
   elona_id = 103,
   image = "elona.item_cupboard",
   value = 2400,
   weight = 7300,
   level = 11,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "barn",
   elona_id = 104,
   image = "elona.item_barn",
   value = 750,
   weight = 8200,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "neat_shelf",
   elona_id = 105,
   image = "elona.item_neat_shelf",
   value = 1800,
   weight = 7600,
   level = 7,
   rarity = 300000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "closet",
   elona_id = 106,
   image = "elona.item_closet",
   value = 1500,
   weight = 6800,
   level = 7,
   rarity = 400000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "variety_of_tools",
   elona_id = 107,
   image = "elona.item_variety_of_tools",
   value = 1050,
   weight = 750,
   rarity = 200000,
   coefficient = 100,
   originalnameref2 = "variety",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "variety_of_goods",
   elona_id = 108,
   image = "elona.item_variety_of_goods",
   value = 1300,
   weight = 820,
   level = 3,
   rarity = 200000,
   coefficient = 100,
   originalnameref2 = "variety",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "variety_of_clothes",
   elona_id = 110,
   image = "elona.item_variety_of_clothes",
   value = 1800,
   weight = 950,
   level = 5,
   rarity = 200000,
   coefficient = 100,
   originalnameref2 = "variety",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "furnace",
   elona_id = 111,
   image = "elona.item_furnace",
   value = 4400,
   weight = 45800,
   level = 17,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.torch_lamp
}

data:add {
   _type = "base.item",
   _id = "sign",
   elona_id = 113,
   image = "elona.item_sign",
   value = 100,
   weight = 3200,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "crossroad_sign",
   elona_id = 114,
   image = "elona.item_crossroad_sign",
   value = 120,
   weight = 3500,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "board",
   elona_id = 115,
   image = "elona.item_board",
   value = 240,
   weight = 9500,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "empty_basket",
   elona_id = 117,
   image = "elona.item_empty_basket",
   value = 20,
   weight = 80,
   coefficient = 100,
   tags = { "fish" },
   random_color = "Furniture",
   categories = {
      "elona.tag_fish",
      "elona.junk"
   }
}

data:add {
   _type = "base.item",
   _id = "show_case_of_breads",
   elona_id = 124,
   image = "elona.item_show_case_of_breads",
   value = 1400,
   weight = 7800,
   rarity = 200000,
   coefficient = 100,
   originalnameref2 = "show case",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "beaker",
   elona_id = 126,
   image = "elona.item_beaker",
   value = 80,
   weight = 210,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "pentagram",
   elona_id = 128,
   image = "elona.item_pentagram",
   value = 3500,
   weight = 1840,
   rarity = 200000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "small_foliage_plant",
   elona_id = 129,
   image = "elona.item_small_foliage_plant",
   value = 850,
   weight = 420,
   level = 7,
   rarity = 300000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "rose",
   elona_id = 130,
   image = "elona.item_rose",
   value = 1050,
   weight = 400,
   level = 9,
   rarity = 300000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "large_foliage_plant",
   elona_id = 131,
   image = "elona.item_large_foliage_plant",
   value = 1800,
   weight = 380,
   level = 11,
   rarity = 300000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "sage",
   elona_id = 132,
   image = "elona.item_sage",
   value = 650,
   weight = 320,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "gazania",
   elona_id = 133,
   image = "elona.item_gazania",
   value = 750,
   weight = 350,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "nerine",
   elona_id = 134,
   image = "elona.item_nerine",
   value = 880,
   weight = 400,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "anemos",
   elona_id = 135,
   image = "elona.item_anemos",
   value = 920,
   weight = 300,
   rarity = 500000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "foxtail_grass",
   elona_id = 136,
   image = "elona.item_foxtail_grass",
   value = 1500,
   weight = 240,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "carnation",
   elona_id = 137,
   image = "elona.item_carnation",
   value = 780,
   weight = 250,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "statue_ornamented_with_plants",
   elona_id = 138,
   image = "elona.item_statue_ornamented_with_plants",
   value = 3400,
   weight = 32000,
   level = 18,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "statue_ornamented_with_flowers",
   elona_id = 139,
   image = "elona.item_statue_ornamented_with_flowers",
   value = 3900,
   weight = 32000,
   level = 20,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "canvas",
   elona_id = 140,
   image = "elona.item_canvas",
   value = 830,
   weight = 1100,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "map",
   elona_id = 141,
   image = "elona.item_map",
   value = 450,
   weight = 240,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "bundle_of_bows",
   elona_id = 143,
   image = "elona.item_bundle_of_bows",
   value = 240,
   weight = 1500,
   coefficient = 100,
   originalnameref2 = "bundle",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "bundle_of_weapons",
   elona_id = 144,
   image = "elona.item_bundle_of_weapons",
   value = 940,
   weight = 2400,
   coefficient = 100,
   originalnameref2 = "bundle",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "decorated_cloth",
   elona_id = 145,
   image = "elona.item_decorated_cloth",
   value = 1400,
   weight = 860,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "decorated_armor",
   elona_id = 146,
   image = "elona.item_decorated_armor",
   value = 1900,
   weight = 4400,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "statue_of_armor",
   elona_id = 147,
   image = "elona.item_statue_of_armor",
   value = 3600,
   weight = 7500,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "statue",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "disorderly_book",
   elona_id = 148,
   image = "elona.item_disorderly_book",
   value = 240,
   weight = 830,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "lot_of_books",
   elona_id = 149,
   image = "elona.item_lot_of_books",
   value = 320,
   weight = 940,
   coefficient = 100,
   originalnameref2 = "lot",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "craft_rack",
   elona_id = 150,
   image = "elona.item_craft_rack",
   value = 4500,
   weight = 8700,
   level = 17,
   rarity = 200000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "craft_book_shelf",
   elona_id = 151,
   image = "elona.item_craft_book_shelf",
   value = 4400,
   weight = 8600,
   level = 17,
   rarity = 200000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "lot_of_alcohols",
   elona_id = 152,
   image = "elona.item_lot_of_alcohols",
   value = 350,
   weight = 320,
   coefficient = 100,
   originalnameref2 = "lot",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "narrow_dining_table",
   elona_id = 156,
   image = "elona.item_narrow_dining_table",
   value = 1200,
   weight = 9700,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "elegant_table",
   elona_id = 157,
   image = "elona.item_elegant_table",
   value = 3500,
   weight = 8600,
   level = 14,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "gorgeous_candlestick",
   elona_id = 158,
   image = "elona.item_gorgeous_candlestick",
   value = 800,
   weight = 860,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.lamp
}

data:add {
   _type = "base.item",
   _id = "simple_shelf",
   elona_id = 159,
   image = "elona.item_simple_shelf",
   value = 1200,
   weight = 11000,
   rarity = 500000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "messy_cloth",
   elona_id = 162,
   image = "elona.item_messy_cloth",
   value = 430,
   weight = 1200,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "silk_cloth",
   elona_id = 163,
   image = "elona.item_silk_cloth",
   value = 1400,
   weight = 340,
   level = 4,
   rarity = 500000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "collapsed_grave",
   elona_id = 164,
   image = "elona.item_collapsed_grave",
   value = 1800,
   weight = 400000,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.junk_in_field",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "crumbled_grave",
   elona_id = 165,
   image = "elona.item_crumbled_grave",
   value = 1700,
   weight = 400000,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.junk_in_field",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "grave_of_ornamented_with_flowers",
   elona_id = 166,
   image = "elona.item_grave_of_ornamented_with_flowers",
   value = 3250,
   weight = 650000,
   level = 5,
   rarity = 50000,
   coefficient = 100,
   originalnameref2 = "grave",
   categories = {
      "elona.junk_in_field",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "brand_new_grave",
   elona_id = 167,
   image = "elona.item_brand_new_grave",
   value = 2500,
   weight = 650000,
   level = 5,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "solemn_tomb",
   elona_id = 168,
   image = "elona.item_solemn_tomb",
   value = 4400,
   weight = 650000,
   level = 10,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "ancient_tomb",
   elona_id = 169,
   image = "elona.item_grave",
   value = 6500,
   weight = 650000,
   level = 20,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "old_grave",
   elona_id = 170,
   image = "elona.item_old_grave",
   value = 2400,
   weight = 650000,
   level = 10,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "stack_of_dishes",
   elona_id = 189,
   image = "elona.item_stack_of_dishes",
   value = 120,
   weight = 450,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "figurine_of_warrior",
   elona_id = 237,
   image = "elona.item_figurine_of_warrior",
   value = 2000,
   weight = 240,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "figurine",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "figurine_of_sword",
   elona_id = 238,
   image = "elona.item_figurine_of_sword",
   value = 2000,
   weight = 240,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "figurine",
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "long_pillar",
   elona_id = 276,
   image = "elona.item_long_pillar",
   value = 2600,
   weight = 350000,
   level = 8,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "broken_pillar",
   elona_id = 277,
   image = "elona.item_broken_pillar",
   value = 1300,
   weight = 300000,
   level = 4,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "street_lamp",
   elona_id = 278,
   image = "elona.item_street_lamp",
   value = 1200,
   weight = 300000,
   level = 10,
   rarity = 200000,
   coefficient = 100,
   tags = { "sf" },
   categories = {
      "elona.tag_sf",
      "elona.furniture"
   },
   light = light.town_light
}

data:add {
   _type = "base.item",
   _id = "water_tub",
   elona_id = 279,
   image = "elona.item_water_tub",
   value = 380,
   weight = 300000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "comfortable_table",
   elona_id = 280,
   image = "elona.item_comfortable_table",
   value = 1800,
   weight = 9800,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "inner_tube",
   elona_id = 281,
   image = "elona.item_inner_tube",
   value = 380,
   weight = 1500,
   coefficient = 100,
   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "mysterious_map",
   elona_id = 282,
   image = "elona.item_treasure_map",
   value = 380,
   weight = 180,
   coefficient = 100,
   can_read_multiple_times = true,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "well_kept_armor",
   elona_id = 291,
   image = "elona.item_well_kept_armor",
   value = 1500,
   weight = 12000,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "rack_of_goods",
   elona_id = 292,
   image = "elona.item_rack_of_goods",
   value = 1800,
   weight = 6800,
   rarity = 500000,
   coefficient = 100,
   originalnameref2 = "rack",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "rack_of_accessories",
   elona_id = 293,
   image = "elona.item_rack_of_accessories",
   value = 2000,
   weight = 7500,
   rarity = 500000,
   coefficient = 100,
   originalnameref2 = "rack",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "towel",
   elona_id = 294,
   image = "elona.item_towel",
   value = 320,
   weight = 1080,
   coefficient = 100,
   tags = { "fest" },
   categories = {
      "elona.tag_fest",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "ragged_table",
   elona_id = 295,
   image = "elona.item_ragged_table",
   value = 890,
   weight = 4500,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "cabinet",
   elona_id = 296,
   image = "elona.item_cabinet",
   value = 2400,
   weight = 15000,
   level = 18,
   rarity = 250000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "vase",
   elona_id = 298,
   image = "elona.item_vase",
   value = 2000,
   weight = 2400,
   level = 7,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.item_middle
}

data:add {
   _type = "base.item",
   _id = "high_grade_dresser",
   elona_id = 299,
   image = "elona.item_high_grade_dresser",
   value = 5500,
   weight = 9000,
   level = 14,
   rarity = 150000,
   coefficient = 100,

   elona_function = 19,

   categories = {
      "elona.furniture"
   },

   light = light.crystal_middle
}

data:add {
   _type = "base.item",
   _id = "neat_bar_table",
   elona_id = 300,
   image = "elona.item_neat_bar_table",
   value = 1900,
   weight = 8500,
   level = 7,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "chest_of_clothes",
   elona_id = 302,
   image = "elona.item_chest_of_clothes",
   value = 1500,
   weight = 6800,
   level = 4,
   rarity = 500000,
   coefficient = 100,
   originalnameref2 = "chest",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "cheap_rack",
   elona_id = 308,
   image = "elona.item_cheap_rack",
   value = 1200,
   weight = 9000,
   rarity = 800000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "dresser",
   elona_id = 309,
   image = "elona.item_dresser",
   value = 2400,
   weight = 8000,
   level = 7,
   rarity = 250000,
   coefficient = 100,

   elona_function = 19,

   categories = {
      "elona.furniture"
   },

   light = light.item_middle
}

data:add {
   _type = "base.item",
   _id = "bathtub",
   elona_id = 311,
   image = "elona.item_bathtub",
   value = 4800,
   weight = 28000,
   level = 19,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "pachisuro_machine",
   elona_id = 312,
   image = "elona.item_pachisuro_machine",
   value = 2800,
   weight = 14000,
   on_use = function() end,
   fltselect = 1,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "casino_table",
   elona_id = 313,
   image = "elona.item_casino_table",
   value = 2800,
   weight = 24000,
   on_use = function() end,
   fltselect = 1,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "slot_machine",
   elona_id = 314,
   image = "elona.item_slot_machine",
   value = 2000,
   weight = 12000,
   on_use = function() end,
   fltselect = 1,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "darts_board",
   elona_id = 315,
   image = "elona.item_darts_board",
   value = 1800,
   weight = 8900,
   on_use = function() end,
   fltselect = 1,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "big_foliage_plant",
   elona_id = 316,
   image = "elona.item_big_foliage_plant",
   value = 3200,
   weight = 1200,
   level = 18,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "old_shelf",
   elona_id = 317,
   image = "elona.item_old_shelf",
   value = 890,
   weight = 7600,
   rarity = 600000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "old_bookshelf",
   elona_id = 318,
   image = "elona.item_old_bookshelf",
   value = 1020,
   weight = 8900,
   rarity = 600000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "cheap_table",
   elona_id = 320,
   image = "elona.item_cheap_table",
   value = 900,
   weight = 6800,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "neat_rack",
   elona_id = 321,
   image = "elona.item_neat_rack",
   value = 1480,
   weight = 8800,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "simple_dresser",
   elona_id = 322,
   image = "elona.item_simple_dresser",
   value = 2200,
   weight = 12000,
   level = 4,
   rarity = 200000,
   coefficient = 100,

   elona_function = 19,

   categories = {
      "elona.furniture"
   },

   light = light.item_middle
}

data:add {
   _type = "base.item",
   _id = "big_cupboard",
   elona_id = 323,
   image = "elona.item_big_cupboard",
   value = 2800,
   weight = 8900,
   level = 7,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "sacred_altar",
   elona_id = 324,
   image = "elona.item_sacred_altar",
   value = 1500,
   weight = 15000,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "simple_rack",
   elona_id = 326,
   image = "elona.item_simple_rack",
   value = 1400,
   weight = 8900,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "wide_chair",
   elona_id = 327,
   image = "elona.item_wide_chair",
   value = 600,
   weight = 6400,
   rarity = 500000,
   coefficient = 100,

   _ext = {
      IItemChair
   },

   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "upright_piano",
   elona_id = 328,
   image = "elona.item_piano",
   value = 4600,
   weight = 29000,
   level = 18,
   rarity = 200000,
   coefficient = 100,

   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   params = { instrument_quality = 150 },
   categories = {
      "elona.furniture"
   },
   light = light.item_middle
}

data:add {
   _type = "base.item",
   _id = "statue_of_cross",
   elona_id = 329,
   image = "elona.item_statue_of_cross",
   value = 1500,
   weight = 15600,
   coefficient = 100,
   originalnameref2 = "statue",
   categories = {
      "elona.furniture"
   },
   light = light.item_middle
}

data:add {
   _type = "base.item",
   _id = "dress",
   elona_id = 331,
   image = "elona.item_dress",
   value = 1440,
   weight = 1050,
   level = 3,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "table",
   elona_id = 332,
   image = "elona.item_table",
   value = 1200,
   weight = 4900,
   level = 3,
   rarity = 20000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "throne",
   elona_id = 334,
   image = "elona.item_throne",
   value = 6800,
   weight = 35000,
   level = 22,
   rarity = 150000,
   coefficient = 100,

   _ext = {
      IItemChair
   },

   categories = {
      "elona.furniture"
   },

   light = light.item
}

data:add {
   _type = "base.item",
   _id = "golden_pedestal",
   elona_id = 335,
   image = "elona.item_golden_pedestal",
   value = 1200,
   weight = 15000,
   level = 8,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.lamp
}

data:add {
   _type = "base.item",
   _id = "golden_statue",
   elona_id = 336,
   image = "elona.item_golden_statue",
   value = 3200,
   weight = 21000,
   level = 18,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "rune",
   elona_id = 343,
   image = "elona.item_rune",
   value = 780,
   weight = 500,
   on_use = function() end,
   coefficient = 100,

   elona_function = 22,

   categories = {
      "elona.furniture"
   },

   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "red_treasure_machine",
   elona_id = 413,
   image = "elona.item_red_treasure_machine",
   value = 15000,
   weight = 140000,
   on_use = function() end,
   level = 18,
   fltselect = 1,
   rarity = 50000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "blue_treasure_machine",
   elona_id = 414,
   image = "elona.item_blue_treasure_machine",
   value = 30000,
   weight = 140000,
   on_use = function() end,
   level = 18,
   fltselect = 1,
   rarity = 50000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "machine",
   elona_id = 486,
   image = "elona.item_machine",
   value = 3600,
   weight = 150000,
   level = 5,
   rarity = 200000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf"
   },

   light = light.item
}

data:add {
   _type = "base.item",
   _id = "computer",
   elona_id = 487,
   image = "elona.item_computer",
   value = 4400,
   weight = 45000,
   level = 12,
   rarity = 300000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf"
   },

   light = light.item
}

data:add {
   _type = "base.item",
   _id = "training_machine",
   elona_id = 488,
   image = "elona.item_training_machine",
   value = 2400,
   weight = 120000,
   level = 11,
   rarity = 200000,
   coefficient = 100,

   on_use = function(self, params)
      -- >>>>>>>> shade2/action.hsp:1850 	case effTrain ...
      params.chara:start_activity("elona.training", {skill_id="random",item=self})
      return "turn_end"
      -- <<<<<<<< shade2/action.hsp:1853 	swbreak ..
   end,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf",
   }
}

data:add {
   _type = "base.item",
   _id = "camera",
   elona_id = 489,
   image = "elona.item_camera",
   value = 1600,
   weight = 1500,
   rarity = 100000,
   coefficient = 100,

   tags = { "sf", "fest" },

   categories = {
      "elona.tag_sf",
      "elona.tag_fest",
      "elona.furniture",
      "elona.offering_sf",
   }
}

data:add {
   _type = "base.item",
   _id = "microwave_oven",
   elona_id = 490,
   image = "elona.item_microwave_oven",
   value = 3200,
   weight = 150000,
   level = 15,
   rarity = 100000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf"
   }
}

data:add {
   _type = "base.item",
   _id = "server",
   elona_id = 491,
   image = "elona.item_server",
   value = 2400,
   weight = 95000,
   level = 18,
   rarity = 100000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf"
   }
}

data:add {
   _type = "base.item",
   _id = "storage",
   elona_id = 492,
   image = "elona.item_storage",
   value = 3100,
   weight = 14000,
   level = 11,
   rarity = 100000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf"
   }
}

data:add {
   _type = "base.item",
   _id = "trash_can",
   elona_id = 493,
   image = "elona.item_trash_can",
   value = 1000,
   weight = 8000,
   rarity = 100000,
   coefficient = 100,
   tags = { "sf" },
   categories = {
      "elona.tag_sf",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "chip",
   elona_id = 494,
   image = "elona.item_chip",
   value = 1200,
   weight = 800,
   rarity = 500000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf",
   }
}

data:add {
   _type = "base.item",
   _id = "blank_disc",
   elona_id = 495,
   image = "elona.item_playback_disc",
   value = 1000,
   weight = 500,
   rarity = 500000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture",
      "elona.offering_sf"
   },

   light = light.item
}

data:add {
   _type = "base.item",
   _id = "furnance",
   elona_id = 531,
   image = "elona.item_furnance",
   value = 8500,
   weight = 68000,
   level = 19,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.stove
}

data:add {
   _type = "base.item",
   _id = "fireplace",
   elona_id = 532,
   image = "elona.item_fireplace",
   value = 9400,
   weight = 45000,
   level = 23,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.stove
}

data:add {
   _type = "base.item",
   _id = "stove",
   elona_id = 533,
   image = "elona.item_stove",
   value = 7500,
   weight = 85000,
   level = 22,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.stove
}

data:add {
   _type = "base.item",
   _id = "giant_foliage_plant",
   elona_id = 534,
   image = "elona.item_giant_foliage_plant",
   value = 4500,
   weight = 15000,
   level = 18,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "big_table",
   elona_id = 535,
   image = "elona.item_big_table",
   value = 2400,
   weight = 5800,
   level = 5,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "painting_of_madam",
   elona_id = 536,
   image = "elona.item_painting_of_madam",
   value = 8500,
   weight = 2000,
   level = 15,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "painting",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "painting_of_landscape",
   elona_id = 537,
   image = "elona.item_painting_of_landscape",
   value = 8200,
   weight = 500,
   level = 14,
   rarity = 100000,
   coefficient = 100,
   originalnameref2 = "painting",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "painting_of_sunflower",
   elona_id = 538,
   image = "elona.item_painting_of_sunflower",
   value = 12000,
   weight = 450,
   level = 28,
   rarity = 50000,
   coefficient = 100,
   originalnameref2 = "painting",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "statue_of_cat",
   elona_id = 539,
   image = "elona.item_statue_of_cat",
   value = 25000,
   weight = 48000,
   level = 30,
   rarity = 50000,
   coefficient = 100,
   originalnameref2 = "statue",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "black_crystal",
   elona_id = 540,
   image = "elona.item_black_crystal",
   value = 7000,
   weight = 2500,
   level = 20,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "snow_man",
   elona_id = 541,
   image = "elona.item_snow_man",
   value = 200,
   weight = 8500,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "modern_rack",
   elona_id = 580,
   image = "elona.item_modern_rack",
   value = 1600,
   weight = 10200,
   level = 12,
   rarity = 600000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "candle",
   elona_id = 584,
   image = "elona.item_candle",
   value = 1500,
   weight = 200,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   },
   light = light.candle
}

data:add {
   _type = "base.item",
   _id = "fancy_lamp",
   elona_id = 585,
   image = "elona.item_fancy_lamp",
   value = 4500,
   weight = 1500,
   level = 20,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.lamp
}

data:add {
   _type = "base.item",
   _id = "modern_lamp_a",
   elona_id = 586,
   image = "elona.item_modern_lamp_a",
   value = 7200,
   weight = 250000,
   level = 30,
   rarity = 200000,
   coefficient = 100,
   tags = { "sf" },
   categories = {
      "elona.tag_sf",
      "elona.furniture"
   },
   light = light.port_light
}

data:add {
   _type = "base.item",
   _id = "mini_snow_man",
   elona_id = 591,
   image = "elona.item_mini_snow_man",
   value = 400,
   weight = 8500,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "snow_barrel",
   elona_id = 592,
   image = "elona.item_snow_barrel",
   value = 180,
   weight = 3400,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "modern_lamp_b",
   elona_id = 593,
   image = "elona.item_modern_lamp_b",
   value = 7200,
   weight = 250000,
   level = 30,
   rarity = 100000,
   coefficient = 100,
   tags = { "sf" },
   categories = {
      "elona.tag_sf",
      "elona.furniture"
   },
   light = light.port_light_snow
}

data:add {
   _type = "base.item",
   _id = "statue_of_holy_cross",
   elona_id = 594,
   image = "elona.item_statue_of_holy_cross",
   value = 18000,
   weight = 12000,
   level = 40,
   rarity = 50000,
   coefficient = 100,
   originalnameref2 = "statue",
   categories = {
      "elona.furniture"
   },
   light = light.port_light_snow
}

data:add {
   _type = "base.item",
   _id = "pillar",
   elona_id = 595,
   image = "elona.item_pillar",
   value = 2500,
   weight = 16000,
   level = 20,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "stained_glass_window",
   elona_id = 596,
   image = "elona.item_stained_glass_window",
   value = 1800,
   weight = 4800,
   level = 10,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "presidents_chair",
   elona_id = 603,
   image = "elona.item_presidents_chair",
   value = 12000,
   weight = 2400,
   level = 35,
   rarity = 10000,
   coefficient = 100,

   _ext = {
      IItemChair
   },
   is_precious = true,
   medal_value = 20,
   categories = {
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "green_plant",
   elona_id = 604,
   image = "elona.item_green_plant",
   value = 400,
   weight = 800,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "money_tree",
   elona_id = 605,
   image = "elona.item_money_tree",
   value = 2200,
   weight = 1200,
   level = 15,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "giant_cactus",
   elona_id = 607,
   image = "elona.item_giant_cactus",
   value = 2600,
   weight = 4200,
   rarity = 300000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "square_window",
   elona_id = 608,
   image = "elona.item_square_window",
   value = 500,
   weight = 1500,
   rarity = 600000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.window
}

data:add {
   _type = "base.item",
   _id = "window",
   elona_id = 609,
   image = "elona.item_window",
   value = 700,
   weight = 1600,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.window
}

data:add {
   _type = "base.item",
   _id = "triangle_plant",
   elona_id = 610,
   image = "elona.item_triangle_plant",
   value = 1500,
   weight = 5600,
   level = 18,
   rarity = 600000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "nice_window",
   elona_id = 612,
   image = "elona.item_nice_window",
   value = 1000,
   weight = 2000,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.window
}

data:add {
   _type = "base.item",
   _id = "flower_arch",
   elona_id = 614,
   image = "elona.item_flower_arch",
   value = 2000,
   weight = 8000,
   level = 15,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "shrine_gate",
   elona_id = 625,
   image = "elona.item_shrine_gate",
   value = 7500,
   weight = 8000,
   fltselect = 1,
   rarity = 10000,
   coefficient = 100,

   is_precious = true,

   medal_value = 11,

   categories = {
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "moon_gate",
   elona_id = 631,
   image = "elona.item_moon_gate",
   value = 50,
   weight = 5000000,
   level = 15,
   fltselect = 1,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   },
   light = light.gate,

   on_descend = function(self)
      Log.error("TODO")
   end
}

data:add {
   _type = "base.item",
   _id = "rice_barrel",
   elona_id = 642,
   image = "elona.item_rice_barrel",
   value = 500,
   weight = 4800,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "decorated_window",
   elona_id = 644,
   image = "elona.item_decorated_window",
   value = 2400,
   weight = 2000,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.window
}

data:add {
   _type = "base.item",
   _id = "king_drawer",
   elona_id = 645,
   image = "elona.item_king_drawer",
   value = 9500,
   weight = 11000,
   level = 35,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "menu_board",
   elona_id = 646,
   image = "elona.item_menu_board",
   value = 1800,
   weight = 4500,
   level = 5,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "black_board",
   elona_id = 647,
   image = "elona.item_black_board",
   value = 5000,
   weight = 7800,
   level = 18,
   rarity = 200000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "sofa",
   elona_id = 648,
   image = "elona.item_sofa",
   value = 2500,
   weight = 5000,
   level = 5,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",

   _ext = {
      IItemChair
   },

   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "flowerbed",
   elona_id = 649,
   image = "elona.item_flowerbed",
   value = 1500,
   weight = 4000,
   level = 10,
   rarity = 500000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "craft_cupboard",
   elona_id = 651,
   image = "elona.item_craft_cupboard",
   value = 4800,
   weight = 8400,
   level = 25,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "sink",
   elona_id = 652,
   image = "elona.item_sink",
   value = 3500,
   weight = 15000,
   level = 15,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "junk",
   elona_id = 653,
   image = "elona.item_junk",
   value = 600,
   weight = 150000,
   rarity = 100000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "eastern_lamp",
   elona_id = 656,
   image = "elona.item_eastern_lamp",
   value = 3000,
   weight = 7900,
   level = 12,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.candle_low
}

data:add {
   _type = "base.item",
   _id = "eastern_window",
   elona_id = 657,
   image = "elona.item_eastern_window",
   value = 3500,
   weight = 1200,
   level = 14,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.window
}

data:add {
   _type = "base.item",
   _id = "chochin",
   elona_id = 658,
   image = "elona.item_chochin",
   value = 2500,
   weight = 500,
   level = 14,
   rarity = 500000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   },
   light = light.window_red
}

data:add {
   _type = "base.item",
   _id = "partition",
   elona_id = 659,
   image = "elona.item_partition",
   value = 1000,
   weight = 1000,
   level = 5,
   rarity = 800000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "eastern_partition",
   elona_id = 694,
   image = "elona.item_eastern_partition",
   value = 2000,
   weight = 1200,
   level = 10,
   rarity = 800000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "gift",
   elona_id = 729,
   image = "elona.item_gift",
   value = 2500,
   weight = 1000,
   rarity = 5000,
   coefficient = 0,

   params = { gift_value = 0 },

   on_init_params = function(self, params)
      -- >>>>>>>> shade2/item.hsp:70 	giftValue=10,20,30,50,75,100 ..
      local GIFT_VALUES = { 10, 20, 30, 50, 75, 100 }
      -- <<<<<<<< shade2/item.hsp:70 	giftValue=10,20,30,50,75,100 ..
      -- >>>>>>>> shade2/item.hsp:656 	if iId(ci)=idGift{	 ..
      local idx = Rand.rnd(Rand.rnd(Rand.rnd(#GIFT_VALUES)+1)+1)+1
      self.params.gift_value = GIFT_VALUES[idx]
      assert(self.params.gift_value)
      -- <<<<<<<< shade2/item.hsp:659 		} ..
   end,

   tags = { "spshop" },
   categories = {
      "elona.tag_spshop",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "upstairs",
   elona_id = 750,
   image = "elona.item_upstairs",
   value = 150000,
   weight = 7500,
   fltselect = 1,
   rarity = 20000,
   coefficient = 0,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   },

   on_ascend = function(self, params)
      -- >>>>>>>> shade2/action.hsp:811 		if val=2:if mapItemFind(cX(cc),cY(cc),idUpstairs ...
      local map = self:containing_map()
      if map == nil then
         return nil
      end

      if map.uid ~= save.base.home_map_uid then
         return nil
      end

      -- TODO just return InstancedArea
      local area_meta = Area.for_map(map)
      if area_meta == nil then
         return
      end

      if Map.floor_number(map) <= 1 then
         Gui.mes("action.use_stairs.cannot_go.up")
         return "player_turn_query"
      end

      Gui.mes_c("TODO", "Yellow")
      -- <<<<<<<< shade2/action.hsp:811 		if val=2:if mapItemFind(cX(cc),cY(cc),idUpstairs ..
   end
}

data:add {
   _type = "base.item",
   _id = "downstairs",
   elona_id = 751,
   image = "elona.item_downstairs",
   value = 150000,
   weight = 7500,
   fltselect = 1,
   rarity = 20000,
   coefficient = 0,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   },

   on_descend = function(self)
      -- >>>>>>>> shade2/action.hsp:810 		if val=1:if mapItemFind(cX(cc),cY(cc),idDownstai ...
      local map = self:containing_map()
      if map == nil then
         return nil
      end

      if map.uid ~= save.base.home_map_uid then
         return nil
      end

      -- TODO just return InstancedArea
      local area_meta = Area.for_map(map)
      if area_meta == nil then
         return
      end

      local area = assert(Area.get(area_meta.uid))
      if Map.floor_number(map) >= area:deepest_floor() then
         Gui.mes("action.use_stairs.cannot_go.down")
         return "player_turn_query"
      end

      Gui.mes_c("TODO", "Yellow")
      -- <<<<<<<< shade2/action.hsp:810 		if val=1:if mapItemFind(cX(cc),cY(cc),idDownstai ..
   end
}

data:add {
   _type = "base.item",
   _id = "kotatsu",
   elona_id = 753,
   image = "elona.item_kotatsu",
   value = 7800,
   weight = 9800,
   level = 28,
   fltselect = 1,
   rarity = 10000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.no_generate",
      "elona.furniture"
   },

   on_descend = function(self, params)
      -- >>>>>>>> shade2/action.hsp:801 	if val=1:if mapItemFind(cX(cc),cY(cc),idKotatsu)! ...
      Gui.mes("action.use_stairs.kotatsu.prompt")
      if not Input.yes_no() then
         return "player_turn_query"
      end
      Gui.mes("action.use_stairs.kotatsu.use")
      params.chara:add_effect_turns("elona.blindness", 2)
      return "turn_end"
      -- <<<<<<<< shade2/action.hsp:807 	} ..
   end
}

data:add {
   _type = "base.item",
   _id = "daruma",
   elona_id = 754,
   image = "elona.item_daruma",
   value = 3200,
   weight = 720,
   fltselect = 1,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "festival_wreath",
   elona_id = 762,
   image = "elona.item_festival_wreath",
   value = 760,
   weight = 280,
   level = 25,
   fltselect = 1,
   rarity = 5000,
   coefficient = 100,
   tags = { "fest" },
   categories = {
      "elona.tag_fest",
      "elona.no_generate",
      "elona.furniture"
   },
   light = light.crystal_high
}

data:add {
   _type = "base.item",
   _id = "pedestal",
   elona_id = 763,
   image = "elona.item_pedestal",
   value = 3600,
   weight = 85000,
   level = 15,
   rarity = 40000,
   coefficient = 100,
   random_color = "Furniture",
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "counter",
   elona_id = 764,
   image = "elona.item_counter",
   value = 1200,
   weight = 9900,
   level = 5,
   rarity = 25000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "red_stall",
   elona_id = 765,
   image = "elona.item_red_stall",
   value = 3800,
   weight = 48500,
   level = 30,
   rarity = 10000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "blue_stall",
   elona_id = 766,
   image = "elona.item_blue_stall",
   value = 3800,
   weight = 48500,
   level = 30,
   rarity = 10000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "new_years_decoration",
   elona_id = 768,
   image = "elona.item_new_years_decoration",
   value = 400,
   weight = 150,
   level = 10,
   fltselect = 1,
   rarity = 5000,
   coefficient = 100,
   tags = { "fest" },
   categories = {
      "elona.tag_fest",
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "miniature_tree",
   elona_id = 769,
   image = "elona.item_miniature_tree",
   value = 1650,
   weight = 530,
   level = 10,
   fltselect = 1,
   rarity = 5000,
   coefficient = 100,
   tags = { "fest" },
   categories = {
      "elona.tag_fest",
      "elona.no_generate",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "large_bookshelf",
   elona_id = 773,
   image = "elona.item_large_bookshelf",
   value = 2400,
   weight = 15000,
   level = 18,
   rarity = 400000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "luxury_cabinet",
   elona_id = 774,
   image = "elona.item_luxury_cabinet",
   value = 7200,
   weight = 23800,
   level = 24,
   rarity = 150000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "luxury_sofa",
   elona_id = 778,
   image = "elona.item_luxury_sofa",
   value = 4900,
   weight = 9000,
   level = 15,
   rarity = 100000,
   coefficient = 100,
   random_color = "Furniture",

   _ext = {
      IItemChair
   },

   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "deer_head",
   elona_id = 779,
   image = "elona.item_deer_head",
   value = 16000,
   weight = 1800,
   level = 32,
   rarity = 10000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "fur_carpet",
   elona_id = 780,
   image = "elona.item_fur_carpet",
   value = 23000,
   weight = 4200,
   level = 45,
   rarity = 10000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "dish",
   elona_id = 782,
   image = "elona.item_dish",
   value = 100,
   weight = 150,
   rarity = 250000,
   coefficient = 100,
   categories = {
      "elona.furniture"
   }
}

--
-- Well
--

data:add {
   _type = "base.item",
   _id = "well",
   elona_id = 109,
   image = "elona.item_well",
   value = 1800,
   weight = 350000,
   coefficient = 100,

   categories = {
      "elona.furniture_well"
   },

   light = light.item,

   _ext = {
      IItemWell
   }
}

data:add {
   _type = "base.item",
   _id = "fountain",
   elona_id = 173,
   image = "elona.item_fountain",
   value = 2400,
   weight = 600000,
   fltselect = 1,
   coefficient = 100,

   categories = {
      "elona.furniture_well",
      "elona.no_generate"
   },

   _ext = {
      IItemWell
   }
}

data:add {
   _type = "base.item",
   _id = "holy_well",
   elona_id = 602,
   image = "elona.item_holy_well",
   value = 185000,
   weight = 350000,
   fltselect = 1,
   rarity = 50000,
   coefficient = 100,

   categories = {
      "elona.furniture_well",
      "elona.no_generate"
   },

   light = light.item,

   events = {
      {
         id = "elona.on_item_created_from_wish",
         name = "Replace with water",

         callback = function(self, params)
            -- >>>>>>>> shade2/command.hsp:1597 		if iId(ci)=idHolyWell:iNum(ci)=0:flt:item_create ..
            local water = Item.create("elona.water", nil, nil, { ownerless = true, amount = 3 })
            self:replace_with(water)
            Gui.mes("wish.it_is_sold_out")
            -- <<<<<<<< shade2/command.hsp:1597 		if iId(ci)=idHolyWell:iNum(ci)=0:flt:item_create ..
         end
      },
   },

   _ext = {
      [IItemWell] = {
         _impl = ItemHolyWellAspect
      }
   }
}

data:add {
   _type = "base.item",
   _id = "toilet",
   elona_id = 650,
   image = "elona.item_toilet",
   value = 1000,
   weight = 12000,
   level = 4,
   rarity = 500000,
   coefficient = 100,
   random_color = "Furniture",

   categories = {
      "elona.furniture_well"
   },

   _ext = {
      IItemWell
   }
}

--
-- Altar
--

data:add {
   _type = "base.item",
   _id = "altar",
   elona_id = 171,
   image = "elona.item_ceremony_altar",
   value = 1500,
   weight = 500000,
   fltselect = 1,
   coefficient = 100,

   params = { altar = { god_id = "" } },

   categories = {
      "elona.furniture_altar",
      "elona.no_generate"
   },

   light = light.candle_low
}

data:add {
   _type = "base.item",
   _id = "ceremony_altar",
   elona_id = 172,
   image = "elona.item_ceremony_altar",
   value = 1600,
   weight = 500000,
   fltselect = 1,
   coefficient = 100,
   categories = {
      "elona.furniture_altar",
      "elona.no_generate"
   },
   light = light.candle_low
}

--
-- Useable
--

--
-- Cooking Tool
--

data:add {
   _type = "base.item",
   _id = "oven",
   elona_id = 112,
   image = "elona.item_oven",
   value = 8500,
   weight = 14000,
   level = 22,
   rarity = 150000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture"
   },

   _ext = {
      [IItemCookingTool] = {
         cooking_quality = 150
      }
   }
}

data:add {
   _type = "base.item",
   _id = "food_maker",
   elona_id = 142,
   image = "elona.item_food_maker",
   value = 7800,
   weight = 17400,
   level = 14,
   rarity = 150000,
   coefficient = 100,

   categories = {
      "elona.furniture"
   },

   _ext = {
      [IItemCookingTool] = {
         cooking_quality = 200
      }
   }
}

data:add {
   _type = "base.item",
   _id = "kitchen",
   elona_id = 153,
   image = "elona.item_kitchen",
   value = 1200,
   weight = 14000,
   level = 4,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",

   categories = {
      "elona.furniture"
   },

   _ext = {
      [IItemCookingTool] = {
         cooking_quality = 100
      }
   }
}

data:add {
   _type = "base.item",
   _id = "washstand",
   elona_id = 154,
   image = "elona.item_washstand",
   value = 1100,
   weight = 15000,
   level = 4,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",

   categories = {
      "elona.furniture"
   },

   _ext = {
      [IItemCookingTool] = {
         cooking_quality = 100
      }
   }
}

data:add {
   _type = "base.item",
   _id = "kitchen_oven",
   elona_id = 155,
   image = "elona.item_kitchen_oven",
   value = 1500,
   weight = 14000,
   level = 4,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",

   categories = {
      "elona.furniture"
   },

   _ext = {
      [IItemCookingTool] = {
         cooking_quality = 100
      }
   }
}

data:add {
   _type = "base.item",
   _id = "food_processor",
   elona_id = 306,
   image = "elona.item_food_processor",
   value = 5200,
   weight = 34000,
   rarity = 200000,
   coefficient = 100,

   tags = { "sf" },

   categories = {
      "elona.tag_sf",
      "elona.furniture"
   },

   _ext = {
      [IItemCookingTool] = {
         cooking_quality = 200
      }
   }
}

data:add {
   _type = "base.item",
   _id = "barbecue_set",
   elona_id = 606,
   image = "elona.item_barbecue_set",
   value = 9500,
   weight = 8250,
   level = 25,
   rarity = 150000,
   coefficient = 100,

   categories = {
      "elona.furniture"
   },

   _ext = {
      [IItemCookingTool] = {
         cooking_quality = 225
      }
   }
}

--
-- Bed
--

data:add {
   _type = "base.item",
   _id = "boring_bed",
   elona_id = 80,
   image = "elona.item_bed",
   value = 1400,
   weight = 15000,
   level = 5,
   coefficient = 100,
   random_color = "Furniture",

   params = { bed_quality = 100 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "bunk_bed",
   elona_id = 174,
   image = "elona.item_bunk_bed",
   value = 2200,
   weight = 12400,
   level = 5,
   rarity = 100000,
   coefficient = 100,

   params = { bed_quality = 110 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "luxury_bed",
   elona_id = 297,
   image = "elona.item_luxury_bed",
   value = 4500,
   weight = 17500,
   level = 15,
   rarity = 200000,
   coefficient = 100,

   params = { bed_quality = 150 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "giant_bed",
   elona_id = 303,
   image = "elona.item_giant_bed",
   value = 3800,
   weight = 15000,
   level = 12,
   rarity = 400000,
   coefficient = 100,

   params = { bed_quality = 120 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "plain_bed",
   elona_id = 304,
   image = "elona.item_plain_bed",
   value = 1200,
   weight = 13000,
   coefficient = 100,

   params = { bed_quality = 100 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "coffin",
   elona_id = 305,
   image = "elona.item_coffin",
   value = 2400,
   weight = 8900,
   level = 18,
   rarity = 100000,
   coefficient = 100,

   params = { bed_quality = 130 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "soft_bed",
   elona_id = 307,
   image = "elona.item_soft_bed",
   value = 2200,
   weight = 12000,
   rarity = 200000,
   coefficient = 100,

   params = { bed_quality = 130 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "clean_bed",
   elona_id = 310,
   image = "elona.item_clean_bed",
   value = 1500,
   weight = 9500,
   rarity = 500000,
   coefficient = 100,

   params = { bed_quality = 130 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "cheap_bed",
   elona_id = 319,
   image = "elona.item_cheap_bed",
   value = 880,
   weight = 2800,
   rarity = 600000,
   coefficient = 100,

   params = { bed_quality = 0 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "comfortable_bed",
   elona_id = 325,
   image = "elona.item_comfortable_bed",
   value = 2800,
   weight = 10000,
   level = 9,
   rarity = 200000,
   coefficient = 100,

   params = { bed_quality = 130 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "sleeping_bag",
   elona_id = 428,
   image = "elona.item_sleeping_bag",
   value = 800,
   weight = 2400,
   coefficient = 0,

   params = { bed_quality = 0 },

   categories = {
      no_implicit = true,
      "elona.misc_item",
      "elona.furniture_bed",
   },
}

data:add {
   _type = "base.item",
   _id = "kings_bed",
   elona_id = 613,
   image = "elona.item_kings_bed",
   value = 35000,
   weight = 24000,
   level = 50,
   rarity = 50000,
   coefficient = 100,

   params = { bed_quality = 180 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "eastern_bed",
   elona_id = 643,
   image = "elona.item_eastern_bed",
   value = 2500,
   weight = 2000,
   rarity = 200000,
   coefficient = 0,

   params = { bed_quality = 130 },

   categories = {
      "elona.furniture_bed",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "double_bed",
   elona_id = 654,
   image = "elona.item_luxury_bed",
   value = 7500,
   weight = 16000,
   level = 40,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",

   params = { bed_quality = 160 },

   categories = {
      "elona.furniture_bed",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "happy_bed",
   elona_id = 720,
   image = "elona.item_luxury_bed",
   value = 25000,
   weight = 31000,
   level = 45,
   rarity = 2000,
   coefficient = 100,

   params = { bed_quality = 200 },

   tags = { "noshop" },
   random_color = "Furniture",
   categories = {
      "elona.furniture_bed",
      "elona.tag_noshop",
      "elona.furniture"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "jures_body_pillow",
   elona_id = 767,
   image = "elona.item_jures_body_pillow",
   value = 250,
   weight = 800,
   level = 5,
   fltselect = 1,
   rarity = 25000,
   coefficient = 100,

   params = { bed_quality = 0 },

   categories = {
      "elona.furniture_bed",
      "elona.no_generate",
      "elona.furniture"
   }
}

--
-- Instrument
--

data:add {
   _type = "base.item",
   _id = "grand_piano",
   elona_id = 88,
   image = "elona.item_goulds_piano",
   value = 15000,
   weight = 45000,
   level = 20,
   rarity = 100000,
   coefficient = 100,

   skill = "elona.performer",
   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   params = { instrument_quality = 200 },
   categories = {
      "elona.furniture_instrument",
      "elona.furniture"
   },
   light = light.item_middle
}

data:add {
   _type = "base.item",
   _id = "horn",
   elona_id = 254,
   image = "elona.item_horn",
   value = 2500,
   weight = 6500,
   level = 5,
   rarity = 500000,
   coefficient = 100,

   skill = "elona.performer",
   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   params = { instrument_quality = 110 },

   tags = { "fest" },

   categories = {
      "elona.furniture_instrument",
      "elona.tag_fest",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "pan_flute",
   elona_id = 690,
   image = "elona.item_pan_flute",
   value = 4500,
   weight = 18000,
   level = 15,
   rarity = 350000,
   coefficient = 100,

   skill = "elona.performer",
   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   params = { instrument_quality = 150 },

   tags = { "fest" },

   categories = {
      "elona.furniture_instrument",
      "elona.tag_fest",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "lute",
   elona_id = 691,
   image = "elona.item_alud",
   value = 3800,
   weight = 8500,
   level = 10,
   rarity = 400000,
   coefficient = 100,

   skill = "elona.performer",
   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   params = { instrument_quality = 130 },

   tags = { "fest" },

   categories = {
      "elona.furniture_instrument",
      "elona.tag_fest",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "harmonica",
   elona_id = 692,
   image = "elona.item_harmonica",
   value = 1500,
   weight = 850,
   rarity = 500000,
   coefficient = 100,

   skill = "elona.performer",
   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   params = { instrument_quality = 70 },

   tags = { "fest" },

   categories = {
      "elona.furniture_instrument",
      "elona.tag_fest",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "harp",
   elona_id = 693,
   image = "elona.item_harp",
   value = 7500,
   weight = 30000,
   level = 10,
   rarity = 250000,
   coefficient = 100,

   skill = "elona.performer",
   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   params = { instrument_quality = 175 },

   categories = {
      "elona.furniture_instrument",
      "elona.furniture"
   }
}

data:add {
   _type = "base.item",
   _id = "stradivarius",
   elona_id = 707,
   image = "elona.item_stradivarius",
   value = 35000,
   weight = 4500,
   fltselect = 3,
   rarity = 400000,
   coefficient = 100,

   skill = "elona.performer",

   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   is_precious = true,
   params = { instrument_quality = 180 },

   quality = Enum.Quality.Unique,

   categories = {
      "elona.furniture_instrument",
      "elona.unique_item",
      "elona.furniture"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.strad", power = 100 },
   }
}

data:add {
   _type = "base.item",
   _id = "goulds_piano",
   elona_id = 761,
   image = "elona.item_goulds_piano",
   value = 35000,
   weight = 45000,
   level = 20,
   fltselect = 3,
   rarity = 100000,
   coefficient = 100,

   skill = "elona.performer",

   on_use = function(self, params)
      Magic.cast("elona.performer", { source = params.chara, item = self })
   end,
   is_precious = true,
   params = { instrument_quality = 200 },
   quality = Enum.Quality.Unique,

   color = { 255, 255, 255 },

   categories = {
      "elona.furniture_instrument",
      "elona.unique_item",
      "elona.furniture"
   },

   light = light.item_middle,

   enchantments = {
      { _id = "elona.gould", power = 100 },
   }
}
