local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")

--
-- Cloak
--

data:add {
   _type = "base.item",
   _id = "light_cloak",
   elona_id = 65,
   image = "elona.item_light_cloak",
   value = 250,
   weight = 700,
   pv = 3,
   dv = 4,
   material = "elona.soft",
   appearance = 1,
   category = 20000,
   equip_slots = { "elona.back" },
   subcategory = 20001,
   coefficient = 100,
   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   }
}

data:add {
   _type = "base.item",
   _id = "armored_cloak",
   elona_id = 461,
   image = "elona.item_armored_cloak",
   value = 1400,
   weight = 1800,
   pv = 4,
   dv = 5,
   material = "elona.soft",
   appearance = 2,
   level = 15,
   category = 20000,
   equip_slots = { "elona.back" },
   subcategory = 20001,
   coefficient = 100,
   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   }
}

data:add {
   _type = "base.item",
   _id = "cloak",
   elona_id = 462,
   image = "elona.item_cloak",
   value = 3500,
   weight = 1500,
   pv = 3,
   dv = 7,
   material = "elona.soft",
   appearance = 1,
   level = 30,
   category = 20000,
   equip_slots = { "elona.back" },
   subcategory = 20001,
   coefficient = 100,
   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   }
}

data:add {
   _type = "base.item",
   _id = "wing",
   elona_id = 520,
   image = "elona.item_wing",
   value = 4500,
   weight = 500,
   dv = 9,
   material = "elona.soft",
   appearance = 3,
   level = 10,
   category = 20000,
   equip_slots = { "elona.back" },
   subcategory = 20001,
   rarity = 500000,
   coefficient = 100,

   categories = {
      "elona.equip_back_cloak",
      "elona.equip_back"
   },

   enchantments = {
      { _id = "elona.float", power = 100 },
   }
}

data:add {
   _type = "base.item",
   _id = "feather",
   elona_id = 552,
   image = "elona.item_feather",
   value = 18000,
   weight = 500,
   pv = 6,
   dv = 4,
   material = "elona.metal",
   appearance = 4,
   level = 25,
   category = 20000,
   equip_slots = { "elona.back" },
   subcategory = 20001,
   rarity = 100000,
   coefficient = 100,

   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   },

   enchantments = {
      { _id = "elona.float", power = 100 },
   }
}

data:add {
   _type = "base.item",
   _id = "vindale_cloak",
   elona_id = 557,
   image = "elona.item_light_cloak",
   value = 18000,
   weight = 400,
   pv = 3,
   dv = 7,
   material = "elona.soft",
   appearance = 1,
   level = 25,
   category = 20000,
   equip_slots = { "elona.back" },
   subcategory = 20001,
   rarity = 10000,
   coefficient = 100,

   before_wish = function(filter, chara)
      -- >>>>>>>> shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
      filter.quality = Calc.calc_object_quality(Enum.Quality.Good)
      return filter
      -- <<<<<<<< shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
   end,

   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   },

   enchantments = {
      { _id = "elona.res_etherwind", power = 100 },
   }
}
