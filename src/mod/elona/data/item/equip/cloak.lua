local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local IItemEquipment = require("mod.elona.api.aspect.IItemEquipment")

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
   material = "elona.soft",
   coefficient = 100,
   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.back" },
         dv = 4,
         pv = 3,
         pcc_part = 1,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "armored_cloak",
   elona_id = 461,
   image = "elona.item_armored_cloak",
   value = 1400,
   weight = 1800,
   material = "elona.soft",
   level = 15,
   coefficient = 100,
   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.back" },
         dv = 5,
         pv = 4,
         pcc_part = 2,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "cloak",
   elona_id = 462,
   image = "elona.item_cloak",
   value = 3500,
   weight = 1500,
   material = "elona.soft",
   level = 30,
   coefficient = 100,
   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   },
   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.back" },
         dv = 7,
         pv = 3,
         pcc_part = 1,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "wing",
   elona_id = 520,
   image = "elona.item_wing",
   value = 4500,
   weight = 500,
   material = "elona.soft",
   level = 10,
   rarity = 500000,
   coefficient = 100,

   categories = {
      "elona.equip_back_cloak",
      "elona.equip_back"
   },

   enchantments = {
      { _id = "elona.float", power = 100 },
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.back" },
         dv = 9,
         pcc_part = 3,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "feather",
   elona_id = 552,
   image = "elona.item_feather",
   value = 18000,
   weight = 500,
   material = "elona.metal",
   level = 25,
   rarity = 100000,
   coefficient = 100,

   categories = {
      "elona.equip_back",
      "elona.equip_back_cloak"
   },

   enchantments = {
      { _id = "elona.float", power = 100 },
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.back" },
         dv = 4,
         pv = 6,
         pcc_part = 4,
      }
   }
}

data:add {
   _type = "base.item",
   _id = "vindale_cloak",
   elona_id = 557,
   image = "elona.item_light_cloak",
   value = 18000,
   weight = 400,
   material = "elona.soft",
   level = 25,
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
   },

   _ext = {
      [IItemEquipment] = {
         equip_slots = { "elona.back" },
         dv = 7,
         pv = 3,
         pcc_part = 1,
      }
   }
}
