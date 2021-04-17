local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Building = require("mod.elona.api.Building")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Enum = require("api.Enum")

--
-- Scroll
--

data:add {
   _type = "base.item",
   _id = "scroll_of_identify",
   elona_id = 14,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 480,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.identify", power = 100 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_oracle",
   elona_id = 15,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 12000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.oracle", power = 100 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_teleportation",
   elona_id = 16,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 200,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.teleport", power = 100 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   tags = { "nogive" },

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_incognito",
   elona_id = 17,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 3500,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.buff_incognito", power = 300 }}, params)
   end,
   category = 53000,
   rarity = 70000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_uncurse",
   elona_id = 209,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 1050,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.uncurse", power = 100 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_return",
   elona_id = 236,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 750,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.return", power = 100 }}, params)
   end,
   category = 53000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_magical_map",
   elona_id = 242,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 480,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.magic_map", power = 500 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_gain_attribute",
   elona_id = 243,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 240000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_skill", power = 100 }}, params)
   end,
   level = 15,
   category = 53000,
   rarity = 25000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "noshop" },
   random_color = "Random",
   categories = {
      "elona.scroll",
      "elona.tag_noshop"
   },

   events = {
      {
         id = "elona.on_item_created_from_wish",
         name = "Adjust amount",

         callback = function(self)
            -- >>>>>>>> shade2/command.hsp:1601 			if iId(ci)=idPotionChangeMaterialSuper	:iNum(ci ..
            self.amount = 1
            -- <<<<<<<< shade2/command.hsp:1601 			if iId(ci)=idPotionChangeMaterialSuper	:iNum(ci ..
         end
      },
   },
}

data:add {
   _type = "base.item",
   _id = "scroll_of_wonder",
   elona_id = 244,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 8000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_knowledge", power = 100 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_minor_teleportation",
   elona_id = 245,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 200,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.teleport", power = 100 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   tags = { "nogive" },

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_curse",
   elona_id = 288,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 150,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_curse", power = 100 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "neg" },
   random_color = "Random",
   categories = {
      "elona.scroll",
      "elona.tag_neg"
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_greater_identify",
   elona_id = 362,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 3500,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.identify", power = 2000 }}, params)
   end,
   level = 10,
   category = 53000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_vanish_curse",
   elona_id = 363,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 4400,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.uncurse", power = 2500 }}, params)
   end,
   level = 12,
   category = 53000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_holy_veil",
   elona_id = 384,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 1500,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.buff_holy_veil", power = 250 }}, params)
   end,
   level = 3,
   category = 53000,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_holy_light",
   elona_id = 388,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 350,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.holy_light", power = 300 }}, params)
   end,
   category = 53000,
   rarity = 800000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_holy_rain",
   elona_id = 389,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 1400,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.vanquish_hex", power = 300 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 400000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_mana",
   elona_id = 390,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 2400,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.harvest_mana", power = 250 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 150000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_gain_material",
   elona_id = 395,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 3800,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_create_material", power = 250 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 700000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_knowledge",
   elona_id = 398,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 1800,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.buff_divine_wisdom", power = 250 }}, params)
   end,
   level = 3,
   category = 53000,
   rarity = 600000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_detect_objects",
   elona_id = 411,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 350,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.sense_object", power = 500 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_growth",
   elona_id = 430,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 15000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_skill_potential", power = 500 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 80000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "noshop" },
   random_color = "Random",
   medal_value = 5,
   categories = {
      "elona.scroll",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_faith",
   elona_id = 431,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 12000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_faith", power = 300 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "noshop" },
   random_color = "Random",
   medal_value = 8,
   categories = {
      "elona.scroll",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_ally",
   elona_id = 479,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 9000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_ally", power = 100 }}, params)
   end,
   level = 10,
   category = 53000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_inferior_material",
   elona_id = 500,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 600,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_change_material", power = 10 }}, params)
   end,
   category = 53000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "neg" },
   random_color = "Random",
   categories = {
      "elona.scroll",
      "elona.tag_neg"
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_change_material",
   elona_id = 501,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 5000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_change_material", power = 180 }}, params)
   end,
   level = 15,
   category = 53000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_superior_material",
   elona_id = 502,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 20000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_change_material", power = 350 }}, params)
   end,
   level = 30,
   category = 53000,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "spshop" },
   random_color = "Random",
   medal_value = 7,
   categories = {
      "elona.scroll",
      "elona.tag_spshop"
   },

   events = {
      {
         id = "elona.on_item_created_from_wish",
         name = "Adjust amount",

         callback = function(self)
            -- >>>>>>>> shade2/command.hsp:1601 			if iId(ci)=idPotionChangeMaterialSuper	:iNum(ci ..
            self.amount = 2
            -- <<<<<<<< shade2/command.hsp:1601 			if iId(ci)=idPotionChangeMaterialSuper	:iNum(ci ..
         end
      },
   },
}

data:add {
   _type = "base.item",
   _id = "scroll_of_enchant_weapon",
   elona_id = 506,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 8000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_enchant_weapon", power = 200 }}, params)
   end,
   category = 53000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_greater_enchant_weapon",
   elona_id = 507,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 14000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_enchant_weapon", power = 400 }}, params)
   end,
   level = 10,
   category = 53000,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_enchant_armor",
   elona_id = 508,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 8000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_enchant_armor", power = 200 }}, params)
   end,
   category = 53000,
   rarity = 300000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_greater_enchant_armor",
   elona_id = 509,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 14000,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_enchant_armor", power = 400 }}, params)
   end,
   level = 10,
   category = 53000,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_recharge",
   elona_id = 515,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 2500,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_recharge", power = 300 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_healing_rain",
   elona_id = 549,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 3500,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.healing_rain", power = 400 }}, params)
   end,
   level = 12,
   category = 53000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "noshop" },
   random_color = "Random",
   categories = {
      "elona.scroll",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "flying_scroll",
   elona_id = 632,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 40000,
   weight = 5,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_flight", power = 150 }}, params)
   end,
   category = 53000,
   rarity = 25000,
   coefficient = 0,
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_escape",
   elona_id = 638,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 450,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_escape", power = 100 }}, params)
   end,
   category = 53000,
   rarity = 500000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,
   random_color = "Random",

   elona_type = "scroll",
   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "book_of_resurrection",
   elona_id = 708,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 6000,
   weight = 380,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.resurrection", power = 2500 }}, params)
   end,
   category = 55000,
   rarity = 3000,
   coefficient = 0,
   originalnameref2 = "book",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "noshop" },
   random_color = "Random",
   categories = {
      "elona.book",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_contingency",
   elona_id = 709,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 3500,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.buff_contingency", power = 1500 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 3000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "noshop" },
   random_color = "Random",
   categories = {
      "elona.scroll",
      "elona.tag_noshop"
   }
}

data:add {
   _type = "base.item",
   _id = "scroll_of_name",
   elona_id = 737,
   knownnameref = "scroll",
   image = "elona.item_scroll",
   value = 7500,
   weight = 20,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_name", power = 100 }}, params)
   end,
   level = 20,
   category = 53000,
   rarity = 2000,
   coefficient = 0,
   originalnameref2 = "scroll",
   has_random_name = true,

   elona_type = "scroll",

   tags = { "noshop" },
   random_color = "Random",
   categories = {
      "elona.scroll",
      "elona.tag_noshop"
   }
}

--
-- Book
--

data:add {
   _type = "base.item",
   _id = "little_sisters_diary",
   elona_id = 505,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 8000,
   weight = 380,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_younger_sister", power = 100 }}, params)
   end,
   level = 5,
   category = 55000,
   rarity = 25000,
   coefficient = 0,
   has_random_name = true,
   random_color = "Random",

   is_precious = true,

   elona_type = "scroll",
   medal_value = 12,
   categories = {
      "elona.book"
   }
}

data:add {
   _type = "base.item",
   _id = "cat_sisters_diary",
   elona_id = 623,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 15000,
   weight = 380,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_cat_sister", power = 100 }}, params)
   end,
   level = 15,
   category = 55000,
   rarity = 1000,
   coefficient = 0,
   has_random_name = true,
   random_color = "Random",

   is_precious = true,

   elona_type = "scroll",
   medal_value = 85,
   categories = {
      "elona.book"
   }
}

data:add {
   _type = "base.item",
   _id = "girls_diary",
   elona_id = 624,
   knownnameref = "spellbook",
   image = "elona.item_spellbook",
   value = 10000,
   weight = 380,
   on_read = function(self, params)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_gain_young_lady", power = 100 }}, params)
   end,
   level = 5,
   category = 55000,
   rarity = 5000,
   coefficient = 0,
   has_random_name = true,
   random_color = "Random",

   is_precious = true,

   elona_type = "scroll",
   medal_value = 25,
   categories = {
      "elona.book"
   }
}

--
-- Deed
--

data:add {
   _type = "base.item",
   _id = "deed",
   elona_id = 344,
   image = "elona.item_deed",
   value = 50000,
   weight = 500,
   fltselect = 1,
   category = 53000,
   subcategory = 53100,
   coefficient = 100,

   can_read_in_world_map = true,
   prevent_sell_in_own_shop = true,

   on_read = function(self, params)
      if not Building.query_build(self) then
         return "player_turn_query"
      end

      self.amount = self.amount - 1

      local chara = params.chara
      local map = chara:current_map()
      local new_home_map = Building.build_home(self.params.deed_home_id, chara.x, chara.y, map)

      Gui.play_sound("base.build1", chara.x, chara.y)
      Gui.mes_c("building.built_new_house", "Green")
      Input.query_more()

      Gui.play_sound("base.exitmap1")
      new_home_map:set_previous_map_and_location(map, chara.x, chara.y)
      Map.travel_to(new_home_map)

      return "turn_end"
   end,

   params = { deed_home_id = "elona.cave" },

   on_init_params = function(self, params)
      -- >>>>>>>> shade2/item.hsp:644 	if iId(ci)=idDeedHouse{ ..
      local can_create = function(home)
         return home._id ~= "elona.cave"
      end

      self.params.deed_home_id = Rand.choice(data["elona.home"]:iter():filter(can_create))._id
      if not params.is_shop then
         self.params.deed_home_id = "elona.shack"
      end
      local home_data = data["elona.home"]:ensure(self.params.deed_home_id)
      self.value = home_data.value
      -- <<<<<<<< shade2/item.hsp:650 	if iId(ci)=idGold{ ..
   end,

   color = { 175, 255, 175 },

   categories = {
      "elona.scroll",
      "elona.scroll_deed",
      "elona.no_generate"
   }
}

local function deed_callback(building_id)
   return function(item, params)
      if not Building.query_build(item) then
         return "player_turn_query"
      end

      item.amount = item.amount - 1

      local chara = params.chara
      local map = chara:current_map()
      Building.build(building_id, chara.x, chara.y, map)

      Gui.update_screen()
      Gui.play_sound("base.build1", chara.x, chara.y)
      local building_name = ("building._.%s.name"):format(building_id)
      Gui.mes_c("building.built_new", "Yellow", building_name)

      return "turn_end"
   end
end

data:add {
   _type = "base.item",
   _id = "deed_of_museum",
   elona_id = 521,
   image = "elona.item_deed",
   value = 140000,
   weight = 500,
   on_read = deed_callback("elona.museum"),
   fltselect = 1,
   category = 53000,
   subcategory = 53100,
   rarity = 1000,
   coefficient = 100,
   originalnameref2 = "deed",
   can_read_in_world_map = true,

   param1 = 1,

   color = { 255, 215, 175 },

   categories = {
      "elona.scroll",
      "elona.scroll_deed",
      "elona.no_generate"
   },
}

data:add {
   _type = "base.item",
   _id = "deed_of_shop",
   elona_id = 522,
   image = "elona.item_deed",
   value = 200000,
   weight = 500,
   on_read = deed_callback("elona.shop"),
   fltselect = 1,
   category = 53000,
   subcategory = 53100,
   rarity = 1000,
   coefficient = 100,
   originalnameref2 = "deed",
   can_read_in_world_map = true,

   param1 = 1,

   color = { 255, 155, 155 },

   categories = {
      "elona.scroll",
      "elona.scroll_deed",
      "elona.no_generate"
   },
}

data:add {
   _type = "base.item",
   _id = "deed_of_farm",
   elona_id = 542,
   image = "elona.item_deed",
   value = 45000,
   weight = 500,
   on_read = deed_callback("elona.crop"),
   fltselect = 1,
   category = 53000,
   subcategory = 53100,
   rarity = 1000,
   coefficient = 100,
   originalnameref2 = "deed",
   can_read_in_world_map = true,

   color = { 225, 225, 255 },

   categories = {
      "elona.scroll",
      "elona.scroll_deed",
      "elona.no_generate"
   },
}

data:add {
   _type = "base.item",
   _id = "deed_of_storage_house",
   elona_id = 543,
   image = "elona.item_deed",
   value = 10000,
   weight = 500,
   on_read = deed_callback("elona.storage_house"),
   fltselect = 1,
   category = 53000,
   subcategory = 53100,
   rarity = 1000,
   coefficient = 100,
   originalnameref2 = "deed",
   can_read_in_world_map = true,

   color = { 255, 225, 225 },

   categories = {
      "elona.scroll",
      "elona.scroll_deed",
      "elona.no_generate"
   },
}

data:add {
   _type = "base.item",
   _id = "deed_of_ranch",
   elona_id = 572,
   image = "elona.item_deed",
   value = 80000,
   weight = 500,
   on_read = deed_callback("elona.ranch"),
   fltselect = 1,
   category = 53000,
   subcategory = 53100,
   rarity = 1000,
   coefficient = 100,
   originalnameref2 = "deed",
   can_read_in_world_map = true,

   color = { 235, 215, 155 },

   categories = {
      "elona.scroll",
      "elona.scroll_deed",
      "elona.no_generate"
   },
}

data:add {
   _type = "base.item",
   _id = "deed_of_dungeon",
   elona_id = 712,
   image = "elona.item_deed",
   value = 500000,
   weight = 500,
   on_read = deed_callback("elona.dungeon"),
   fltselect = 1,
   category = 53000,
   subcategory = 53100,
   rarity = 1000,
   coefficient = 100,
   originalnameref2 = "deed",
   can_read_in_world_map = true,

   color = { 175, 175, 255 },

   categories = {
      "elona.scroll",
      "elona.scroll_deed",
      "elona.no_generate"
   },
}

--
-- Special
--

data:add {
   _type = "base.item",
   _id = "deed_of_heirship",
   elona_id = 511,
   image = "elona.item_deed",
   value = 10000,
   weight = 500,
   on_read = function(self)
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_deed_of_inheritance", power = self.params.deed_of_heirship_quality }})
   end,
   level = 3,
   category = 53000,
   rarity = 250000,
   coefficient = 100,
   originalnameref2 = "deed",

   params = { deed_of_heirship_quality = 0 },
   on_init_params = function(self)
      self.params.deed_of_heirship_quality = 100 + Rand.rnd(200)
   end,

   elona_type = "scroll",

   categories = {
      "elona.scroll",
   }
}

data:add {
   _type = "base.item",
   _id = "bill",
   elona_id = 615,
   image = "elona.item_bill",
   value = 100,
   weight = 100,
   fltselect = 1,
   category = 53000,
   rarity = 400000,
   coefficient = 100,

   is_precious = true,

   medal_value = 5,

   params = {
      bill_gold_amount = 0
   },

   categories = {
      "elona.scroll",
      "elona.no_generate"
   }
}

data:add {
   _type = "base.item",
   _id = "treasure_map",
   elona_id = 621,
   image = "elona.item_treasure_map",
   value = 10000,
   weight = 20,
   on_read = function(self, params)
      params.no_consume = true
      return ElonaMagic.read_scroll(self, {{ _id = "elona.effect_treasure_map", power = 100 }}, params)
   end,
   level = 5,
   category = 53000,
   rarity = 100000,
   coefficient = 100,

   elona_type = "scroll",

   can_read_in_world_map = true,

   tags = { "noshop", "spshop" },

   categories = {
      "elona.scroll",
      "elona.tag_noshop",
      "elona.tag_spshop"
   },

   events = {
      {
         id = "elona.on_item_created_from_wish",
         name = "Adjust amount",

         callback = function(self)
            -- >>>>>>>> shade2/command.hsp:1603 			if iId(ci)=idTreasureMap		:iNum(ci)=1 ..
            self.amount = 1
            -- <<<<<<<< shade2/command.hsp:1603 			if iId(ci)=idTreasureMap		:iNum(ci)=1 ..
         end
      },
   },
}

data:add {
   _type = "base.item",
   _id = "license_of_the_void_explorer",
   elona_id = 742,
   image = "elona.item_deed",
   value = 15000,
   weight = 500,
   fltselect = 3,
   category = 53000,
   rarity = 1000,
   coefficient = 100,
   originalnameref2 = "license",

   is_precious = true,
   quality = Enum.Quality.Unique,

   elona_type = "normal_book",

   on_read = function(self)
      -- >>>>>>>> shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBook: txt lang( ...
      Gui.play_sound("base.book1")
      Gui.mes("action.read.book.void_permit")
      return "turn_end"
      -- <<<<<<<< shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBook: txt lang( ..
   end,

   medal_value = 72,

   categories = {
      "elona.scroll",
      "elona.unique_item"
   }
}
