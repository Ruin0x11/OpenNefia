local Enum = require("api.Enum")
local IItemFood = require("mod.elona.api.aspect.IItemFood")

--
-- Edible Fish
--

data:add {
   _type = "base.item",
   _id = "bomb_fish",
   elona_id = 261,
   image = "elona.item_bomb_fish",
   value = 280,
   weight = 350,
   material = "elona.fresh",
   level = 3,
   rarity = 5000000,
   coefficient = 100,

   categories = {
      "elona.food",
      "elona.offering_fish"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 6
      }
   }
}

data:add {
   _type = "base.item",
   _id = "moonfish",
   elona_id = 345,
   image = "elona.item_moonfish",
   value = 900,
   weight = 800,
   material = "elona.fresh",
   level = 12,
   rarity = 500000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "sardine",
   elona_id = 346,
   image = "elona.item_fish",
   value = 1200,
   weight = 1250,
   material = "elona.fresh",
   level = 15,
   rarity = 300000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "flatfish",
   elona_id = 347,
   image = "elona.item_flatfish",
   value = 700,
   weight = 900,
   material = "elona.fresh",
   level = 10,
   rarity = 400000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "manboo",
   elona_id = 348,
   image = "elona.item_manboo",
   value = 1500,
   weight = 2400,
   material = "elona.fresh",
   level = 17,
   rarity = 200000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "seabream",
   elona_id = 349,
   image = "elona.item_seabream",
   value = 150,
   weight = 800,
   material = "elona.fresh",
   level = 3,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "salmon",
   elona_id = 350,
   image = "elona.item_salmon",
   value = 170,
   weight = 600,
   material = "elona.fresh",
   level = 3,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "globefish",
   elona_id = 351,
   image = "elona.item_globefish",
   value = 320,
   weight = 550,
   material = "elona.fresh",
   level = 5,
   rarity = 600000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "tuna",
   elona_id = 352,
   image = "elona.item_tuna_fish",
   value = 640,
   weight = 700,
   material = "elona.fresh",
   level = 7,
   rarity = 500000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "cutlassfish",
   elona_id = 353,
   image = "elona.item_cutlassfish",
   value = 620,
   weight = 600,
   material = "elona.fresh",
   level = 7,
   rarity = 500000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "sandborer",
   elona_id = 354,
   image = "elona.item_sandborer",
   value = 380,
   weight = 450,
   material = "elona.fresh",
   level = 5,
   rarity = 600000,
   coefficient = 100,

   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

data:add {
   _type = "base.item",
   _id = "fish",
   elona_id = 618,
   image = "elona.item_fish",
   value = 1200,
   weight = 1250,
   material = "elona.fresh",
   level = 15,
   fltselect = Enum.FltSelect.Sp,
   rarity = 300000,
   coefficient = 100,


   categories = {
      "elona.no_generate",
      "elona.food",
      "elona.offering_fish",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fish",
         spoilage_hours = 4
      }
   }
}

--
-- Junk Fish
--

data:add {
   _type = "base.item",
   _id = "wood_piece",
   elona_id = 43,
   image = "elona.item_wood_piece",
   value = 10,
   weight = 120,
   coefficient = 100,
   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.junk",
      "elona.junk_in_field"
   }
}

data:add {
   _type = "base.item",
   _id = "garbage",
   elona_id = 45,
   image = "elona.item_garbage",
   value = 8,
   weight = 80,
   coefficient = 100,
   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.junk",
      "elona.junk_in_field"
   }
}

data:add {
   _type = "base.item",
   _id = "dead_fish",
   elona_id = 220,
   image = "elona.item_bomb_fish",
   value = 4,
   weight = 50,
   coefficient = 100,
   tags = { "fish" },
   categories = {
      "elona.tag_fish",
      "elona.junk",
      "elona.junk_in_field"
   }
}

data:add {
   _type = "base.item",
   _id = "fish_junk",
   elona_id = 619,
   image = "elona.item_fish",
   value = 1200,
   weight = 1250,
   level = 15,
   fltselect = Enum.FltSelect.Sp,
   rarity = 300000,
   coefficient = 100,
   categories = {
      "elona.no_generate",
      "elona.junk"
   }
}
