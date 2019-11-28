local Item = require("api.Item")

local class = {
   {
      _id = "warrior",
      ordering = 10010,

      copy_to_chara = {
         item_type = 1,
         equipment_type = 1
      },

      skills = {
         ["elona.stat_strength"] = 10,
         ["elona.stat_constitution"] = 10,
         ["elona.stat_dexterity"] = 2,
         ["elona.stat_perception"] = 0,
         ["elona.stat_learning"] = 0,
         ["elona.stat_will"] = 3,
         ["elona.stat_magic"] = 0,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.long_sword"] = 6,
         ["elona.short_sword"] = 4,
         ["elona.blunt"] = 6,
         ["elona.axe"] = 6,
         ["elona.polearm"] = 4,
         ["elona.scythe"] = 5,
         ["elona.two_hand"] = 6,
         ["elona.tactics"] = 4,
         ["elona.evasion"] = 5,
         ["elona.healing"] = 5,
         ["elona.medium_armor"] = 4,
         ["elona.heavy_armor"] = 4,
         ["elona.shield"] = 5,
      }
   },
   {
      _id = "thief",
      ordering = 10020,

      copy_to_chara = {
         item_type = 7,
         equipment_type = 7
      },

      skills = {
         ["elona.stat_strength"] = 4,
         ["elona.stat_constitution"] = 4,
         ["elona.stat_dexterity"] = 8,
         ["elona.stat_perception"] = 5,
         ["elona.stat_learning"] = 4,
         ["elona.stat_will"] = 0,
         ["elona.stat_magic"] = 0,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.short_sword"] = 4,
         ["elona.long_sword"] = 3,
         ["elona.bow"] = 3,
         ["elona.evasion"] = 4,
         ["elona.dual_wield"] = 4,
         ["elona.tactics"] = 3,
         ["elona.negotiation"] = 4,
         ["elona.pickpocket"] = 4,
         ["elona.magic_device"] = 3,
         ["elona.medium_armor"] = 4,
      }
   },
   {
      _id = "wizard",
      ordering = 10030,

      copy_to_chara = {
         item_type = 2,
         equipment_type = 2
      },

      skills = {
         ["elona.stat_strength"] = 0,
         ["elona.stat_constitution"] = 0,
         ["elona.stat_dexterity"] = 0,
         ["elona.stat_perception"] = 4,
         ["elona.stat_learning"] = 3,
         ["elona.stat_will"] = 8,
         ["elona.stat_magic"] = 10,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.stave"] = 3,
         ["elona.short_sword"] = 2,
         ["elona.literacy"] = 6,
         ["elona.memorization"] = 3,
         ["elona.magic_capacity"] = 6,
         ["elona.magic_device"] = 5,
         ["elona.light_armor"] = 4,
         ["elona.alchemy"] = 4,
         ["elona.casting"] = 5,
      },

      on_init_player = function(player)
         Item.create("elona.spellbook_of_minor_teleportation", nil, nil, {}, player)
         Item.create("elona.spellbook_of_magic_arrow", nil, nil, {amount=3}, player)
      end
   },
   {
      _id = "farmer",
      ordering = 10040,

      copy_to_chara = {
         item_type = 1,
         equipment_type = 1
      },

      skills = {
         ["elona.stat_strength"] = 5,
         ["elona.stat_constitution"] = 5,
         ["elona.stat_dexterity"] = 2,
         ["elona.stat_perception"] = 0,
         ["elona.stat_learning"] = 8,
         ["elona.stat_will"] = 5,
         ["elona.stat_magic"] = 0,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.polearm"] = 4,
         ["elona.scythe"] = 3,
         ["elona.evasion"] = 3,
         ["elona.negotiation"] = 5,
         ["elona.cooking"] = 6,
         ["elona.anatomy"] = 7,
         ["elona.healing"] = 5,
         ["elona.gardening"] = 5,
         ["elona.tailoring"] = 5,
      },

      on_init_player = function(player)
         Item.create("elona.portable_cooking_tool", nil, nil, {}, player)
      end
   },
   {
      _id = "predator",
      ordering = 20010,
      is_extra = true,

      copy_to_chara = {
         item_type = 0,
         equipment_type = 0
      },

      skills = {
         ["elona.stat_strength"] = 8,
         ["elona.stat_constitution"] = 11,
         ["elona.stat_dexterity"] = 8,
         ["elona.stat_perception"] = 0,
         ["elona.stat_learning"] = 0,
         ["elona.stat_will"] = 0,
         ["elona.stat_magic"] = 0,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 10,
         ["elona.tactics"] = 4,
      }
   },
   {
      _id = "archer",
      ordering = 10050,

      copy_to_chara = {
         item_type = 3,
         equipment_type = 3
      },

      skills = {
         ["elona.stat_strength"] = 6,
         ["elona.stat_constitution"] = 4,
         ["elona.stat_dexterity"] = 8,
         ["elona.stat_perception"] = 5,
         ["elona.stat_learning"] = 2,
         ["elona.stat_will"] = 0,
         ["elona.stat_magic"] = 0,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.bow"] = 5,
         ["elona.crossbow"] = 5,
         ["elona.short_sword"] = 4,
         ["elona.axe"] = 3,
         ["elona.evasion"] = 5,
         ["elona.magic_device"] = 3,
         ["elona.medium_armor"] = 3,
         ["elona.tailoring"] = 4,
         ["elona.riding"] = 4,
         ["elona.marksman"] = 3,
      }
   },
   {
      _id = "warmage",
      ordering = 10060,

      copy_to_chara = {
         item_type = 5,
         equipment_type = 5
      },

      skills = {
         ["elona.stat_strength"] = 6,
         ["elona.stat_constitution"] = 6,
         ["elona.stat_dexterity"] = 2,
         ["elona.stat_perception"] = 0,
         ["elona.stat_learning"] = 0,
         ["elona.stat_will"] = 4,
         ["elona.stat_magic"] = 7,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.long_sword"] = 4,
         ["elona.short_sword"] = 3,
         ["elona.evasion"] = 3,
         ["elona.literacy"] = 4,
         ["elona.magic_capacity"] = 3,
         ["elona.magic_device"] = 5,
         ["elona.medium_armor"] = 4,
         ["elona.heavy_armor"] = 4,
         ["elona.casting"] = 4,
      },

      on_init_player = function(player)
         Item.create("elona.spellbook_of_minor_teleportation", nil, nil, {}, player)
         Item.create("elona.spellbook_of_magic_arrow", nil, nil, {amount=3}, player)
      end
   },
   {
      _id = "tourist",
      ordering = 10070,

      copy_to_chara = {
         item_type = 0,
         equipment_type = 0
      },

      skills = {
         ["elona.stat_strength"] = 0,
         ["elona.stat_constitution"] = 0,
         ["elona.stat_dexterity"] = 0,
         ["elona.stat_perception"] = 0,
         ["elona.stat_learning"] = 0,
         ["elona.stat_will"] = 0,
         ["elona.stat_magic"] = 0,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.fishing"] = 5,
         ["elona.traveling"] = 3,
      }
   },
   {
      _id = "pianist",
      ordering = 10080,

      copy_to_chara = {
         item_type = 3,
         equipment_type = 3
      },

      skills = {
         ["elona.stat_strength"] = 6,
         ["elona.stat_constitution"] = 0,
         ["elona.stat_dexterity"] = 4,
         ["elona.stat_perception"] = 5,
         ["elona.stat_learning"] = 6,
         ["elona.stat_will"] = 0,
         ["elona.stat_magic"] = 4,
         ["elona.stat_charisma"] = 8,
         ["elona.stat_speed"] = 0,
         ["elona.performer"] = 6,
         ["elona.weight_lifting"] = 19,
         ["elona.literacy"] = 4,
         ["elona.memorization"] = 6,
         ["elona.magic_device"] = 6,
         ["elona.jeweler"] = 5,
         ["elona.light_armor"] = 4,
         ["elona.riding"] = 3,
      },

      on_init_player = function(player)
         Item.create("elona.grand_piano", nil, nil, {}, player)
      end
   },
   {
      _id = "gunner",
      ordering = 20020,
      is_extra = true,

      copy_to_chara = {
         item_type = 4,
         equipment_type = 4
      },

      skills = {
         ["elona.stat_strength"] = 0,
         ["elona.stat_constitution"] = 2,
         ["elona.stat_dexterity"] = 5,
         ["elona.stat_perception"] = 8,
         ["elona.stat_learning"] = 5,
         ["elona.stat_will"] = 4,
         ["elona.stat_magic"] = 3,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.firearm"] = 5,
         ["elona.evasion"] = 4,
         ["elona.literacy"] = 3,
         ["elona.healing"] = 4,
         ["elona.marksman"] = 3,
      }
   },
   {
      _id = "priest",
      ordering = 10090,

      copy_to_chara = {
         item_type = 6,
         equipment_type = 6
      },

      skills = {
         ["elona.stat_strength"] = 2,
         ["elona.stat_constitution"] = 2,
         ["elona.stat_dexterity"] = 0,
         ["elona.stat_perception"] = 2,
         ["elona.stat_learning"] = 2,
         ["elona.stat_will"] = 10,
         ["elona.stat_magic"] = 7,
         ["elona.stat_charisma"] = 2,
         ["elona.stat_speed"] = 0,
         ["elona.blunt"] = 3,
         ["elona.shield"] = 3,
         ["elona.literacy"] = 5,
         ["elona.healing"] = 5,
         ["elona.magic_device"] = 5,
         ["elona.medium_armor"] = 3,
         ["elona.heavy_armor"] = 4,
         ["elona.faith"] = 5,
         ["elona.casting"] = 5,
      },

      on_init_player = function(player)
         Item.create("elona.spellbook_of_cure_minor_wound", nil, nil, {amount=3}, player)
         Item.create("elona.spellbook_of_hero", nil, nil, {}, player)
      end
   },
   {
      _id = "claymore",
      ordering = 10100,

      copy_to_chara = {
         item_type = 8,
         equipment_type = 8
      },

      skills = {
         ["elona.stat_strength"] = 9,
         ["elona.stat_constitution"] = 3,
         ["elona.stat_dexterity"] = 7,
         ["elona.stat_perception"] = 6,
         ["elona.stat_learning"] = 0,
         ["elona.stat_will"] = 0,
         ["elona.stat_magic"] = 4,
         ["elona.stat_charisma"] = 0,
         ["elona.stat_speed"] = 0,
         ["elona.long_sword"] = 6,
         ["elona.two_hand"] = 7,
         ["elona.tactics"] = 5,
         ["elona.evasion"] = 7,
         ["elona.greater_evasion"] = 4,
         ["elona.healing"] = 6,
         ["elona.light_armor"] = 5,
         ["elona.literacy"] = 4,
      }
   },
}

data:add_multi("base.class", class)
