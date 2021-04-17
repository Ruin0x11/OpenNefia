local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")

--
-- Heavy Boots
--

data:add {
   _type = "base.item",
   _id = "heavy_boots",
   elona_id = 11,
   image = "elona.item_heavy_boots",
   value = 480,
   weight = 950,
   pv = 3,
   dv = 1,
   material = "elona.metal",
   appearance = 3,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18001,
   coefficient = 100,
   categories = {
      "elona.equip_leg_heavy_boots",
      "elona.equip_leg"
   }
}

data:add {
   _type = "base.item",
   _id = "composite_boots",
   elona_id = 12,
   image = "elona.item_composite_boots",
   value = 2200,
   weight = 720,
   pv = 5,
   dv = 1,
   material = "elona.metal",
   appearance = 4,
   level = 15,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18001,
   coefficient = 100,
   categories = {
      "elona.equip_leg_heavy_boots",
      "elona.equip_leg"
   }
}

data:add {
   _type = "base.item",
   _id = "armored_boots",
   elona_id = 458,
   image = "elona.item_armored_boots",
   value = 4800,
   weight = 1400,
   pv = 6,
   material = "elona.metal",
   appearance = 4,
   level = 30,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18001,
   coefficient = 100,
   categories = {
      "elona.equip_leg_heavy_boots",
      "elona.equip_leg"
   }
}

--
-- Light Boots
--

data:add {
   _type = "base.item",
   _id = "shoes",
   elona_id = 455,
   image = "elona.item_boots",
   value = 260,
   weight = 250,
   pv = 1,
   dv = 3,
   material = "elona.soft",
   appearance = 5,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18002,
   coefficient = 100,
   categories = {
      "elona.equip_leg_shoes",
      "elona.equip_leg"
   }
}

data:add {
   _type = "base.item",
   _id = "boots",
   elona_id = 456,
   image = "elona.item_boots",
   value = 1500,
   weight = 450,
   pv = 2,
   dv = 5,
   material = "elona.soft",
   appearance = 1,
   level = 15,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18002,
   coefficient = 100,
   categories = {
      "elona.equip_leg_shoes",
      "elona.equip_leg"
   }
}

data:add {
   _type = "base.item",
   _id = "tight_boots",
   elona_id = 457,
   image = "elona.item_tight_boots",
   value = 3500,
   weight = 650,
   pv = 3,
   dv = 6,
   material = "elona.soft",
   appearance = 2,
   level = 30,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18002,
   coefficient = 100,
   categories = {
      "elona.equip_leg_shoes",
      "elona.equip_leg"
   }
}

data:add {
   _type = "base.item",
   _id = "seven_league_boots",
   elona_id = 556,
   image = "elona.item_composite_boots",
   value = 24000,
   weight = 300,
   pv = 2,
   dv = 7,
   material = "elona.soft",
   appearance = 3,
   level = 30,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18002,
   rarity = 25000,
   coefficient = 100,

   before_wish = function(filter, chara)
      -- >>>>>>>> shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
      filter.quality = Calc.calc_object_quality(Enum.Quality.Good)
      return filter
      -- <<<<<<<< shade2/command.hsp:1586 		if (p=idRingAurora)or(p=idBootsSeven)or(p=idCloa ..
   end,

   categories = {
      "elona.equip_leg_shoes",
      "elona.equip_leg"
   },

   enchantments = {
      { _id = "elona.fast_travel", power = 500 },
   }
}

data:add {
   _type = "base.item",
   _id = "dal_i_thalion",
   elona_id = 661,
   image = "elona.item_tight_boots",
   value = 25000,
   weight = 650,
   pv = 7,
   dv = 16,
   material = "elona.leather",
   appearance = 2,
   level = 15,
   fltselect = 3,
   category = 18000,
   equip_slots = { "elona.leg" },
   subcategory = 18002,
   coefficient = 100,

   is_precious = true,
   identify_difficulty = 500,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   categories = {
      "elona.equip_leg_shoes",
      "elona.unique_item",
      "elona.equip_leg"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.res_curse", power = 100 },
      { _id = "elona.fast_travel", power = 100 },
      { _id = "elona.modify_attribute", power = 250, params = { skill_id = "elona.stat_dexterity" } },
      { _id = "elona.modify_skill", power = 200, params = { skill_id = "elona.traveling" } },
   }
}
