local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Rand = require("api.Rand")
local ItemFunction = require("mod.elona.api.ItemFunction")

--
-- Spellbook
--

data:add {
   _type = "base.item",
   _id = "spellbook_of_teleportation",
   elona_id = 20,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 3200,
   weight = 380,
   charge_level = 5,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_teleport", params)
   end,
   on_init_params = function(self)
      self.charges = 5 + Rand.rnd(5) - Rand.rnd(5)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 6,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_identify", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 10,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_uncurse", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_ice_bolt", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_fire_bolt", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_lightning_bolt", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_dimensional_move", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 5,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_summon_monsters", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 12,
   category = 54000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_magic_map", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 2,
   level = 15,
   category = 54000,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_oracle", params)
   end,
   on_init_params = function(self)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 8,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_return", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 5,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_heal_light", params)
   end,
   on_init_params = function(self)
      self.charges = 5 + Rand.rnd(5) - Rand.rnd(5)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 8,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_heal_critical", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 10,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_cure_of_eris", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 2,
   level = 15,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_cure_of_jure", params)
   end,
   on_init_params = function(self)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 5,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_magic_dart", params)
   end,
   on_init_params = function(self)
      self.charges = 5 + Rand.rnd(5) - Rand.rnd(5)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 6,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_nether_arrow", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 12,
   category = 54000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_chaos_eye", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 10,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_nerve_arrow", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 3,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_darkness_bolt", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 5,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_mind_bolt", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 3,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_ice_ball", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 3,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_fire_ball", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 10,
   category = 54000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_raging_roar", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 15,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_chaos_ball", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   category = 54000,
   rarity = 20000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_wish", params)
   end,
   on_init_params = function(self)
      self.charges = 1 + Rand.rnd(1) - Rand.rnd(1)
   end,
   has_charge = true,
   can_be_recharged = false,
   is_wishable = false,
   can_be_reserved = false,

   elona_type = "book",
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
   charge_level = 5,
   level = 3,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_holy_shield", params)
   end,
   on_init_params = function(self)
      self.charges = 5 + Rand.rnd(5) - Rand.rnd(5)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 10,
   category = 54000,
   rarity = 600000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_mist_of_silence", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 8,
   category = 54000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_regeneration", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 8,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_elemental_shield", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 13,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_speed", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 7,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_slow", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 5,
   level = 2,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_hero", params)
   end,
   on_init_params = function(self)
      self.charges = 5 + Rand.rnd(5) - Rand.rnd(5)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_mist_of_frailness", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 10,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_element_scar", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 14,
   category = 54000,
   rarity = 200000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_holy_veil", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 2,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_holy_light", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 11,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_vanquish_hex", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 3,
   category = 54000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_nightmare", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 5,
   level = 3,
   category = 54000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_divine_wisdom", params)
   end,
   on_init_params = function(self)
      self.charges = 5 + Rand.rnd(5) - Rand.rnd(5)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   category = 54000,
   rarity = 600000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_sense_object", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 2,
   level = 15,
   category = 54000,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_mutation", params)
   end,
   on_init_params = function(self)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 2,
   level = 5,
   category = 54000,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_dominate", params)
   end,
   on_init_params = function(self)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   category = 54000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_web", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 4,
   category = 54000,
   rarity = 600000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_wall_creation", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 7,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_healing_rain", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 5,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_healing_touch", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 8,
   category = 54000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_acid_ground", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 4,
   category = 54000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_fire_wall", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   category = 54000,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_door_creation", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 4,
   level = 10,
   category = 54000,
   rarity = 200000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_incognito", params)
   end,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 5,
   level = 5,
   category = 54000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_dark_eye", params)
   end,
   on_init_params = function(self)
      self.charges = 5 + Rand.rnd(5) - Rand.rnd(5)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 2,
   level = 3,
   category = 54000,
   rarity = 5000000,
   coefficient = 0,

   params = {
      ancient_book_difficulty = 0,
      ancient_book_is_decoded = false,
   },

   on_read = function(self, params)
      return ItemFunction.read_ancient_book(self, params)
   end,

   on_init_params = function(self, params)
      -- >>>>>>>> shade2/item.hsp:30 	#define global maxMageBook 14 ..
      local MAX_LEVEL = 14
      -- <<<<<<<< shade2/item.hsp:30 	#define global maxMageBook 14 ..
      -- >>>>>>>> shade2/item.hsp:673 	if iId(ci)=idMageBook{ ..
      local object_level = self.level
      self.params.ancient_book_difficulty = Rand.rnd(Rand.rnd(math.floor(math.clamp(object_level / 2, 0, MAX_LEVEL))) + 1)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
      self.has_charges = true
      self.can_be_recharged = false
      -- <<<<<<<< shade2/item.hsp:675 		} ..
   end,

   elona_type = "book",

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
   charge_level = 2,
   level = 20,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_magic_storm", params)
   end,
   on_init_params = function(self)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 2,
   level = 15,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_crystal_spear", params)
   end,
   on_init_params = function(self)
      self.charges = 2 + Rand.rnd(2) - Rand.rnd(2)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 15,
   category = 54000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.buff_contingency", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 15,
   category = 54000,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_four_dimensional_pocket", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,

   elona_type = "book",
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
   charge_level = 3,
   level = 5,
   category = 54000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "spellbook",
   has_random_name = true,
   random_color = "Random",

   on_read = function(self, params)
      return ElonaMagic.read_spellbook(self, "elona.spell_wizards_harvest", params)
   end,
   on_init_params = function(self)
      self.charges = 3 + Rand.rnd(3) - Rand.rnd(3)
   end,
   has_charge = true,
   can_be_recharged = false,
   can_be_reserved = false,

   elona_type = "book",
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
   category = 54000,
   rarity = 50000,
   coefficient = 0,

   elona_type = "book",

   categories = {
      "elona.spellbook"
   }
}
