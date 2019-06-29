local Resolver = require("api.Resolver")
-- builtin:
-- is_extra
-- ordering
--
-- all else should be copy_to_chara

-- TODO: there needs to be some way of resolving "male_ratio" before
-- "elona.by_gender".

local race =
   {
      {
         _id = "kobold",
         is_extra = true,
         ordering = 20010,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 3,
               ["elona.stat_learning"] = 2,
               ["elona.stat_will"] = 2,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.pickpocket"] = 3,
               ["elona.stealth"] = 2,
               ["elona.magic_device"] = 3,
            },

            breed_power = 250,
            image = Resolver.make("elona.by_gender", { male = 171, female = 171 }),
            age = Resolver.make("base.between", { min = 15, max = 44 }),
            height = 150,
            gender = Resolver.make("elona.gender", { male_ratio = 50 }),
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "orc",
         is_extra = true,
         ordering = 20020,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 130,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 3,
               ["elona.stat_perception"] = 2,
               ["elona.stat_learning"] = 2,
               ["elona.stat_will"] = 3,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 1,
               ["elona.healing"] = 3,
               ["elona.heavy_armor"] = 3,
               ["elona.shield"] = 3,
            },

            breed_power = 300,
            image = Resolver.make("elona.by_gender", { male = 165, female = 165 }),
            age = Resolver.make("base.between", { min = 15, max = 44 }),
            height = 150,
            gender = Resolver.make("elona.gender", { male_ratio = 51 }),
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "troll",
         is_extra = true,
         ordering = 20030,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 10,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 1,
               ["elona.stat_perception"] = 2,
               ["elona.stat_learning"] = 2,
               ["elona.stat_will"] = 2,
               ["elona.stat_magic"] = 3,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 3,
               ["elona.healing"] = 40,
            },

            breed_power = 250,
            image = Resolver.make("elona.by_gender", { male = 391, female = 391 }),
            age = Resolver.make("base.between", { min = 15, max = 44 }),
            height = 400,
            gender = Resolver.make("elona.gender", { male_ratio = 51 }),
            pv_correction = 150,
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.waist"
            },

         },

      },
      {
         _id = "lizardman",
         is_extra = true,
         ordering = 20040,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 120,
               ["elona.stat_mana"] = 70,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 5,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 80,
               ["elona.martial_arts"] = 2,
               ["elona.polearm"] = 3,
               ["elona.shield"] = 3,
               ["elona.evasion"] = 2,
            },

            breed_power = 300,
            image = Resolver.make("elona.by_gender", { male = 397, female = 397 }),
            age = Resolver.make("base.between", { min = 15, max = 44 }),
            height = 240,
            gender = Resolver.make("elona.gender", { male_ratio = 51 }),
            dv_correction = 120,
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "minotaur",
         is_extra = true,
         ordering = 20050,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 160,
               ["elona.stat_mana"] = 60,
               ["elona.stat_strength"] = 12,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 3,
               ["elona.stat_perception"] = 4,
               ["elona.stat_learning"] = 3,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 65,
               ["elona.martial_arts"] = 3,
               ["elona.tactics"] = 4,
               ["elona.eye_of_mind"] = 3,
            },

            breed_power = 300,
            image = Resolver.make("elona.by_gender", { male = 398, female = 398 }),
            age = Resolver.make("base.between", { min = 15, max = 44 }),
            height = 350,
            gender = Resolver.make("elona.gender", { male_ratio = 51 }),
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "yerles",
         is_extra = false,
         ordering = 10010,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 110,
               ["elona.stat_mana"] = 90,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 12,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 8,
               ["elona.stat_charisma"] = 7,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.firearm"] = 5,
               ["elona.literacy"] = 3,
               ["elona.negotiation"] = 2,
               ["elona.throwing"] = 3,
            },

            breed_power = 220,
            image = Resolver.make("elona.by_gender", { male = 1, female = 2 }),
            age = Resolver.make("base.between", { min = 15, max = 34 }),
            height = 165,
            gender = Resolver.make("elona.gender", { male_ratio = 52 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "norland",
         is_extra = true,
         ordering = 20060,

         copy_to_chara = {
            skills = Resolver.make(
               "elona.skills",
               {
                  skills = {
                     ["elona.stat_life"] = 100,
                     ["elona.stat_mana"] = 90,
                     ["elona.stat_strength"] = 8,
                     ["elona.stat_constitution"] = 8,
                     ["elona.stat_dexterity"] = 6,
                     ["elona.stat_perception"] = 6,
                     ["elona.stat_learning"] = 7,
                     ["elona.stat_will"] = 9,
                     ["elona.stat_magic"] = 7,
                     ["elona.stat_charisma"] = 6,
                     ["elona.stat_speed"] = 70,
                     ["elona.martial_arts"] = 2,
                     ["elona.casting"] = 3,
                     ["elona.tactics"] = 3,
                     ["elona.two_hand"] = 3,
                     ["elona.control_magic"] = 3,
                  }
               }
            ),

            breed_power = 220,
            image = Resolver.make("elona.by_gender", { male = 1, female = 2 }),
            age = Resolver.make("base.between", { min = 15, max = 34 }),
            height = 170,
            gender = Resolver.make("elona.gender", { male_ratio = 52 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "eulderna",
         is_extra = false,
         ordering = 10020,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 10,
               ["elona.stat_magic"] = 12,
               ["elona.stat_charisma"] = 8,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.casting"] = 5,
               ["elona.literacy"] = 3,
               ["elona.magic_device"] = 3,
            },

            breed_power = 180,
            image = Resolver.make("elona.by_gender", { male = 5, female = 6 }),
            age = Resolver.make("base.between", { min = 16, max = 35 }),
            height = 175,
            gender = Resolver.make("elona.gender", { male_ratio = 52 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "fairy",
         is_extra = false,
         ordering = 10030,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 40,
               ["elona.stat_mana"] = 130,
               ["elona.stat_strength"] = 3,
               ["elona.stat_constitution"] = 4,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 13,
               ["elona.stat_charisma"] = 12,
               ["elona.stat_speed"] = 120,
               ["elona.martial_arts"] = 1,
               ["elona.casting"] = 5,
               ["elona.pickpocket"] = 3,
               ["elona.light_armor"] = 3,
            },

            breed_power = 180,
            image = Resolver.make("elona.by_gender", { male = 390, female = 390 }),
            age = Resolver.make("base.between", { min = 5, max = 104 }),
            height = 50,
            gender = Resolver.make("elona.gender", { male_ratio = 52 }),
            resistances = {
               ["elona.element_magic"] = 200,
               ["elona.element_darkness"] = 200,
               ["elona.element_nerve"] = 200,
               ["elona.element_nether"] = 200,
               ["elona.element_mind"] = 200,
               ["elona.element_sound"] = 200,
               ["elona.element_chaos"] = 200,
            },
            dv_correction = 250,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "asura",
         is_extra = true,
         ordering = 20070,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 70,
               ["elona.stat_strength"] = 11,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 14,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 5,
               ["elona.stat_charisma"] = 5,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.dual_wield"] = 30,
               ["elona.greater_evasion"] = 6,
               ["elona.anatomy"] = 4,
            },

            breed_power = 100,
            image = Resolver.make("elona.by_gender", { male = 405, female = 405 }),
            age = Resolver.make("base.between", { min = 15, max = 34 }),
            height = 220,
            gender = Resolver.make("elona.gender", { male_ratio = 52 }),
            dv_correction = 200,
            body_parts = {
               "elona.hand",
               "elona.hand",
               "elona.hand",
               "elona.hand",
               "elona.neck"
            },

         },

      },
      {
         _id = "slime",
         is_extra = true,
         ordering = 20080,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 4,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 5,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 13,
               ["elona.stat_speed"] = 55,
               ["elona.martial_arts"] = 2,
               ["elona.evasion"] = 2,
               ["elona.performer"] = 3,
            },

            breed_power = 700,
            image = Resolver.make("elona.by_gender", { male = 168, female = 168 }),
            special_attack_type = 2,
            age = Resolver.make("base.between", { min = 1, max = 10 }),
            height = 40,
            gender = Resolver.make("elona.gender", { male_ratio = 54 }),
            body_parts = {
               "elona.head"
            },

         },

      },
      {
         _id = "wolf",
         is_extra = true,
         ordering = 20090,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 11,
               ["elona.stat_learning"] = 7,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 6,
               ["elona.stat_speed"] = 80,
               ["elona.martial_arts"] = 2,
               ["elona.evasion"] = 2,
               ["elona.greater_evasion"] = 2,
            },

            breed_power = 800,
            image = Resolver.make("elona.by_gender", { male = 254, female = 254 }),
            age = Resolver.make("base.between", { min = 2, max = 11 }),
            height = 100,
            gender = Resolver.make("elona.gender", { male_ratio = 55 }),
            dv_correction = 140,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "dwarf",
         is_extra = false,
         ordering = 10040,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 10,
               ["elona.stat_constitution"] = 11,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 7,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 6,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.cooking"] = 4,
               ["elona.jeweler"] = 3,
               ["elona.mining"] = 4,
            },

            breed_power = 150,
            image = Resolver.make("elona.by_gender", { male = 66, female = 66 }),
            age = Resolver.make("base.between", { min = 20, max = 79 }),
            height = 100,
            gender = Resolver.make("elona.gender", { male_ratio = 56 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "juere",
         is_extra = false,
         ordering = 10050,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 12,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 10,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 8,
               ["elona.stat_charisma"] = 11,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.performer"] = 4,
               ["elona.lock_picking"] = 2,
               ["elona.negotiation"] = 2,
               ["elona.throwing"] = 3,
            },

            breed_power = 210,
            image = Resolver.make("elona.by_gender", { male = 9, female = 10 }),
            age = Resolver.make("base.between", { min = 15, max = 44 }),
            height = 165,
            gender = Resolver.make("elona.gender", { male_ratio = 50 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "zombie",
         is_extra = true,
         ordering = 20100,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 120,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 10,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 2,
               ["elona.stat_perception"] = 2,
               ["elona.stat_learning"] = 1,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 45,
               ["elona.martial_arts"] = 3,
               ["elona.cooking"] = 3,
               ["elona.fishing"] = 3,
            },

            breed_power = 100,
            image = Resolver.make("elona.by_gender", { male = 167, female = 167 }),
            age = Resolver.make("base.between", { min = 10, max = 209 }),
            height = 160,
            gender = Resolver.make("elona.gender", { male_ratio = 50 }),
            resistances = {
               ["elona.element_darkness"] = 500,
               ["elona.element_nerve"] = 500,
               ["elona.element_nether"] = 500,
               ["elona.element_fire"] = 80,
            },
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.waist"
            },

         },

      },
      {
         _id = "elea",
         is_extra = false,
         ordering = 10060,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 110,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 12,
               ["elona.stat_magic"] = 13,
               ["elona.stat_charisma"] = 10,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.magic_capacity"] = 5,
               ["elona.casting"] = 2,
               ["elona.memorization"] = 3,
            },

            breed_power = 120,
            image = Resolver.make("elona.by_gender", { male = 3, female = 4 }),
            age = Resolver.make("base.between", { min = 10, max = 209 }),
            height = 180,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "rabbit",
         is_extra = true,
         ordering = 20110,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 4,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 11,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 10,
               ["elona.stat_speed"] = 100,
               ["elona.martial_arts"] = 1,
               ["elona.riding"] = 3,
            },

            breed_power = 800,
            image = Resolver.make("elona.by_gender", { male = 169, female = 169 }),
            age = Resolver.make("base.between", { min = 2, max = 6 }),
            height = 40,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.ring"
            },

         },

      },
      {
         _id = "sheep",
         is_extra = true,
         ordering = 20120,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 130,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 8,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 1,
               ["elona.healing"] = 3,
               ["elona.anatomy"] = 3,
            },

            breed_power = 1000,
            image = Resolver.make("elona.by_gender", { male = 170, female = 170 }),
            age = Resolver.make("base.between", { min = 2, max = 6 }),
            height = 150,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "frog",
         is_extra = true,
         ordering = 20130,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 5,
               ["elona.stat_charisma"] = 6,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 1,
               ["elona.performer"] = 3,
               ["elona.investing"] = 2,
            },

            breed_power = 600,
            image = Resolver.make("elona.by_gender", { male = 172, female = 172 }),
            age = Resolver.make("base.between", { min = 2, max = 6 }),
            height = 10,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {4},

         },

      },
      {
         _id = "centipede",
         is_extra = true,
         ordering = 20140,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 3,
               ["elona.stat_will"] = 2,
               ["elona.stat_magic"] = 2,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 1,
               ["elona.eye_of_mind"] = 3,
            },

            breed_power = 400,
            image = Resolver.make("elona.by_gender", { male = 173, female = 173 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 10,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.back",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "snail",
         is_extra = false,
         ordering = 10070,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 4,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 3,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 3,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 2,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 25,
               ["elona.martial_arts"] = 1,
               ["elona.throwing"] = 5,
            },

            breed_power = 500,
            image = Resolver.make("elona.by_gender", { male = 174, female = 174 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 8,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.back"
            },

         },

      },
      {
         _id = "mandrake",
         is_extra = true,
         ordering = 20150,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 70,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 10,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 2,
               ["elona.memorization"] = 3,
               ["elona.literacy"] = 2,
               ["elona.magic_capacity"] = 3,
            },

            breed_power = 80,
            image = Resolver.make("elona.by_gender", { male = 175, female = 175 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 25,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.back"
            },

         },

      },
      {
         _id = "beetle",
         is_extra = true,
         ordering = 20160,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 75,
               ["elona.martial_arts"] = 2,
               ["elona.detection"] = 3,
               ["elona.stealth"] = 3,
            },

            breed_power = 750,
            image = Resolver.make("elona.by_gender", { male = 176, female = 176 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 10,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 140,
            body_parts = {
               "elona.neck"
            },

         },

      },
      {
         _id = "mushroom",
         is_extra = true,
         ordering = 20170,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 50,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 4,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 10,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 1,
               ["elona.tailoring"] = 3,
               ["elona.alchemy"] = 2,
            },

            breed_power = 440,
            image = Resolver.make("elona.by_gender", { male = 177, female = 177 }),
            melee_attack_type = 7,
            special_attack_type = 5,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 20,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck"
            },

         },

      },
      {
         _id = "bat",
         is_extra = true,
         ordering = 20180,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 10,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 3,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 9,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 3,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 140,
               ["elona.martial_arts"] = 2,
               ["elona.greater_evasion"] = 3,
            },

            breed_power = 350,
            image = Resolver.make("elona.by_gender", { male = 200, female = 200 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 70,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 320,
            body_parts = {
               "elona.head"
            },

         },

      },
      {
         _id = "ent",
         is_extra = true,
         ordering = 20190,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 170,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 9,
               ["elona.stat_constitution"] = 12,
               ["elona.stat_dexterity"] = 4,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 2,
               ["elona.stat_will"] = 3,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 50,
               ["elona.martial_arts"] = 3,
               ["elona.healing"] = 2,
               ["elona.carpentry"] = 4,
            },

            breed_power = 35,
            image = Resolver.make("elona.by_gender", { male = 201, female = 201 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 1500,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "lich",
         is_extra = false,
         ordering = 10080,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 140,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 10,
               ["elona.stat_will"] = 13,
               ["elona.stat_magic"] = 15,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 3,
               ["elona.meditation"] = 5,
               ["elona.magic_device"] = 3,
               ["elona.casting"] = 3,
            },

            breed_power = 25,
            image = Resolver.make("elona.by_gender", { male = 202, female = 202 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 180,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            resistances = {
               ["elona.element_darkness"] = 500,
               ["elona.element_nerve"] = 500,
               ["elona.element_nether"] = 500,
               ["elona.element_fire"] = 80,
            },
            dv_correction = 190,
            pv_correction = 150,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "hound",
         is_extra = true,
         ordering = 20200,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 11,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 3,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 90,
               ["elona.martial_arts"] = 2,
               ["elona.detection"] = 4,
               ["elona.performer"] = 2,
            },

            breed_power = 540,
            image = Resolver.make("elona.by_gender", { male = 203, female = 203 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 160,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 120,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.leg"
            },

         },

      },
      {
         _id = "ghost",
         is_extra = true,
         ordering = 20210,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 60,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 4,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 14,
               ["elona.stat_learning"] = 7,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 11,
               ["elona.stat_charisma"] = 11,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 2,
               ["elona.magic_capacity"] = 4,
               ["elona.magic_device"] = 2,
            },

            breed_power = 30,
            image = Resolver.make("elona.by_gender", { male = 205, female = 205 }),
            melee_attack_type = 6,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 180,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            resistances = {
               ["elona.element_darkness"] = 500,
               ["elona.element_nerve"] = 500,
               ["elona.element_nether"] = 500,
               ["elona.element_fire"] = 80,
            },
            dv_correction = 160,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "spirit",
         is_extra = true,
         ordering = 20220,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 10,
               ["elona.stat_magic"] = 13,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 2,
               ["elona.casting"] = 3,
               ["elona.control_magic"] = 2,
            },

            breed_power = 25,
            image = Resolver.make("elona.by_gender", { male = 206, female = 206 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 100,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "eye",
         is_extra = true,
         ordering = 20230,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 3,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 4,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 7,
               ["elona.stat_magic"] = 10,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 25,
               ["elona.martial_arts"] = 2,
               ["elona.detection"] = 3,
               ["elona.anatomy"] = 3,
            },

            breed_power = 50,
            image = Resolver.make("elona.by_gender", { male = 207, female = 207 }),
            melee_attack_type = 4,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 40,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head"
            },

         },

      },
      {
         _id = "wyvern",
         is_extra = true,
         ordering = 20240,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 190,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 11,
               ["elona.stat_constitution"] = 13,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 9,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 7,
               ["elona.stat_magic"] = 8,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 3,
               ["elona.literacy"] = 3,
               ["elona.traveling"] = 3,
            },

            breed_power = 100,
            image = Resolver.make("elona.by_gender", { male = 235, female = 235 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 1600,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "wasp",
         is_extra = true,
         ordering = 20250,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 50,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 13,
               ["elona.stat_perception"] = 11,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 3,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 100,
               ["elona.martial_arts"] = 2,
               ["elona.greater_evasion"] = 2,
            },

            breed_power = 580,
            image = Resolver.make("elona.by_gender", { male = 210, female = 210 }),
            melee_attack_type = 5,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 80,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 220,
            body_parts = {
               "elona.head"
            },

         },

      },
      {
         _id = "giant",
         is_extra = true,
         ordering = 20260,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 200,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 12,
               ["elona.stat_constitution"] = 14,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 4,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 4,
               ["elona.anatomy"] = 3,
               ["elona.magic_device"] = 2,
               ["elona.carpentry"] = 3,
            },

            breed_power = 60,
            image = Resolver.make("elona.by_gender", { male = 232, female = 232 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 1800,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "imp",
         is_extra = true,
         ordering = 20270,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 70,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.memorization"] = 3,
               ["elona.control_magic"] = 3,
            },

            breed_power = 240,
            image = Resolver.make("elona.by_gender", { male = 212, female = 212 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 80,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 200,
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "hand",
         is_extra = true,
         ordering = 20280,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 4,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 5,
               ["elona.stat_charisma"] = 2,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.eye_of_mind"] = 4,
            },

            breed_power = 160,
            image = Resolver.make("elona.by_gender", { male = 213, female = 213 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 70,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "snake",
         is_extra = true,
         ordering = 20290,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.stealth"] = 4,
            },

            breed_power = 430,
            image = Resolver.make("elona.by_gender", { male = 216, female = 216 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 50,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {4},

         },

      },
      {
         _id = "drake",
         is_extra = true,
         ordering = 20300,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 160,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 11,
               ["elona.stat_constitution"] = 12,
               ["elona.stat_dexterity"] = 11,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 9,
               ["elona.stat_magic"] = 8,
               ["elona.stat_charisma"] = 7,
               ["elona.stat_speed"] = 85,
               ["elona.martial_arts"] = 3,
               ["elona.traveling"] = 3,
               ["elona.fishing"] = 2,
            },

            breed_power = 120,
            image = Resolver.make("elona.by_gender", { male = 233, female = 233 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 1400,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 120,
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "goblin",
         is_extra = false,
         ordering = 10090,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 110,
               ["elona.stat_mana"] = 90,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 5,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 7,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.healing"] = 5,
               ["elona.fishing"] = 2,
               ["elona.mining"] = 2,
               ["elona.eye_of_mind"] = 3,
            },

            breed_power = 290,
            image = Resolver.make("elona.by_gender", { male = 220, female = 220 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 140,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "bear",
         is_extra = true,
         ordering = 20310,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 160,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 9,
               ["elona.stat_constitution"] = 10,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 3,
               ["elona.stat_charisma"] = 5,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.healing"] = 3,
               ["elona.performer"] = 2,
               ["elona.eye_of_mind"] = 3,
            },

            breed_power = 350,
            image = Resolver.make("elona.by_gender", { male = 222, female = 222 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 280,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "armor",
         is_extra = true,
         ordering = 20320,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 40,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 4,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 5,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 50,
               ["elona.martial_arts"] = 2,
               ["elona.lock_picking"] = 3,
               ["elona.magic_device"] = 2,
            },

            breed_power = 40,
            image = Resolver.make("elona.by_gender", { male = 223, female = 223 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 550,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 300,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.waist"
            },

         },

      },
      {
         _id = "medusa",
         is_extra = true,
         ordering = 20330,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 110,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 7,
               ["elona.stat_will"] = 9,
               ["elona.stat_magic"] = 11,
               ["elona.stat_charisma"] = 5,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 3,
               ["elona.magic_capacity"] = 3,
               ["elona.control_magic"] = 3,
            },

            breed_power = 180,
            image = Resolver.make("elona.by_gender", { male = 224, female = 224 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 160,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 140,
            body_parts = {
               "elona.body",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "cupid",
         is_extra = true,
         ordering = 20340,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 130,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 7,
               ["elona.stat_magic"] = 12,
               ["elona.stat_charisma"] = 8,
               ["elona.stat_speed"] = 80,
               ["elona.martial_arts"] = 2,
               ["elona.literacy"] = 4,
               ["elona.control_magic"] = 3,
            },

            breed_power = 350,
            image = Resolver.make("elona.by_gender", { male = 225, female = 225 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 120,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 200,
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "phantom",
         is_extra = true,
         ordering = 20350,
         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 60,
               ["elona.stat_mana"] = 90,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 9,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 85,
               ["elona.martial_arts"] = 2,
               ["elona.stealth"] = 3,
               ["elona.disarm_trap"] = 3,
            },

            breed_power = 35,
            image = Resolver.make("elona.by_gender", { male = 226, female = 226 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 450,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            resistances = {
               ["elona.element_darkness"] = 500,
               ["elona.element_nerve"] = 500,
               ["elona.element_nether"] = 500,
               ["elona.element_fire"] = 80,
            },
            pv_correction = 200,
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "harpy",
         is_extra = true,
         ordering = 20360,
         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 9,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 9,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 80,
               ["elona.martial_arts"] = 2,
               ["elona.magic_capacity"] = 3,
               ["elona.magic_device"] = 2,
            },

            breed_power = 420,
            image = Resolver.make("elona.by_gender", { male = 227, female = 227 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 140,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 150,
            body_parts = {
               "elona.neck",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.leg",
               "elona.leg"
            },

         },

      },
      {
         _id = "dragon",
         is_extra = true,
         ordering = 20370,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 220,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 13,
               ["elona.stat_constitution"] = 15,
               ["elona.stat_dexterity"] = 10,
               ["elona.stat_perception"] = 9,
               ["elona.stat_learning"] = 10,
               ["elona.stat_will"] = 9,
               ["elona.stat_magic"] = 13,
               ["elona.stat_charisma"] = 9,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 3,
               ["elona.traveling"] = 3,
               ["elona.jeweler"] = 3,
            },

            breed_power = 20,
            image = Resolver.make("elona.by_gender", { male = 228, female = 228 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 2400,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 120,
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "dinosaur",
         is_extra = true,
         ordering = 20380,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 140,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 10,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 5,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 5,
               ["elona.stat_speed"] = 120,
               ["elona.martial_arts"] = 4,
               ["elona.traveling"] = 3,
               ["elona.greater_evasion"] = 2,
            },

            breed_power = 100,
            image = Resolver.make("elona.by_gender", { male = 389, female = 389 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 2000,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 120,
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "cerberus",
         is_extra = true,
         ordering = 20390,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 160,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 11,
               ["elona.stat_constitution"] = 9,
               ["elona.stat_dexterity"] = 10,
               ["elona.stat_perception"] = 11,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 85,
               ["elona.martial_arts"] = 3,
               ["elona.detection"] = 3,
               ["elona.tailoring"] = 3,
            },

            breed_power = 80,
            image = Resolver.make("elona.by_gender", { male = 229, female = 229 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 1200,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.ring",
               "elona.leg",
               "elona.leg"
            },

         },

      },
      {
         _id = "spider",
         is_extra = true,
         ordering = 20400,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 50,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 12,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 8,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 120,
               ["elona.martial_arts"] = 2,
               ["elona.stealth"] = 3,
               ["elona.anatomy"] = 5,
            },

            breed_power = 560,
            image = Resolver.make("elona.by_gender", { male = 230, female = 230 }),
            melee_attack_type = 3,
            special_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 60,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            dv_correction = 170,
            body_parts = {
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "golem",
         is_extra = false,
         ordering = 10100,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 150,
               ["elona.stat_mana"] = 70,
               ["elona.stat_strength"] = 10,
               ["elona.stat_constitution"] = 14,
               ["elona.stat_dexterity"] = 4,
               ["elona.stat_perception"] = 5,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 9,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 45,
               ["elona.martial_arts"] = 4,
               ["elona.weight_lifting"] = 5,
               ["elona.mining"] = 3,
            },

            breed_power = 40,
            image = Resolver.make("elona.by_gender", { male = 231, female = 231 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 700,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 140,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "rock",
         is_extra = true,
         ordering = 20410,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 40,
               ["elona.stat_mana"] = 50,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 22,
               ["elona.stat_dexterity"] = 3,
               ["elona.stat_perception"] = 8,
               ["elona.stat_learning"] = 2,
               ["elona.stat_will"] = 3,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 10,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 1,
               ["elona.weight_lifting"] = 3,
               ["elona.mining"] = 3,
            },

            breed_power = 200,
            image = Resolver.make("elona.by_gender", { male = 386, female = 386 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 500,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 200,
            body_parts = {
               "elona.head"
            },

         },

      },
      {
         _id = "crab",
         is_extra = true,
         ordering = 20420,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 60,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 3,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.disarm_trap"] = 2,
               ["elona.shield"] = 3,
            },

            breed_power = 420,
            image = Resolver.make("elona.by_gender", { male = 237, female = 237 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 50,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 150,
            body_parts = {
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "skeleton",
         is_extra = true,
         ordering = 20430,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 8,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 9,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.long_sword"] = 3,
               ["elona.shield"] = 2,
               ["elona.lock_picking"] = 3,
            },

            breed_power = 30,
            image = Resolver.make("elona.by_gender", { male = 241, female = 241 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 160,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            resistances = {
               ["elona.element_darkness"] = 500,
               ["elona.element_nerve"] = 500,
               ["elona.element_nether"] = 500,
               ["elona.element_fire"] = 80,
            },
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "piece",
         is_extra = true,
         ordering = 20440,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 120,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 9,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 4,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 9,
               ["elona.stat_magic"] = 10,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.magic_capacity"] = 2,
               ["elona.literacy"] = 3,
            },

            breed_power = 25,
            image = Resolver.make("elona.by_gender", { male = 244, female = 244 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 750,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 150,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist"
            },

         },

      },
      {
         _id = "cat",
         is_extra = true,
         ordering = 20450,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 120,
               ["elona.stat_mana"] = 120,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 12,
               ["elona.stat_speed"] = 110,
               ["elona.martial_arts"] = 2,
               ["elona.performer"] = 2,
               ["elona.greater_evasion"] = 3,
               ["elona.evasion"] = 2,
            },

            breed_power = 950,
            image = Resolver.make("elona.by_gender", { male = 253, female = 253 }),
            melee_attack_type = 1,
            special_attack_type = 4,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 60,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.leg",
               "elona.leg"
            },

         },

      },
      {
         _id = "dog",
         is_extra = true,
         ordering = 20460,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 120,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 7,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 7,
               ["elona.stat_speed"] = 85,
               ["elona.martial_arts"] = 2,
               ["elona.weight_lifting"] = 3,
               ["elona.performer"] = 2,
               ["elona.detection"] = 3,
            },

            breed_power = 920,
            image = Resolver.make("elona.by_gender", { male = 254, female = 254 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 80,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.leg",
               "elona.leg"
            },

         },

      },
      {
         _id = "roran",
         is_extra = true,
         ordering = 20470,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 4,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 7,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 10,
               ["elona.stat_speed"] = 95,
               ["elona.martial_arts"] = 2,
               ["elona.meditation"] = 3,
               ["elona.literacy"] = 4,
               ["elona.investing"] = 2,
            },

            breed_power = 220,
            image = Resolver.make("elona.by_gender", { male = 4, female = 4 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 150,
            gender = Resolver.make("elona.gender", { male_ratio = 0 }),
            dv_correction = 150,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "rat",
         is_extra = true,
         ordering = 20480,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 4,
               ["elona.stat_dexterity"] = 8,
               ["elona.stat_perception"] = 10,
               ["elona.stat_learning"] = 3,
               ["elona.stat_will"] = 3,
               ["elona.stat_magic"] = 2,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 75,
               ["elona.martial_arts"] = 1,
               ["elona.stealth"] = 3,
               ["elona.anatomy"] = 2,
            },

            breed_power = 1100,
            image = Resolver.make("elona.by_gender", { male = 255, female = 255 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 30,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.back",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "shell",
         is_extra = true,
         ordering = 20490,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 4,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 3,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 20,
               ["elona.martial_arts"] = 1,
               ["elona.meditation"] = 3,
               ["elona.sense_quality"] = 3,
            },

            breed_power = 450,
            image = Resolver.make("elona.by_gender", { male = 256, female = 256 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 120,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 340,
            body_parts = {
               "elona.leg"
            },

         },

      },
      {
         _id = "catgod",
         is_extra = true,
         ordering = 20500,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 120,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 12,
               ["elona.stat_constitution"] = 13,
               ["elona.stat_dexterity"] = 21,
               ["elona.stat_perception"] = 28,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 13,
               ["elona.stat_magic"] = 12,
               ["elona.stat_charisma"] = 25,
               ["elona.stat_speed"] = 500,
               ["elona.martial_arts"] = 3,
               ["elona.evasion"] = 3,
               ["elona.greater_evasion"] = 3,
               ["elona.eye_of_mind"] = 2,
            },

            breed_power = 5,
            image = Resolver.make("elona.by_gender", { male = 199, female = 199 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 120,
            gender = Resolver.make("elona.gender", { male_ratio = 0 }),
            dv_correction = 250,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "machinegod",
         is_extra = true,
         ordering = 20510,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 200,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 15,
               ["elona.stat_constitution"] = 14,
               ["elona.stat_dexterity"] = 11,
               ["elona.stat_perception"] = 24,
               ["elona.stat_learning"] = 12,
               ["elona.stat_will"] = 15,
               ["elona.stat_magic"] = 8,
               ["elona.stat_charisma"] = 10,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 5,
               ["elona.firearm"] = 30,
            },

            breed_power = 5,
            image = Resolver.make("elona.by_gender", { male = 349, female = 349 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 3000,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 150,
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "undeadgod",
         is_extra = true,
         ordering = 20520,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 150,
               ["elona.stat_mana"] = 500,
               ["elona.stat_strength"] = 10,
               ["elona.stat_constitution"] = 13,
               ["elona.stat_dexterity"] = 14,
               ["elona.stat_perception"] = 18,
               ["elona.stat_learning"] = 16,
               ["elona.stat_will"] = 18,
               ["elona.stat_magic"] = 28,
               ["elona.stat_charisma"] = 7,
               ["elona.stat_speed"] = 110,
               ["elona.martial_arts"] = 4,
               ["elona.control_magic"] = 3,
               ["elona.magic_capacity"] = 5,
            },

            breed_power = 5,
            image = Resolver.make("elona.by_gender", { male = 350, female = 350 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 1500,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "machine",
         is_extra = true,
         ordering = 20530,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 10,
               ["elona.stat_dexterity"] = 7,
               ["elona.stat_perception"] = 9,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 12,
               ["elona.stat_magic"] = 5,
               ["elona.stat_charisma"] = 6,
               ["elona.stat_speed"] = 65,
               ["elona.martial_arts"] = 2,
               ["elona.meditation"] = 3,
               ["elona.lock_picking"] = 3,
               ["elona.disarm_trap"] = 3,
            },

            breed_power = 15,
            image = Resolver.make("elona.by_gender", { male = 270, female = 270 }),
            special_attack_type = 6,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 240,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "wisp",
         is_extra = true,
         ordering = 20540,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 150,
               ["elona.stat_mana"] = 150,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 10,
               ["elona.stat_dexterity"] = 10,
               ["elona.stat_perception"] = 20,
               ["elona.stat_learning"] = 10,
               ["elona.stat_will"] = 15,
               ["elona.stat_magic"] = 15,
               ["elona.stat_charisma"] = 4,
               ["elona.stat_speed"] = 35,
               ["elona.martial_arts"] = 1,
               ["elona.control_magic"] = 3,
               ["elona.magic_capacity"] = 5,
            },

            breed_power = 25,
            image = Resolver.make("elona.by_gender", { male = 272, female = 272 }),
            melee_attack_type = 4,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 40,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head"
            },

         },

      },
      {
         _id = "chicken",
         is_extra = true,
         ordering = 20550,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 80,
               ["elona.stat_strength"] = 5,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 10,
               ["elona.stat_perception"] = 11,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 5,
               ["elona.stat_charisma"] = 7,
               ["elona.stat_speed"] = 60,
               ["elona.martial_arts"] = 1,
               ["elona.anatomy"] = 3,
               ["elona.meditation"] = 3,
            },

            breed_power = 1000,
            image = Resolver.make("elona.by_gender", { male = 274, female = 274 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 40,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.head"
            },

         },

      },
      {
         _id = "stalker",
         is_extra = true,
         ordering = 20560,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 120,
               ["elona.stat_mana"] = 140,
               ["elona.stat_strength"] = 9,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 11,
               ["elona.stat_learning"] = 7,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 9,
               ["elona.stat_charisma"] = 3,
               ["elona.stat_speed"] = 100,
               ["elona.martial_arts"] = 2,
               ["elona.eye_of_mind"] = 3,
               ["elona.stealth"] = 4,
            },

            breed_power = 25,
            image = Resolver.make("elona.by_gender", { male = 276, female = 276 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 180,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            resistances = {
               ["elona.element_darkness"] = 500,
               ["elona.element_nerve"] = 500,
               ["elona.element_nether"] = 500,
               ["elona.element_fire"] = 80,
            },
            dv_correction = 130,
            body_parts = {
               "elona.neck",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "catsister",
         is_extra = true,
         ordering = 20570,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 30,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 7,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 13,
               ["elona.stat_perception"] = 15,
               ["elona.stat_learning"] = 8,
               ["elona.stat_will"] = 10,
               ["elona.stat_magic"] = 13,
               ["elona.stat_charisma"] = 22,
               ["elona.stat_speed"] = 200,
               ["elona.martial_arts"] = 4,
               ["elona.two_hand"] = 6,
               ["elona.tactics"] = 4,
            },

            breed_power = 5,
            image = Resolver.make("elona.by_gender", { male = 354, female = 354 }),
            melee_attack_type = 1,
            age = Resolver.make("base.between", { min = 10, max = 13 }),
            height = 140,
            gender = Resolver.make("elona.gender", { male_ratio = 0 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "mutant",
         is_extra = false,
         ordering = 10110,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 100,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 9,
               ["elona.stat_constitution"] = 5,
               ["elona.stat_dexterity"] = 5,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 7,
               ["elona.stat_will"] = 9,
               ["elona.stat_magic"] = 7,
               ["elona.stat_charisma"] = 1,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 2,
               ["elona.magic_capacity"] = 3,
               ["elona.healing"] = 4,
            },

            breed_power = 50,
            image = Resolver.make("elona.by_gender", { male = 3, female = 4 }),
            age = Resolver.make("base.between", { min = 25, max = 74 }),
            height = 180,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.body",
               "elona.hand"
            },

         },

      },
      {
         _id = "yeek",
         is_extra = true,
         ordering = 20580,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 80,
               ["elona.stat_mana"] = 90,
               ["elona.stat_strength"] = 4,
               ["elona.stat_constitution"] = 7,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 7,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 6,
               ["elona.stat_speed"] = 90,
               ["elona.martial_arts"] = 1,
               ["elona.meditation"] = 3,
               ["elona.negotiation"] = 4,
            },

            breed_power = 500,
            image = Resolver.make("elona.by_gender", { male = 378, female = 378 }),
            age = Resolver.make("base.between", { min = 15, max = 44 }),
            height = 90,
            gender = Resolver.make("elona.gender", { male_ratio = 50 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "yith",
         is_extra = true,
         ordering = 20590,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 150,
               ["elona.stat_mana"] = 200,
               ["elona.stat_strength"] = 13,
               ["elona.stat_constitution"] = 14,
               ["elona.stat_dexterity"] = 9,
               ["elona.stat_perception"] = 15,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 11,
               ["elona.stat_charisma"] = 11,
               ["elona.stat_speed"] = 70,
               ["elona.martial_arts"] = 3,
               ["elona.control_magic"] = 4,
               ["elona.meditation"] = 3,
               ["elona.faith"] = 4,
            },

            breed_power = 25,
            image = Resolver.make("elona.by_gender", { male = 429, female = 429 }),
            melee_attack_type = 6,
            special_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 950,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.hand",
               "elona.hand",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.ring"
            },

         },

      },
      {
         _id = "servant",
         is_extra = true,
         ordering = 20600,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 90,
               ["elona.stat_mana"] = 150,
               ["elona.stat_strength"] = 6,
               ["elona.stat_constitution"] = 6,
               ["elona.stat_dexterity"] = 6,
               ["elona.stat_perception"] = 6,
               ["elona.stat_learning"] = 6,
               ["elona.stat_will"] = 6,
               ["elona.stat_magic"] = 6,
               ["elona.stat_charisma"] = 6,
               ["elona.stat_speed"] = 100,
               ["elona.martial_arts"] = 3,
               ["elona.tactics"] = 3,
               ["elona.casting"] = 4,
               ["elona.negotiation"] = 3,
               ["elona.throwing"] = 3,
               ["elona.dual_wield"] = 4,
               ["elona.firearm"] = 4,
               ["elona.two_hand"] = 3,
            },

            breed_power = 5,
            image = Resolver.make("elona.by_gender", { male = 1, female = 2 }),
            age = Resolver.make("base.between", { min = 100, max = 299 }),
            height = 165,
            gender = Resolver.make("elona.gender", { male_ratio = 52 }),
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },

         },

      },
      {
         _id = "horse",
         is_extra = true,
         ordering = 20610,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 150,
               ["elona.stat_mana"] = 50,
               ["elona.stat_strength"] = 9,
               ["elona.stat_constitution"] = 8,
               ["elona.stat_dexterity"] = 4,
               ["elona.stat_perception"] = 5,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 3,
               ["elona.stat_charisma"] = 6,
               ["elona.stat_speed"] = 125,
               ["elona.martial_arts"] = 1,
               ["elona.healing"] = 4,
            },

            breed_power = 1000,
            image = Resolver.make("elona.by_gender", { male = 262, female = 262 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 250,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            body_parts = {
               "elona.body",
               "elona.leg",
               "elona.leg"
            },

         },

      },
      {
         _id = "god",
         is_extra = true,
         ordering = 20620,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 200,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 17,
               ["elona.stat_constitution"] = 13,
               ["elona.stat_dexterity"] = 19,
               ["elona.stat_perception"] = 17,
               ["elona.stat_learning"] = 16,
               ["elona.stat_will"] = 25,
               ["elona.stat_magic"] = 24,
               ["elona.stat_charisma"] = 21,
               ["elona.stat_speed"] = 150,
               ["elona.martial_arts"] = 6,
               ["elona.evasion"] = 3,
               ["elona.greater_evasion"] = 3,
               ["elona.eye_of_mind"] = 2,
               ["elona.firearm"] = 8,
               ["elona.bow"] = 7,
               ["elona.dual_wield"] = 7,
               ["elona.two_hand"] = 5,
               ["elona.tactics"] = 7,
            },

            breed_power = 1,
            image = Resolver.make("elona.by_gender", { male = 393, female = 393 }),
            age = Resolver.make("base.between", { min = 999999, max = 999999 }),
            height = 180,
            gender = Resolver.make("elona.gender", { male_ratio = 0 }),
            dv_correction = 300,
            pv_correction = 200,
            body_parts = {
               "elona.hand",
               "elona.hand"
            },

         },

      },
      {
         _id = "quickling",
         is_extra = true,
         ordering = 20630,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 3,
               ["elona.stat_mana"] = 40,
               ["elona.stat_strength"] = 2,
               ["elona.stat_constitution"] = 4,
               ["elona.stat_dexterity"] = 18,
               ["elona.stat_perception"] = 16,
               ["elona.stat_learning"] = 5,
               ["elona.stat_will"] = 8,
               ["elona.stat_magic"] = 9,
               ["elona.stat_charisma"] = 7,
               ["elona.stat_speed"] = 750,
               ["elona.martial_arts"] = 1,
               ["elona.stealth"] = 3,
               ["elona.evasion"] = 7,
               ["elona.greater_evasion"] = 6,
            },

            breed_power = 1,
            image = Resolver.make("elona.by_gender", { male = 281, female = 281 }),
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 25,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            resistances = {
               ["elona.element_magic"] = 500,
            },
            dv_correction = 550,
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.leg"
            },

         },

      },
      {
         _id = "metal",
         is_extra = true,
         ordering = 20640,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 1,
               ["elona.stat_mana"] = 100,
               ["elona.stat_strength"] = 4,
               ["elona.stat_constitution"] = 1,
               ["elona.stat_dexterity"] = 3,
               ["elona.stat_perception"] = 32,
               ["elona.stat_learning"] = 2,
               ["elona.stat_will"] = 4,
               ["elona.stat_magic"] = 4,
               ["elona.stat_charisma"] = 16,
               ["elona.stat_speed"] = 640,
               ["elona.martial_arts"] = 1,
               ["elona.magic_capacity"] = 4,
               ["elona.greater_evasion"] = 6,
            },

            breed_power = 1,
            image = Resolver.make("elona.by_gender", { male = 252, female = 252 }),
            melee_attack_type = 3,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 12,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            resistances = {
               ["elona.element_magic"] = 500,
            },
            dv_correction = 150,
            pv_correction = 1000,
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back"
            },

         },

      },
      {
         _id = "bike",
         is_extra = true,
         ordering = 20650,

         copy_to_chara = {
            skills = {
               ["elona.stat_life"] = 170,
               ["elona.stat_mana"] = 60,
               ["elona.stat_strength"] = 11,
               ["elona.stat_constitution"] = 13,
               ["elona.stat_dexterity"] = 4,
               ["elona.stat_perception"] = 3,
               ["elona.stat_learning"] = 4,
               ["elona.stat_will"] = 5,
               ["elona.stat_magic"] = 3,
               ["elona.stat_charisma"] = 11,
               ["elona.stat_speed"] = 155,
               ["elona.martial_arts"] = 2,
               ["elona.evasion"] = 11,
               ["elona.lock_picking"] = 3,
               ["elona.disarm_trap"] = 3,
            },

            breed_power = 15,
            image = Resolver.make("elona.by_gender", { male = 471, female = 471 }),
            special_attack_type = 6,
            age = Resolver.make("base.between", { min = 10, max = 19 }),
            height = 240,
            breaks_into_debris = true,
            gender = Resolver.make("elona.gender", { male_ratio = 53 }),
            pv_correction = 150,
            body_parts = {
               "elona.head",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.waist",
               "elona.leg",
               "elona.leg"
            },

         },

      },
      -- For debug
      {
         _id = "slug",
         ordering = 0,

         copy_to_chara = {
            skills = Resolver.make(
               "elona.skills",
               {
                  skills = {
                     ["elona.stat_life"] = 1000,
                     ["elona.stat_mana"] = 1000,
                     ["elona.stat_strength"] = 100,
                     ["elona.stat_constitution"] = 100,
                     ["elona.stat_dexterity"] = 100,
                     ["elona.stat_perception"] = 100,
                     ["elona.stat_learning"] = 100,
                     ["elona.stat_will"] = 100,
                     ["elona.stat_magic"] = 100,
                     ["elona.stat_charisma"] = 100,
                     ["elona.stat_speed"] = 500,
                     ["elona.mining"] = 100,
                  }
               }
            ),

            pv_correction = 1000,
            dv_correction = 1000,
            body_parts = {
               "elona.head",
               "elona.neck",
               "elona.body",
               "elona.back",
               "elona.hand",
               "elona.hand",
               "elona.ring",
               "elona.ring",
               "elona.ring",
               "elona.waist",
               "elona.leg"
            },
         },
      },
   }

data:add_multi("base.race", table.unpack(race))
