local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Rand = require("api.Rand")

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
   charge_level = 8,
   level = 4,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.identify", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   charge_level = 12,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.teleport_other", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 12 + Rand.rnd(12) - Rand.rnd(12)
   end,
   has_charge = true,

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
   charge_level = 8,
   level = 3,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.heal_light", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   charge_level = 10,
   level = 2,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.magic_dart", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 10 + Rand.rnd(10) - Rand.rnd(10)
   end,
   has_charge = true,

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
   charge_level = 8,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.summon_monsters", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   charge_level = 8,
   level = 8,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.ice_bolt", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   charge_level = 10,
   level = 8,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.fire_bolt", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 10 + Rand.rnd(10) - Rand.rnd(10)
   end,
   has_charge = true,

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
   charge_level = 4,
   level = 15,
   category = 56000,
   rarity = 250000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.cure_of_eris", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

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
   charge_level = 10,
   level = 8,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.lightning_bolt", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 10 + Rand.rnd(10) - Rand.rnd(10)
   end,
   has_charge = true,

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
   charge_level = 8,
   level = 3,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.buff_slow", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   charge_level = 9,
   level = 4,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.magic_map", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 9 + Rand.rnd(9) - Rand.rnd(9)
   end,
   has_charge = true,

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
   charge_level = 8,
   level = 10,
   category = 56000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.heal_critical", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   category = 56000,
   rarity = 20000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.wish", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 1 + Rand.rnd(1) - Rand.rnd(1)
   end,
   has_charge = true,
   can_be_recharged = false,

   is_zap_always_successful = true,

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
   charge_level = 7,
   level = 4,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.buff_mist_of_silence", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 7 + Rand.rnd(7) - Rand.rnd(7)
   end,
   has_charge = true,

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
   charge_level = 8,
   level = 8,
   category = 56000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.buff_speed", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   charge_level = 6,
   level = 7,
   category = 56000,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.vanquish_hex", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 6 + Rand.rnd(6) - Rand.rnd(6)
   end,
   has_charge = true,

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
   charge_level = 4,
   level = 11,
   category = 56000,
   rarity = 200000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.harvest_mana", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

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
   charge_level = 3,
   level = 12,
   category = 56000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.uncurse", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,

   has_charge = true,

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
   charge_level = 2,
   level = 5,
   category = 56000,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.dominate", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
   end,
   has_charge = true,
   can_be_recharged = false,

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
   charge_level = 8,
   level = 3,
   category = 56000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.web", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 8 + Rand.rnd(8) - Rand.rnd(8)
   end,
   has_charge = true,

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
   charge_level = 4,
   level = 5,
   category = 56000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.change", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

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
   charge_level = 3,
   level = 7,
   category = 56000,
   rarity = 450000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.effect_alchemy", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

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
   charge_level = 7,
   level = 5,
   category = 56000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.wall_creation", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 7 + Rand.rnd(7) - Rand.rnd(7)
   end,
   has_charge = true,

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
   charge_level = 3,
   level = 3,
   category = 56000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.healing_touch", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

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
   charge_level = 4,
   level = 8,
   category = 56000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.acid_ground", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

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
   charge_level = 4,
   level = 4,
   category = 56000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.fire_wall", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

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
   charge_level = 6,
   category = 56000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "rod",
   has_random_name = true,
   random_color = "Random",

   on_zap = function(self, params)
      return ElonaMagic.zap_rod(self, "elona.door_creation", 100, params)
   end,
   on_init_params = function(self)
      self.charges = 6 + Rand.rnd(6) - Rand.rnd(6)
   end,
   has_charge = true,

   categories = {
      "elona.rod"
   }
}
