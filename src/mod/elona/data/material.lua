data:add_type {
   name = "material",
   fields = {
      {
         name = "level",
         default = 1,
         template = true
      },
      {
         name = "rarity",
         default = 1,
         template = true
      },
      {
         name = "image",
         default = "elona.item_garbage",
         template = true
      }
   }
}
data:add_index("elona.material", "elona_id")

local materials = {
   -- global
    { _id = "kuzu",          elona_id = 0,  level = 0,  rarity = 1,     image = "elona.item_garbage"              },
    { _id = "casino_chip",   elona_id = 1,  level = 1,  rarity = 80,    image = "elona.item_casino_chip"          },
    { _id = "coin_1",        elona_id = 40, level = 1,  rarity = 200,   image = "elona.item_platinum_coin"        },
    { _id = "coin_2",        elona_id = 41, level = 1,  rarity = 1000,  image = "elona.item_platinum_coin"        },
    { _id = "paper",         elona_id = 43, level = 1,  rarity = 20,    image = "elona.item_scroll"               },
    { _id = "sumi",          elona_id = 2,  level = 1,  rarity = 10,    image = "elona.item_wood_piece"           },
    { _id = "driftwood",     elona_id = 3,  level = 1,  rarity = 10,    image = "elona.item_wood_piece"           },
    { _id = "stone",         elona_id = 48, level = 1,  rarity = 10,    image = "elona.item_ore_piece"            },
    { _id = "staff",         elona_id = 6,  level = 1,  rarity = 70,    image = "elona.item_wood_piece"           },
    { _id = "cloth",         elona_id = 45, level = 3,  rarity = 20,    image = "elona.item_silk_cloth"           },
    { _id = "yellmadman",    elona_id = 38, level = 4,  rarity = 30,    image = "elona.item_projectile_bomb_1"    },
    { _id = "magic_mass",    elona_id = 30, level = 10, rarity = 150,   image = "elona.item_material_spark"       },
    { _id = "elec",          elona_id = 23, level = 12, rarity = 20,    image = "elona.item_material_spark"       },
    { _id = "generate",      elona_id = 44, level = 25, rarity = 150,   image = "elona.item_material_spark"       },

    -- dungeon
    { _id = "magic_frag",    elona_id = 50, level = 1,  rarity = 30,    image = "elona.item_ore_piece"            },

    -- forest
    { _id = "stick",         elona_id = 46, level = 2,  rarity = 20,    image = "elona.item_wood_piece"           },
    { _id = "leather",       elona_id = 33, level = 4,  rarity = 20,    image = "elona.item_silk_cloth"           },
    { _id = "string",        elona_id = 53, level = 6,  rarity = 20,    image = "elona.item_rope"                 },
    { _id = "tight_wood",    elona_id = 47, level = 10, rarity = 20,    image = "elona.item_wood_piece"           },
    { _id = "crooked_staff", elona_id = 37, level = 12, rarity = 60,    image = "elona.item_rod"                  },

    -- building
    { _id = "adhesive",      elona_id = 54, level = 1,  rarity = 50,    image = "elona.item_potion"               },
    { _id = "memory_frag",   elona_id = 49, level = 5,  rarity = 50,    image = "elona.item_gorgeous_candlestick" },
    { _id = "magic_paper",   elona_id = 35, level = 8,  rarity = 40,    image = "elona.item_scroll"               },
    { _id = "magic_ink",     elona_id = 36, level = 8,  rarity = 40,    image = "elona.item_potion"               },

    -- spring
    { _id = "sea_water",     elona_id = 12, level = 1,  rarity = 10,    image = "elona.item_potion"               },
    { _id = "waterdrop",     elona_id = 5,  level = 1,  rarity = 10,    image = "elona.item_potion"               },
    { _id = "tear_angel",    elona_id = 10, level = 4,  rarity = 50,    image = "elona.item_potion"               },
    { _id = "hot_water",     elona_id = 25, level = 4,  rarity = 20,    image = "elona.item_potion"               },
    { _id = "tear_witch",    elona_id = 11, level = 8,  rarity = 30,    image = "elona.item_potion"               },
    { _id = "snow",          elona_id = 20, level = 12, rarity = 15,    image = "elona.item_material_spark"       },

    -- mine
    { _id = "mithril_frag",  elona_id = 7,  level = 1,  rarity = 40,    image = "elona.item_ore_piece"            },
    { _id = "steel_frag",    elona_id = 9,  level = 1,  rarity = 10,    image = "elona.item_ore_piece"            },
    { _id = "fire_stone",    elona_id = 26, level = 5,  rarity = 10,    image = "elona.item_ore_piece"            },
    { _id = "ice_stone",     elona_id = 27, level = 5,  rarity = 10,    image = "elona.item_ore_piece"            },
    { _id = "elec_stone",    elona_id = 28, level = 5,  rarity = 10,    image = "elona.item_ore_piece"            },
    { _id = "good_stone",    elona_id = 52, level = 8,  rarity = 50,    image = "elona.item_ore_piece"            },
    { _id = "ether_frag",    elona_id = 8,  level = 10, rarity = 40,    image = "elona.item_ore_piece"            },
    { _id = "elem_frag",     elona_id = 22, level = 20, rarity = 100,   image = "elona.item_ore_piece"            },
    { _id = "chaos_stone",   elona_id = 51, level = 40, rarity = 200,   image = "elona.item_ore_piece"            },

    -- bush
    { _id = "plant_1",       elona_id = 13, level = 1,  rarity = 10,    image = "elona.item_stomafillia"          },
    { _id = "plant_2",       elona_id = 14, level = 1,  rarity = 20,    image = "elona.item_stomafillia"          },
    { _id = "plant_3",       elona_id = 15, level = 1,  rarity = 20,    image = "elona.item_stomafillia"          },
    { _id = "plant_4",       elona_id = 16, level = 1,  rarity = 10,    image = "elona.item_stomafillia"          },
    { _id = "plant_heal",    elona_id = 42, level = 3,  rarity = 20,    image = "elona.item_stomafillia"          },
    { _id = "flying_grass",  elona_id = 29, level = 7,  rarity = 50,    image = "elona.item_stomafillia"          },
    { _id = "plant_5",       elona_id = 17, level = 12, rarity = 20,    image = "elona.item_stomafillia"          },
    { _id = "black_myst",    elona_id = 24, level = 15, rarity = 40,    image = "elona.item_material_skull"       },
    { _id = "sap",           elona_id = 34, level = 25, rarity = 200,   image = "elona.item_potion"               },

    -- remain
    { _id = "feather",       elona_id = 4,  level = 1,  rarity = 10,    image = "elona.item_material_feather"      },
    { _id = "tail_rabbit",   elona_id = 18, level = 1,  rarity = 80,    image = "elona.item_rabbits_tail"         },
    { _id = "gen_human",     elona_id = 31, level = 1,  rarity = 20,    image = "elona.item_remains_heart"        },
    { _id = "tail_bear",     elona_id = 39, level = 3,  rarity = 20,    image = "elona.item_rabbits_tail"         },
    { _id = "gen_troll",     elona_id = 19, level = 5,  rarity = 15,    image = "elona.item_remains_heart"        },
    { _id = "eye_witch",     elona_id = 32, level = 8,  rarity = 40,    image = "elona.item_remains_heart"        },
    { _id = "fairy_dust",    elona_id = 21, level = 15, rarity = 45,    image = "elona.item_ore_piece"            },
}

data:add_multi("elona.material", materials)
