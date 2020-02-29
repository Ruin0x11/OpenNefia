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
         name = "spots",
         default = {},
         template = true
      }
   }
}

local materials = {
   { _id = "kuzu" },
   { _id = "casino_chip" },
   { _id = "sumi" },
   { _id = "driftwood" },
   { _id = "feather" },
   { _id = "waterdrop" },
   { _id = "staff" },
   { _id = "mithril_frag" },
   { _id = "ether_frag" },
   { _id = "steel_frag" },
   { _id = "tear_angel" },
   { _id = "tear_witch" },
   { _id = "sea_water" },
   { _id = "plant1" },
   { _id = "plant2" },
   { _id = "plant3" },
   { _id = "plant4" },
   { _id = "plant5" },
   { _id = "tail_rabbit" },
   { _id = "gen_troll" },
   { _id = "snow" },
   { _id = "fairy_dust" },
   { _id = "elem_frag" },
   { _id = "elec" },
   { _id = "black_myst" },
   { _id = "hot_water" },
   { _id = "fire_stone" },
   { _id = "ice_stone" },
   { _id = "elec_stone" },
   { _id = "flying_grass" },
   { _id = "magic_mass" },
   { _id = "gen_human" },
   { _id = "eye_witch" },
   { _id = "leather" },
   { _id = "sap" },
   { _id = "magic_paper" },
   { _id = "magic_ink" },
   { _id = "crooked_staff" },
   { _id = "yell_madman" },
   { _id = "tail_bear" },
   { _id = "coin1" },
   { _id = "coin2" },
   { _id = "plant_heal" },
   { _id = "paper" },
   { _id = "generate" },
   { _id = "cloth" },
   { _id = "stick" },
   { _id = "tight_wood" },
   { _id = "stone" },
   { _id = "memory_frag" },
   { _id = "magic_frag" },
   { _id = "chaos_stone" },
   { _id = "good_stone" },
   { _id = "string" },
   { _id = "adhesive" },
   { _id = "tail" },
}

data:add_multi("elona.material", materials)
