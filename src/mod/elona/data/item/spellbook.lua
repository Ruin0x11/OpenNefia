local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Rand = require("api.Rand")
local ItemFunction = require("mod.elona.api.ItemFunction")
local IItemSpellbook = require("mod.elona.api.aspect.IItemSpellbook")
local IItemAncientBook = require("mod.elona.api.aspect.IItemAncientBook")

--
-- Spellbook
--

data:add {
   _type = "base.data_ext",
   _id = "spellbook",

   fields = {
      {
         name = "can_be_reserved",
         type = types.boolean,
         default = true
      }
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_teleportation",
   elona_id = 20,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3200,
   weight = 380,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_teleport",
         charges = function(self)
            return 5 + Rand.rnd(5) - Rand.rnd(5)
         end,
         max_charges = 5,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_identify",
   elona_id = 21,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 5600,
   weight = 380,
   level = 6,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_identify",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_uncurse",
   elona_id = 22,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 6400,
   weight = 380,
   level = 10,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_uncurse",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_ice_bolt",
   elona_id = 32,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3800,
   weight = 380,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_ice_bolt",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_fire_bolt",
   elona_id = 33,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3800,
   weight = 380,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_fire_bolt",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_lightning_bolt",
   elona_id = 34,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3800,
   weight = 380,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_lightning_bolt",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_minor_teleportation",
   elona_id = 116,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 2400,
   weight = 380,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_teleport",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_summon_monsters",
   elona_id = 118,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 6000,
   weight = 380,
   level = 5,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_summon_monsters",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_magic_mapping",
   elona_id = 246,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 8500,
   weight = 380,
   level = 12,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_magic_map",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_oracle",
   elona_id = 247,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 25000,
   weight = 380,
   level = 15,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_oracle",
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_return",
   elona_id = 248,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 8900,
   weight = 380,
   level = 8,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_return",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_cure_minor_wound",
   elona_id = 249,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 4500,
   weight = 380,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_heal_light",
         charges = function(self)
            return 5 + Rand.rnd(5) - Rand.rnd(5)
         end,
         max_charges = 5,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_cure_critical_wound",
   elona_id = 250,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 9000,
   weight = 380,
   level = 8,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_heal_critical",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_cure_eris",
   elona_id = 251,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 15000,
   weight = 380,
   level = 10,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_cure_of_eris",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_cure_jure",
   elona_id = 252,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 35000,
   weight = 380,
   level = 15,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_cure_of_jure",
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_magic_arrow",
   elona_id = 257,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 2500,
   weight = 380,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_magic_dart",
         charges = function(self)
            return 5 + Rand.rnd(5) - Rand.rnd(5)
         end,
         max_charges = 5,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_nether_eye",
   elona_id = 263,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 7200,
   weight = 380,
   level = 6,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_nether_arrow",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_chaos_eye",
   elona_id = 264,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 9600,
   weight = 380,
   level = 12,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_chaos_eye",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_nerve_eye",
   elona_id = 265,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 6400,
   weight = 380,
   level = 10,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_nerve_arrow",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_darkness_beam",
   elona_id = 267,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 4500,
   weight = 380,
   level = 3,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_darkness_bolt",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_illusion_beam",
   elona_id = 268,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 5500,
   weight = 380,
   level = 5,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_mind_bolt",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_ice_ball",
   elona_id = 269,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 5400,
   weight = 380,
   level = 3,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_ice_ball",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_fire_ball",
   elona_id = 270,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 5400,
   weight = 380,
   level = 3,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_fire_ball",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_sound_ball",
   elona_id = 271,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 8400,
   weight = 380,
   level = 10,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_raging_roar",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_chaos_ball",
   elona_id = 272,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 12000,
   weight = 380,
   level = 15,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_chaos_ball",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_wishing",
   elona_id = 289,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 40000,
   weight = 380,
   level = 15,
   rarity = 20000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   is_wishable = false,

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_wish",
         charges = function(self)
            return 1 + Rand.rnd(1) - Rand.rnd(1)
         end,
         can_be_recharged = false,
      },
      ["elona.spellbook"] = {
         can_be_reserved = false,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_holy_shield",
   elona_id = 365,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 2800,
   weight = 380,
   level = 3,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_holy_shield",
         charges = function(self)
            return 5 + Rand.rnd(5) - Rand.rnd(5)
         end,
         max_charges = 5,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_silence",
   elona_id = 367,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 8400,
   weight = 380,
   level = 10,
   rarity = 600000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_mist_of_silence",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_regeneration",
   elona_id = 369,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 4400,
   weight = 380,
   level = 8,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_regeneration",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_resistance",
   elona_id = 371,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 7500,
   weight = 380,
   level = 8,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_elemental_shield",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_speed",
   elona_id = 373,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 12000,
   weight = 380,
   level = 13,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_speed",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_slow",
   elona_id = 374,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 4800,
   weight = 380,
   level = 7,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_slow",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_hero",
   elona_id = 378,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 2600,
   weight = 380,
   level = 2,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_hero",
         charges = function(self)
            return 5 + Rand.rnd(5) - Rand.rnd(5)
         end,
         max_charges = 5,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_weakness",
   elona_id = 380,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 2500,
   weight = 380,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_mist_of_frailness",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_elemental_scar",
   elona_id = 381,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 6400,
   weight = 380,
   level = 10,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_element_scar",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_holy_veil",
   elona_id = 383,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 11000,
   weight = 380,
   level = 14,
   rarity = 200000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_holy_veil",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_holy_light",
   elona_id = 386,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3500,
   weight = 380,
   level = 2,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_holy_light",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_holy_rain",
   elona_id = 387,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 9800,
   weight = 380,
   level = 11,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_vanquish_hex",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_nightmare",
   elona_id = 396,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3400,
   weight = 380,
   level = 3,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_nightmare",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_knowledge",
   elona_id = 397,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3800,
   weight = 380,
   level = 3,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_divine_wisdom",
         charges = function(self)
            return 5 + Rand.rnd(5) - Rand.rnd(5)
         end,
         max_charges = 5,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_detect_objects",
   elona_id = 410,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 4000,
   weight = 380,
   rarity = 600000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_sense_object",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_mutation",
   elona_id = 434,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 20000,
   weight = 380,
   level = 15,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_mutation",
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_domination",
   elona_id = 481,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 28000,
   weight = 380,
   level = 5,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_dominate",
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_web",
   elona_id = 484,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 4500,
   weight = 380,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_web",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_wall_creation",
   elona_id = 546,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 6800,
   weight = 380,
   level = 4,
   rarity = 600000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_wall_creation",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_healing_rain",
   elona_id = 548,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 9500,
   weight = 380,
   level = 7,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_healing_rain",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_healing_hands",
   elona_id = 550,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 5800,
   weight = 380,
   level = 5,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_healing_touch",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_acid_ground",
   elona_id = 564,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 7500,
   weight = 380,
   level = 8,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_acid_ground",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_fire_wall",
   elona_id = 569,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 5800,
   weight = 380,
   level = 4,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_fire_wall",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_make_door",
   elona_id = 582,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 2000,
   weight = 380,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_door_creation",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_incognito",
   elona_id = 628,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 7000,
   weight = 380,
   level = 10,
   rarity = 200000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_incognito",
         charges = function(self)
            return 4 + Rand.rnd(4) - Rand.rnd(4)
         end,
         max_charges = 4,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_darkness_arrow",
   elona_id = 660,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3500,
   weight = 380,
   level = 5,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_dark_eye",
         charges = function(self)
            return 5 + Rand.rnd(5) - Rand.rnd(5)
         end,
         max_charges = 5,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "ancient_book",
   elona_id = 687,
   image = "elona.item_spellbook",
   value = 2000,
   weight = 380,
   level = 3,
   rarity = 5000000,
   coefficient = 0,

   _ext = {
      [IItemAncientBook] = {
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
         display_charge_count = false
      }
   },

   tags = { "noshop" },

   categories = {
      "elona.spellbook",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_magic_ball",
   elona_id = 696,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 14200,
   weight = 380,
   level = 20,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_magic_storm",
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_magic_laser",
   elona_id = 697,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 12500,
   weight = 380,
   level = 15,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_crystal_spear",
         charges = function(self)
            return 2 + Rand.rnd(2) - Rand.rnd(2)
         end,
         max_charges = 2,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_contingency",
   elona_id = 710,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 8500,
   weight = 380,
   level = 15,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.buff_contingency",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_4_dimensional_pocket",
   elona_id = 731,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 8500,
   weight = 380,
   level = 15,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_four_dimensional_pocket",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

data:add {
   _type = "base.item",
   _id = "spellbook_of_harvest",
   elona_id = 732,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 4000,
   weight = 380,
   level = 5,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   _ext = {
      [IItemSpellbook] = {
         skill_id = "elona.spell_wizards_harvest",
         charges = function(self)
            return 3 + Rand.rnd(3) - Rand.rnd(3)
         end,
         max_charges = 3,
         can_be_recharged = false,
      },
      ["elona.spellbook"] = {
         can_be_reserved = false,
      }
   },

   categories = {
      "elona.spellbook"
   }
}

--
-- Special
--

data:add {
   _type = "base.item",
   _id = "recipe",
   elona_id = 783,
   image = "elona.item_recipe",
   value = 1000,
   weight = 50,
   rarity = 50000,
   coefficient = 0,

   categories = {
      "elona.spellbook"
   }
}
