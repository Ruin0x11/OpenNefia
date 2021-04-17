local light = require("mod.elona.data.item.light")

--
-- Ore
--

data:add {
   _type = "base.item",
   _id = "earth_crystal",
   elona_id = 35,
   image = "elona.item_crystal",
   value = 450,
   weight = 1600,
   category = 77000,
   coefficient = 100,

   rftags = { "ore" },
   color = { 255, 255, 175 },
   categories = {
      "elona.ore",
      "elona.offering_ore"
   }
}

data:add {
   _type = "base.item",
   _id = "mana_crystal",
   elona_id = 36,
   image = "elona.item_crystal",
   value = 470,
   weight = 900,
   category = 77000,
   coefficient = 100,

   rftags = { "ore" },
   color = { 255, 155, 155 },
   categories = {
      "elona.ore",
      "elona.offering_ore"
   }
}

data:add {
   _type = "base.item",
   _id = "sun_crystal",
   elona_id = 37,
   image = "elona.item_crystal",
   value = 450,
   weight = 1200,
   category = 77000,
   coefficient = 100,

   rftags = { "ore" },
   color = { 255, 215, 175 },
   categories = {
      "elona.ore",
      "elona.offering_ore"
   },
   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "gold_bar",
   elona_id = 38,
   image = "elona.item_worthless_fake_gold_bar",
   value = 2000,
   weight = 1100,
   category = 77000,
   rarity = 500000,
   coefficient = 100,

   rftags = { "ore" },

   categories = {
      "elona.ore",
      "elona.offering_ore"
   },

   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "worthless_fake_gold_bar",
   elona_id = 208,
   image = "elona.item_worthless_fake_gold_bar",
   value = 1,
   weight = 1,
   category = 77000,
   coefficient = 100,
   rftags = { "ore" },
   categories = {
      "elona.ore"
   }
}

--
-- Gem
--

data:add {
   _type = "base.item",
   _id = "raw_ore_of_rubynus",
   elona_id = 39,
   image = "elona.item_raw_ore",
   value = 1400,
   weight = 240,
   category = 77000,
   subcategory = 77001,
   rarity = 500000,
   coefficient = 100,
   originalnameref2 = "raw ore",

   rftags = { "ore" },
   color = { 255, 155, 155 },
   categories = {
      "elona.ore_valuable",
      "elona.ore",
      "elona.offering_ore",
   },
   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "raw_ore_of_mica",
   elona_id = 40,
   image = "elona.item_raw_ore",
   value = 720,
   weight = 70,
   category = 77000,
   subcategory = 77001,
   coefficient = 100,
   originalnameref2 = "raw ore",

   rftags = { "ore" },

   categories = {
      "elona.ore_valuable",
      "elona.ore",
      "elona.offering_ore",
   }
}

data:add {
   _type = "base.item",
   _id = "raw_ore_of_emerald",
   elona_id = 41,
   image = "elona.item_raw_ore_of_diamond",
   value = 2450,
   weight = 380,
   category = 77000,
   subcategory = 77001,
   rarity = 400000,
   coefficient = 100,
   originalnameref2 = "raw ore",

   rftags = { "ore" },
   color = { 175, 255, 175 },
   categories = {
      "elona.ore_valuable",
      "elona.ore",
      "elona.offering_ore",
   },
   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "raw_ore_of_diamond",
   elona_id = 42,
   image = "elona.item_raw_ore_of_diamond",
   value = 4200,
   weight = 320,
   category = 77000,
   subcategory = 77001,
   rarity = 250000,
   coefficient = 100,
   originalnameref2 = "raw ore",

   rftags = { "ore" },
   color = { 175, 175, 255 },
   categories = {
      "elona.ore_valuable",
      "elona.ore",
      "elona.offering_ore",
   },
   light = light.crystal
}

data:add {
   _type = "base.item",
   _id = "junk_stone",
   elona_id = 44,
   image = "elona.item_junk_stone",
   value = 10,
   weight = 450,
   category = 77000,
   subcategory = 64000,
   coefficient = 100,

   rftags = { "ore" },

   categories = {
      "elona.junk_in_field",
      "elona.ore",
      "elona.offering_ore"
   }
}
