local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

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
   material = "elona.metal",
   coefficient = 100,
   categories = {
      "elona.equip_leg_heavy_boots",
      "elona.equip_leg"
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         dv = 1,
         pv = 3,
         pcc_part = 3,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "composite_boots",
   elona_id = 12,
   image = "elona.item_composite_boots",
   value = 2200,
   weight = 720,
   material = "elona.metal",
   level = 15,
   coefficient = 100,
   categories = {
      "elona.equip_leg_heavy_boots",
      "elona.equip_leg"
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         dv = 1,
         pv = 5,
         pcc_part = 4,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "armored_boots",
   elona_id = 458,
   image = "elona.item_armored_boots",
   value = 4800,
   weight = 1400,
   material = "elona.metal",
   level = 30,
   coefficient = 100,
   categories = {
      "elona.equip_leg_heavy_boots",
      "elona.equip_leg"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         pv = 6,
         pcc_part = 4,
      }
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
   material = "elona.soft",
   coefficient = 100,
   categories = {
      "elona.equip_leg_shoes",
      "elona.equip_leg"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         dv = 3,
         pv = 1,
         pcc_part = 5,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "boots",
   elona_id = 456,
   image = "elona.item_boots",
   value = 1500,
   weight = 450,
   material = "elona.soft",
   level = 15,
   coefficient = 100,
   categories = {
      "elona.equip_leg_shoes",
      "elona.equip_leg"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         dv = 5,
         pv = 2,
         pcc_part = 1,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "tight_boots",
   elona_id = 457,
   image = "elona.item_tight_boots",
   value = 3500,
   weight = 650,
   material = "elona.soft",
   level = 30,
   coefficient = 100,
   categories = {
      "elona.equip_leg_shoes",
      "elona.equip_leg"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         dv = 6,
         pv = 3,
         pcc_part = 2,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "seven_league_boots",
   elona_id = 556,
   image = "elona.item_composite_boots",
   value = 24000,
   weight = 300,
   material = "elona.soft",
   level = 30,
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
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         dv = 7,
         pv = 2,
         pcc_part = 3,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "dal_i_thalion",
   elona_id = 661,
   image = "elona.item_tight_boots",
   value = 25000,
   weight = 650,
   material = "elona.leather",
   level = 15,
   fltselect = 3,
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
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.leg" },
         dv = 16,
         pv = 7,
         pcc_part = 2,
      }
   }
}
