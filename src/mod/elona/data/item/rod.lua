local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Rand = require("api.Rand")
local IItemRod = require("mod.elona.api.aspect.IItemRod")

--
-- Rod
--

data:add {
   _type = "base.item",
   _id = "rod_of_identify",
   elona_id = 18,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 1080,
   weight = 800,
   level = 4,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.identify",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_teleportation",
   elona_id = 19,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 840,
   weight = 800,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.teleport_other",
         effect_power = 100,
         charges = function(self)
            return 12 + Rand.rnd(12) - Rand.rnd(12)
         end,
         max_charges = 12,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_cure_minor_wound",
   elona_id = 119,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 650,
   weight = 800,
   level = 3,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.heal_light",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_magic_missile",
   elona_id = 120,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 800,
   weight = 800,
   level = 2,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.magic_dart",
         effect_power = 100,
         charges = function(self)
            return 10 + Rand.rnd(10) - Rand.rnd(10)
         end,
         max_charges = 10,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_summon_monsters",
   elona_id = 121,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 700,
   weight = 800,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.summon_monsters",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_ice_bolt",
   elona_id = 122,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 1460,
   weight = 800,
   level = 8,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.ice_bolt",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_fire_bolt",
   elona_id = 123,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 1600,
   weight = 800,
   level = 8,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.fire_bolt",
         effect_power = 100,
         charges = function(self)
            return 10 + Rand.rnd(10) - Rand.rnd(10)
         end,
         max_charges = 10,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_heal",
   elona_id = 125,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 4800,
   weight = 800,
   level = 15,
   rarity = 250000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.cure_of_eris",
         effect_power = 100,
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_lightning_bolt",
   elona_id = 175,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 1900,
   weight = 800,
   level = 8,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.lightning_bolt",
         effect_power = 100,
         charges = function(self)
            return 10 + Rand.rnd(10) - Rand.rnd(10)
         end,
         max_charges = 10,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_slow",
   elona_id = 176,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 1500,
   weight = 800,
   level = 3,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.buff_slow",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_magic_mapping",
   elona_id = 202,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 3250,
   weight = 800,
   level = 4,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.magic_map",
         effect_power = 100,
         charges = function(self)
            return 9 + Rand.rnd(9) - Rand.rnd(9)
         end,
         max_charges = 9,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_cure",
   elona_id = 203,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 2600,
   weight = 800,
   level = 10,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.heal_critical",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_wishing",
   elona_id = 290,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 300000,
   weight = 800,
   level = 10,
   rarity = 20000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,

   _ext = {
      [IItemRod] = {
         effect_id = "elona.wish",
         effect_power = 100,
         charges = function(self)
            return 1 + Rand.rnd(1) - Rand.rnd(1)
         end,
         can_be_recharged = false,
         is_zap_always_successful = true,
      }
   },

   tags = { "noshop" },
   random_color = "Random",
   categories = {
      "elona.rod",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_silence",
   elona_id = 366,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 1080,
   weight = 800,
   level = 4,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.buff_mist_of_silence",
         effect_power = 100,
         charges = function(self)
            return 7 + Rand.rnd(7) - Rand.rnd(7)
         end,
         max_charges = 7,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_speed",
   elona_id = 377,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 4200,
   weight = 800,
   level = 8,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.buff_speed",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_holy_light",
   elona_id = 385,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 3600,
   weight = 800,
   level = 7,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.vanquish_hex",
         effect_power = 100,
         charges = function(self)
            return 6 + Rand.rnd(6) - Rand.rnd(6)
         end,
         max_charges = 6,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_mana",
   elona_id = 391,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 4100,
   weight = 800,
   level = 11,
   rarity = 200000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.harvest_mana",
         effect_power = 100,
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_uncurse",
   elona_id = 412,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 3800,
   weight = 800,
   level = 12,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.uncurse",
         effect_power = 100,
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_domination",
   elona_id = 480,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 16000,
   weight = 800,
   level = 5,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,

   _ext = {
      [IItemRod] = {
         effect_id = "elona.dominate",
         effect_power = 100,
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
         can_be_recharged = false,
      }
   },

   tags = { "noshop" },
   random_color = "Random",
   medal_value = 20,
   categories = {
      "elona.rod",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_web",
   elona_id = 485,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 3500,
   weight = 800,
   level = 3,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.web",
         effect_power = 100,
         charges = function(self)
            return 8 + Rand.rnd(8) - Rand.rnd(8)
         end,
         max_charges = 8,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_change_creature",
   elona_id = 517,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 4500,
   weight = 800,
   level = 5,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.change",
         effect_power = 100,
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_alchemy",
   elona_id = 518,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 6000,
   weight = 800,
   level = 7,
   rarity = 450000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.effect_alchemy",
         effect_power = 100,
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_wall_creation",
   elona_id = 545,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 4000,
   weight = 800,
   level = 5,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.wall_creation",
         effect_power = 100,
         charges = function(self)
            return 7 + Rand.rnd(7) - Rand.rnd(7)
         end,
         max_charges = 7,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_healing_hands",
   elona_id = 551,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 5600,
   weight = 800,
   level = 3,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.healing_touch",
         effect_power = 100,
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_acid_ground",
   elona_id = 565,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 4400,
   weight = 800,
   level = 8,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.acid_ground",
         effect_power = 100,
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_fire_wall",
   elona_id = 570,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 3800,
   weight = 800,
   level = 4,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.fire_wall",
         effect_power = 100,
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.rod"
   }
}

data:add {
   _type = "base.item",
   _id = "rod_of_make_door",
   elona_id = 581,
   knownnameref = "staff",
   image = "elona.item_rod",
   value = 2000,
   weight = 800,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemRod] = {
         effect_id = "elona.door_creation",
         effect_power = 100,
         charges = function(self)
            return 6 + Rand.rnd(6) - Rand.rnd(6)
         end,
         max_charges = 6,
      }
   },

   categories = {
      "elona.rod"
   }
}
