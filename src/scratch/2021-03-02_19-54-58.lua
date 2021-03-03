local Compat = require("mod.elona_sys.api.Compat")

local materials = {
   -- global
    { _id = "kuzu",          elona_id = 0, level = 0,  rarity = 1,     image = 240  },
    { _id = "casino_chip",   elona_id = 0, level = 1,  rarity = 80,    image = 434  },
    { _id = "coin_1",        elona_id = 0, level = 1,  rarity = 200,   image = 437  },
    { _id = "coin_2",        elona_id = 0, level = 1,  rarity = 1000,  image = 437  },
    { _id = "paper",         elona_id = 0, level = 1,  rarity = 20,    image = 470  },
    { _id = "sumi",          elona_id = 0, level = 1,  rarity = 10,    image = 239  },
    { _id = "driftwood",     elona_id = 0, level = 1,  rarity = 10,    image = 239  },
    { _id = "stone",         elona_id = 0, level = 1,  rarity = 10,    image = 209  },
    { _id = "staff",         elona_id = 0, level = 1,  rarity = 70,    image = 239  },
    { _id = "cloth",         elona_id = 0, level = 3,  rarity = 20,    image = 155  },
    { _id = "yellmadman",    elona_id = 0, level = 4,  rarity = 30,    image = 8    },
    { _id = "magic_mass",    elona_id = 0, level = 10, rarity = 150,   image = 7    },
    { _id = "elec",          elona_id = 0, level = 12, rarity = 20,    image = 7    },
    { _id = "generate",      elona_id = 0, level = 25, rarity = 150,   image = 7    },

    -- dungeon
    { _id = "magic_frag",    elona_id = 0, level = 1,  rarity = 30,    image = 209  },

    -- forest
    { _id = "stick",         elona_id = 0, level = 2,  rarity = 20,    image = 239  },
    { _id = "leather",       elona_id = 0, level = 4,  rarity = 20,    image = 155  },
    { _id = "string",        elona_id = 0, level = 6,  rarity = 20,    image = 202  },
    { _id = "tight_wood",    elona_id = 0, level = 10, rarity = 20,    image = 239  },
    { _id = "crooked_staff", elona_id = 0, level = 12, rarity = 60,    image = 471  },

    -- building
    { _id = "adhesive",      elona_id = 0, level = 1,  rarity = 50,    image = 354  },
    { _id = "memory_frag",   elona_id = 0, level = 5,  rarity = 50,    image = 150  },
    { _id = "magic_paper",   elona_id = 0, level = 8,  rarity = 40,    image = 470  },
    { _id = "magic_ink",     elona_id = 0, level = 8,  rarity = 40,    image = 354  },

    -- spring
    { _id = "sea_water",     elona_id = 0, level = 1,  rarity = 10,    image = 354  },
    { _id = "waterdrop",     elona_id = 0, level = 1,  rarity = 10,    image = 354  },
    { _id = "tear_angel",    elona_id = 0, level = 4,  rarity = 50,    image = 354  },
    { _id = "hot_water",     elona_id = 0, level = 4,  rarity = 20,    image = 354  },
    { _id = "tear_witch",    elona_id = 0, level = 8,  rarity = 30,    image = 354  },
    { _id = "snow",          elona_id = 0, level = 12, rarity = 15,    image = 7    },

    -- mine
    { _id = "mithril_frag",  elona_id = 0, level = 1,  rarity = 40,    image = 209  },
    { _id = "steel_frag",    elona_id = 0, level = 1,  rarity = 10,    image = 209  },
    { _id = "fire_stone",    elona_id = 0, level = 5,  rarity = 10,    image = 209  },
    { _id = "ice_stone",     elona_id = 0, level = 5,  rarity = 10,    image = 209  },
    { _id = "elec_stone",    elona_id = 0, level = 5,  rarity = 10,    image = 209  },
    { _id = "good_stone",    elona_id = 0, level = 8,  rarity = 50,    image = 209  },
    { _id = "ether_frag",    elona_id = 0, level = 10, rarity = 40,    image = 209  },
    { _id = "elem_frag",     elona_id = 0, level = 20, rarity = 100,   image = 209  },
    { _id = "chaos_stone",   elona_id = 0, level = 40, rarity = 200,   image = 209  },

    -- bush
    { _id = "plant_1",       elona_id = 0, level = 1,  rarity = 10,    image = 170  },
    { _id = "plant_2",       elona_id = 0, level = 1,  rarity = 20,    image = 170  },
    { _id = "plant_3",       elona_id = 0, level = 1,  rarity = 20,    image = 170  },
    { _id = "plant_4",       elona_id = 0, level = 1,  rarity = 10,    image = 170  },
    { _id = "plant_heal",    elona_id = 0, level = 3,  rarity = 20,    image = 170  },
    { _id = "flying_grass",  elona_id = 0, level = 7,  rarity = 50,    image = 170  },
    { _id = "plant_5",       elona_id = 0, level = 12, rarity = 20,    image = 170  },
    { _id = "black_myst",    elona_id = 0, level = 15, rarity = 40,    image = 8    },
    { _id = "sap",           elona_id = 0, level = 25, rarity = 200,   image = 354  },

    -- remain
    { _id = "feather",       elona_id = 0, level = 1,  rarity = 10,    image = 436  },
    { _id = "tail_rabbit",   elona_id = 0, level = 1,  rarity = 80,    image = 301  },
    { _id = "gen_human",     elona_id = 0, level = 1,  rarity = 20,    image = 304  },
    { _id = "tail_bear",     elona_id = 0, level = 3,  rarity = 20,    image = 301  },
    { _id = "gen_troll",     elona_id = 0, level = 5,  rarity = 15,    image = 304  },
    { _id = "eye_witch",     elona_id = 0, level = 8,  rarity = 40,    image = 304  },
    { _id = "fairy_dust",    elona_id = 0, level = 15, rarity = 45,    image = 209  },
}

for _, material in ipairs(materials) do
   material.image = Compat.convert_122_item_chip(material.image)
   print(inspect(material))
end
