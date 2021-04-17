local light = require("mod.elona.data.item.light")

--
-- Cargo
--

data:add {
   _type = "base.item",
   _id = "cargo_rag_doll",
   elona_id = 399,
   image = "elona.item_rag_doll",
   value = 700,
   cargo_weight = 6500,
   is_cargo = true,
   category = 92000,
   coefficient = 100,

   params = { cargo_quality = 1 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_barrel",
   elona_id = 400,
   image = "elona.item_barrel",
   value = 420,
   cargo_weight = 10000,
   is_cargo = true,
   category = 92000,
   coefficient = 100,

   params = { cargo_quality = 2 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_piano",
   elona_id = 401,
   image = "elona.item_piano",
   value = 4000,
   cargo_weight = 50000,
   is_cargo = true,
   category = 92000,
   rarity = 200000,
   coefficient = 100,

   params = { cargo_quality = 4 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_rope",
   elona_id = 402,
   image = "elona.item_rope",
   value = 550,
   cargo_weight = 4800,
   is_cargo = true,
   category = 92000,
   coefficient = 100,

   params = { cargo_quality = 5 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_coffin",
   elona_id = 403,
   image = "elona.item_coffin",
   value = 2200,
   cargo_weight = 12000,
   is_cargo = true,
   category = 92000,
   rarity = 700000,
   coefficient = 100,

   params = { cargo_quality = 3 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_manboo",
   elona_id = 404,
   image = "elona.item_manboo",
   value = 800,
   cargo_weight = 10000,
   is_cargo = true,
   category = 92000,
   rarity = 1500000,
   coefficient = 100,

   params = { cargo_quality = 0 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_grave",
   elona_id = 405,
   image = "elona.item_grave",
   value = 2800,
   cargo_weight = 48000,
   is_cargo = true,
   category = 92000,
   rarity = 800000,
   coefficient = 100,

   params = { cargo_quality = 3 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_tuna_fish",
   elona_id = 406,
   image = "elona.item_tuna_fish",
   value = 350,
   cargo_weight = 7500,
   is_cargo = true,
   category = 92000,
   rarity = 2000000,
   coefficient = 100,

   params = { cargo_quality = 0 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_whisky",
   elona_id = 407,
   image = "elona.item_whisky",
   value = 1400,
   cargo_weight = 16000,
   is_cargo = true,
   category = 92000,
   rarity = 600000,
   coefficient = 100,

   params = { cargo_quality = 2 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_noble_toy",
   elona_id = 408,
   image = "elona.item_noble_toy",
   value = 1200,
   cargo_weight = 32000,
   is_cargo = true,
   category = 92000,
   rarity = 500000,
   coefficient = 100,

   params = { cargo_quality = 1 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_inner_tube",
   elona_id = 409,
   image = "elona.item_inner_tube",
   value = 340,
   cargo_weight = 1500,
   is_cargo = true,
   category = 92000,
   rarity = 1500000,
   coefficient = 100,

   params = { cargo_quality = 5 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_christmas_tree",
   elona_id = 597,
   image = "elona.item_christmas_tree",
   value = 3500,
   cargo_weight = 60000,
   is_cargo = true,
   category = 92000,
   rarity = 600000,
   coefficient = 100,

   params = { cargo_quality = 6 },

   categories = {
      "elona.cargo"
   },

   light = light.crystal_high
}

data:add {
   _type = "base.item",
   _id = "cargo_snow_man",
   elona_id = 598,
   image = "elona.item_snow_man",
   value = 1200,
   cargo_weight = 11000,
   is_cargo = true,
   category = 92000,
   rarity = 800000,
   coefficient = 100,

   params = { cargo_quality = 6 },

   categories = {
      "elona.cargo"
   },

   light = light.item
}

data:add {
   _type = "base.item",
   _id = "cargo_art",
   elona_id = 669,
   image = "elona.item_painting_of_landscape",
   value = 3800,
   cargo_weight = 35000,
   is_cargo = true,
   category = 92000,
   rarity = 150000,
   coefficient = 100,

   params = { cargo_quality = 7 },

   categories = {
      "elona.cargo"
   }
}

data:add {
   _type = "base.item",
   _id = "cargo_canvas",
   elona_id = 670,
   image = "elona.item_canvas",
   value = 750,
   cargo_weight = 7000,
   is_cargo = true,
   category = 92000,
   coefficient = 100,

   params = { cargo_quality = 7 },

   categories = {
      "elona.cargo"
   }
}

--
-- Cargo Food
--

data:add {
   _type = "base.item",
   _id = "cargo_travelers_food",
   elona_id = 333,
   image = "elona.item_travelers_food",
   value = 40,
   cargo_weight = 2000,
   is_cargo = true,
   category = 91000,
   coefficient = 100,

   params = { food_quality = 3 },

   categories = {
      "elona.cargo_food"
   }
}
