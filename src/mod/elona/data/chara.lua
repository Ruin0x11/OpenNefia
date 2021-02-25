local Enum = require("api.Enum")
local Rand = require("api.Rand")
local Resolver = require("api.Resolver")
local Filters = require("mod.elona.api.Filters")
local Gui = require("api.Gui")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")

local eating_effect = require("mod.elona.data.chara.eating_effect")

local chara = {
   {
      _id = "bug",
      _doc = "bug",
      elona_id = 0,
      item_type = 3,
      level = 1,
      relation = Enum.Relation.Enemy,
      race = "elona.slime",
      class = "elona.predator",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
   },
   {
      _id = "user",
      elona_id = 343,
      item_type = 6,
      level = 1,
      relation = Enum.Relation.Neutral,
      race = "elona.god",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_human_male",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 0,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "shopkeeper",
      elona_id = 1,
      item_type = 3,
      tags = { "man" },
      level = 35,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.gunner",
      male_image = "elona.chara_shopkeeper_male",
      female_image = "elona.chara_shopkeeper_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      has_own_name = true,
      ai_actions = {
         calm_action = "elona.calm_dull"
      },
      ai_distance = 6,
      ai_move_chance = 80
   },
   {
      _id = "caravan_master",
      elona_id = 353,
      item_type = 3,
      tags = { "man" },
      level = 22,
      portrait = "random",
      ai_calm = 3,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.gunner",
      image = "elona.chara_caravan_master",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      has_own_name = true,
      ai_actions = {
         calm_action = "elona.calm_stand"
      }
   },
   {
      _id = "bartender",
      elona_id = 70,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.gunner",
      male_image = "elona.chara_bartender_male",
      female_image = "elona.chara_bartender_female",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      has_own_name = true,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "informer",
      elona_id = 69,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      male_image = "elona.chara_informer_male",
      female_image = "elona.chara_informer_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "arena_master",
      elona_id = 73,
      item_type = 3,
      tags = { "man" },
      level = 40,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_arena_master",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "healer",
      elona_id = 74,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "female",
      image = "elona.chara_healer",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      on_eat_corpse = eating_effect.holy_one,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "nun",
      elona_id = 206,
      item_type = 3,
      tags = { "man" },
      level = 50,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.wizard",
      gender = "female",
      image = "elona.chara_nun",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      on_eat_corpse = eating_effect.holy_one,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "elder",
      elona_id = 38,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.gunner",
      male_image = "elona.chara_elder_male",
      female_image = "elona.chara_elder_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "trainer",
      elona_id = 40,
      item_type = 3,
      tags = { "man" },
      level = 40,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      male_image = "elona.chara_trainer_male",
      female_image = "elona.chara_juere_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "guild_trainer",
      elona_id = 333,
      item_type = 3,
      tags = { "man" },
      level = 69,
      portrait = "random",
      ai_calm = 2,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      male_image = "elona.chara_guild_trainer_male",
      female_image = "elona.chara_guild_trainer_female",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_dull"
      }
   },
   {
      _id = "guard_port_kapul",
      elona_id = 76,
      item_type = 3,
      tags = { "man" },
      level = 40,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.archer",
      image = "elona.chara_guard_port_kapul",
      fltselect = Enum.FltSelect.TownSp,
      coefficient = 400,
      on_eat_corpse = eating_effect.guard,
      ai_move_chance = 50
   },
   {
      _id = "guard",
      elona_id = 77,
      item_type = 3,
      tags = { "man" },
      level = 40,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.archer",
      image = "elona.chara_guard",
      fltselect = Enum.FltSelect.TownSp,
      coefficient = 400,
      on_eat_corpse = eating_effect.guard,
      ai_move_chance = 50
   },
   {
      _id = "palmian_elite_soldier",
      elona_id = 204,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.gunner",
      male_image = "elona.chara_palmian_elite_soldier_male",
      female_image = "elona.chara_palmian_elite_soldier_female",
      fltselect = Enum.FltSelect.TownSp,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.wait_melee" },
            { id = "elona.wait_melee" },
            { id = "elona.ranged" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 50
   },
   {
      _id = "zeome",
      elona_id = 2,
      item_type = 3,
      tags = { "man" },
      level = 55,
      portrait = "elona.zeome",
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.elea",
      class = "elona.warmage",
      gender = "male",
      image = "elona.chara_zeome",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 63,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.zeome",
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_cure_of_jure"
         },
         main = {
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_chaos_ball" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_summon_monsters" }
         },
         sub_action_chance = 20
      },
      skills = {
         "elona.spell_cure_of_jure",
         "elona.spell_magic_dart",
         "elona.spell_chaos_ball",
         "elona.spell_summon_monsters"
      }
   },
   {
      _id = "at",
      elona_id = 37,
      item_type = 3,
      tags = { "man" },
      level = 1,
      portrait = "elona.zeome",
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.predator",
      gender = "male",
      image = "elona.chara_at",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      on_eat_corpse = eating_effect.at,
   },
   {
      _id = "orphe",
      elona_id = 23,
      item_type = 3,
      tags = { "man", "god" },
      level = 20,
      portrait = "elona.orphe",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_orphe",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 64,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 1000,
      coefficient = 400,
      dialog = "elona.orphe",
   },
   {
      _id = "mad_scientist",
      elona_id = 26,
      item_type = 3,
      tags = { "man" },
      level = 6,
      portrait = "elona.man7",
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.wizard",
      gender = "male",
      image = "elona.chara_mad_scientist",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.Unique,
      is_unique = true,
      rarity = 1000,
      coefficient = 400,
   },
   {
      _id = "isca",
      elona_id = 27,
      item_type = 3,
      tags = { "man", "god" },
      level = 42,
      portrait = "elona.isca",
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.archer",
      gender = "female",
      image = "elona.chara_isca",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.Unique,
      is_unique = true,
      rarity = 1000,
      coefficient = 400,
   },
   {
      _id = "whom_dwell_in_the_vanity",
      elona_id = 28,
      item_type = 3,
      tags = { "man" },
      level = 78,
      portrait = "elona.bethel",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_whom_dwell_in_the_vanity",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 73,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 1000,
      coefficient = 400,
      dialog = "elona.whom_dwell_in_the_vanity"
   },
   {
      _id = "loyter",
      elona_id = 29,
      item_type = 3,
      tags = { "man" },
      level = 50,
      portrait = "elona.loyter",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_loyter",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 1000,
      coefficient = 400,
      dialog = "elona.loyter",
   },
   {
      _id = "vesda",
      elona_id = 140,
      item_type = 5,
      tags = { "dragon" },
      level = 25,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      class = "elona.predator",
      resistances = {
         ["elona.fire"] = 500,
      },
      image = "elona.chara_vesda",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 1000,
      coefficient = 400,
      on_eat_corpse = eating_effect.vesda,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_fire_breath"
      }
   },
   {
      _id = "miches",
      elona_id = 30,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "elona.miches",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.archer",
      gender = "female",
      image = "elona.chara_miches",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.miches",
   },
   {
      _id = "shena",
      elona_id = 31,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "elona.shena",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.warrior",
      gender = "female",
      image = "elona.chara_shena",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.shena",
   },
   {
      _id = "the_leopard_warrior",
      elona_id = 351,
      item_type = 3,
      tags = { "man" },
      level = 130,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.cat",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_the_leopard_warrior",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqtwohand = 1,
      eqweapon1 = 232,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      flags = { "IsQuickTempered" },
      drops = { "elona.the_leopard_warrior" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_boost" }
         },
         sub_action_chance = 2
      },
      skills = {
         "elona.buff_boost"
      }
   },
   {
      _id = "silvia",
      elona_id = 352,
      item_type = 3,
      tags = { "man" },
      level = 1,
      ai_calm = 5,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.tourist",
      gender = "female",
      image = "elona.chara_silvia",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      drops = { "elona.the_leopard_warrior" },
      ai_actions = {
         calm_action = "elona.calm_special"
      }
   },
   {
      _id = "dungeon_cleaner",
      elona_id = 32,
      item_type = 3,
      level = 20,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_dungeon_cleaner",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
   },
   {
      _id = "larnneire",
      elona_id = 33,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "elona.larnneire",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.elea",
      class = "elona.warmage",
      gender = "female",
      image = "elona.chara_larnneire",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 206,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.larnneire",
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_nerve_arrow" }
         },
         sub_action_chance = 25
      },
      skills = {
         "elona.spell_nerve_arrow"
      }
   },
   {
      _id = "lomias",
      elona_id = 34,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "elona.lomias",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.elea",
      class = "elona.archer",
      gender = "male",
      image = "elona.chara_lomias",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 1,
      eqrange_0 = 207,
      eqammo_0 = 25001,
      eqammo_1 = 3,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      drops = { "elona.lomias" },
      dialog = "elona.lomias",
      eqammo = { 25001, 3 },
      eqrange = 207,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_slow" }
         },
         sub_action_chance = 15
      },
      ai_distance = 3,
      ai_move_chance = 60,
      skills = {
         "elona.buff_slow"
      }
   },
   {
      _id = "slan",
      elona_id = 139,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "elona.karam",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_karam",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.slan",
   },
   {
      _id = "karam",
      elona_id = 146,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "elona.karam",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_karam",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.karam",
   },
   {
      _id = "erystia",
      elona_id = 142,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "elona.erystia",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.wizard",
      gender = "female",
      image = "elona.chara_erystia",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.erystia",
   },
   {
      _id = "issizzle",
      elona_id = 141,
      item_type = 6,
      tags = { "undead", "god" },
      level = 28,
      relation = Enum.Relation.Enemy,
      race = "elona.lich",
      class = "elona.wizard",
      image = "elona.chara_issizzle",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 358,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      on_eat_corpse = eating_effect.insanity,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.buff_mist_of_silence" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt",
         "elona.spell_short_teleport",
         "elona.buff_mist_of_silence"
      }
   },
   {
      _id = "wynan",
      elona_id = 143,
      item_type = 3,
      level = 25,
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.warrior",
      image = "elona.chara_wynan",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 359,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "quruiza",
      elona_id = 144,
      item_type = 6,
      level = 24,
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.wizard",
      resistances = {
         ["elona.fire"] = 500,
      },
      image = "elona.chara_quruiza",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 356,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "corgon",
      elona_id = 145,
      item_type = 5,
      level = 16,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      resistances = {
         ["elona.fire"] = 500,
      },
      image = "elona.chara_corgon",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqring1 = 357,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 60
   },
   {
      _id = "lulwy",
      elona_id = 306,
      item_type = 6,
      tags = { "god" },
      level = 350,
      relation = Enum.Relation.Neutral,
      race = "elona.god",
      class = "elona.archer",
      gender = "female",
      image = "elona.chara_lulwy",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_insult" },
            { id = "elona.skill", skill_id = "elona.action_eye_of_insanity" }
         },
         sub_action_chance = 30
      },
      ai_distance = 2,
      ai_move_chance = 60,
      skills = {
         "elona.action_insult",
         "elona.action_eye_of_insanity"
      }
   },
   {
      _id = "ehekatl",
      elona_id = 331,
      item_type = 6,
      tags = { "god" },
      level = 350,
      relation = Enum.Relation.Neutral,
      race = "elona.god",
      class = "elona.warmage",
      gender = "female",
      image = "elona.chara_ehekatl",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_mewmewmew" }
         },
         sub_action_chance = 15
      },
      ai_distance = 2,
      ai_move_chance = 60,
      skills = {
         "elona.action_mewmewmew"
      }
   },
   {
      _id = "god_inside_ehekatl",
      elona_id = 336,
      item_type = 6,
      tags = { "god" },
      level = 1200,
      relation = Enum.Relation.Enemy,
      race = "elona.god",
      class = "elona.warmage",
      gender = "female",
      image = "elona.chara_ehekatl",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqtwohand = 1,
      eqweapon1 = 739,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_power_breath" },
            { id = "elona.skill", skill_id = "elona.spell_crystal_spear" },
            { id = "elona.skill", skill_id = "elona.action_draw_shadow" },
            { id = "elona.skill", skill_id = "elona.action_drain_blood" }
         },
         sub_action_chance = 25
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_power_breath",
         "elona.spell_crystal_spear",
         "elona.action_draw_shadow",
         "elona.action_drain_blood"
      }
   },
   {
      _id = "opatos",
      elona_id = 338,
      item_type = 6,
      tags = { "god" },
      level = 350,
      relation = Enum.Relation.Neutral,
      race = "elona.god",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_opatos",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqtwohand = 1,
      eqweapon1 = 739,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_mewmewmew" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_mewmewmew"
      }
   },
   {
      _id = "kumiromi",
      elona_id = 339,
      item_type = 6,
      tags = { "god" },
      level = 350,
      relation = Enum.Relation.Neutral,
      race = "elona.god",
      class = "elona.farmer",
      gender = "male",
      image = "elona.chara_kumiromi",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqtwohand = 1,
      eqweapon1 = 739,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_mewmewmew" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_mewmewmew"
      }
   },
   {
      _id = "mani",
      elona_id = 342,
      item_type = 6,
      tags = { "god" },
      level = 350,
      relation = Enum.Relation.Neutral,
      race = "elona.god",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_mani",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqtwohand = 1,
      eqweapon1 = 739,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_mewmewmew" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_mewmewmew"
      }
   },
   {
      _id = "_test",
      elona_id = 340,
      item_type = 6,
      level = 1200,
      relation = Enum.Relation.Enemy,
      race = "elona.god",
      class = "elona.warmage",
      gender = "male",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqtwohand = 1,
      eqweapon1 = 739,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_power_breath" },
            { id = "elona.skill", skill_id = "elona.spell_crystal_spear" },
            { id = "elona.skill", skill_id = "elona.action_draw_shadow" },
            { id = "elona.skill", skill_id = "elona.action_drain_blood" }
         },
         sub_action_chance = 25
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_power_breath",
         "elona.spell_crystal_spear",
         "elona.action_draw_shadow",
         "elona.action_drain_blood"
      }
   },
   {
      _id = "putit",
      elona_id = 3,
      item_type = 1,
      tags = { "slime" },
      level = 1,
      creaturepack = Enum.CharaCategory.Slime,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.slime",
      class = "elona.tourist",
      resistances = {
         -- Element acid is invalid in vanilla, although it is defined.
         -- ["elona.acid"] = 500,
      },
      category = 3,
      rarity = 80000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.putit,
   },
   {
      _id = "red_putit",
      elona_id = 4,
      item_type = 1,
      tags = { "fire", "slime" },
      level = 4,
      creaturepack = Enum.CharaCategory.Slime,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.slime",
      resistances = {
         -- Element acid is invalid in vanilla, although it is defined.
         -- ["elona.acid"] = 500,
      },
      color = { 255, 155, 155 },
      category = 3,
      rarity = 70000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.putit,
   },
   {
      _id = "slime",
      elona_id = 169,
      item_type = 1,
      tags = { "slime" },
      level = 10,
      creaturepack = Enum.CharaCategory.Slime,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.slime",
      class = "elona.predator",
      resistances = {
         -- Element acid is invalid in vanilla, although it is defined.
         -- ["elona.acid"] = 500,
      },
      image = "elona.chara_slime",
      color = { 175, 175, 255 },
      damage_reaction = { id = "elona.acid", power = 100 },
      category = 3,
      rarity = 70000,
      coefficient = 400,
   },
   {
      _id = "acid_slime",
      elona_id = 194,
      item_type = 1,
      tags = { "slime" },
      level = 16,
      creaturepack = Enum.CharaCategory.Slime,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.slime",
      class = "elona.predator",
      resistances = {
         -- Element acid is invalid in vanilla, although it is defined.
         -- ["elona.acid"] = 500,
      },
      image = "elona.chara_slime",
      color = { 175, 255, 175 },
      damage_reaction = { id = "elona.acid", power = 200 },
      category = 3,
      rarity = 70000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_acid_ground" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_acid_ground"
      },
      unarmed_element_id = "elona.acid",
      unarmed_element_power = 100
   },
   {
      _id = "bubble",
      elona_id = 286,
      item_type = 1,
      tags = { "slime" },
      level = 9,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.slime",
      resistances = {
         -- Element acid is invalid in vanilla, although it is defined.
         -- ["elona.acid"] = 500,
      },
      image = "elona.chara_bubble",
      rarity = 25000,
      coefficient = 400,
      flags = { "Splits" },
      splits = true,
   },
   {
      _id = "blue_bubble",
      elona_id = 285,
      item_type = 1,
      tags = { "slime" },
      level = 22,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.slime",
      resistances = {
         -- Element acid is invalid in vanilla, although it is defined.
         -- ["elona.acid"] = 500,
      },
      image = "elona.chara_bubble",
      color = { 225, 225, 255 },
      rarity = 25000,
      coefficient = 400,
      flags = { "Splits" },
      splits = true,
   },
   {
      _id = "mass_monster",
      elona_id = 287,
      item_type = 1,
      level = 20,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.drake",
      image = "elona.chara_mass_monster",
      rarity = 25000,
      coefficient = 400,
      flags = { "Splits" },
      splits = true,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 20,
      skills = {
         "elona.action_touch_of_weakness"
      }
   },
   {
      _id = "cube",
      elona_id = 327,
      item_type = 1,
      level = 52,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.machine",
      image = "elona.chara_cube",
      rarity = 15000,
      coefficient = 400,
      flags = { "Splits2", "IsImmuneToElementalDamage" },
      splits2 = true,
      is_immune_to_elemental_damage = true,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_dimness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 20,
      skills = {
         "elona.action_eye_of_dimness"
      }
   },
   {
      _id = "rabbit",
      elona_id = 5,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      relation = Enum.Relation.Enemy,
      race = "elona.rabbit",
      class = "elona.tourist",
      coefficient = 400,
      drops = { "elona.rabbit" },
   },
   {
      _id = "snail",
      elona_id = 6,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.snail",
      class = "elona.tourist",
      coefficient = 400,
   },
   {
      _id = "fallen_soldier",
      elona_id = 7,
      item_type = 0,
      tags = { "man" },
      level = 3,
      portrait = "random",
      can_talk = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.warrior",
      image = "elona.chara_fallen_soldier",
      coefficient = 400,
   },
   {
      _id = "mercenary",
      elona_id = 8,
      item_type = 0,
      tags = { "man" },
      level = 4,
      portrait = "random",
      can_talk = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.warrior",
      male_image = "elona.chara_mercenary_male",
      female_image = "elona.chara_mercenary_female",
      fltselect = Enum.FltSelect.Town,
      coefficient = 400,
   },
   {
      _id = "beggar",
      elona_id = 9,
      item_type = 0,
      tags = { "man" },
      level = 2,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.tourist",
      male_image = "elona.chara_beggar_male",
      female_image = "elona.chara_beggar_female",
      fltselect = Enum.FltSelect.Town,
      coefficient = 400,
      flags = { "DropsGold" },
   },
   {
      _id = "farmer",
      elona_id = 269,
      item_type = 0,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.tourist",
      male_image = "elona.chara_farmer_male",
      female_image = "elona.chara_farmer_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
   },
   {
      _id = "cleaner",
      elona_id = 320,
      item_type = 0,
      tags = { "man" },
      level = 32,
      portrait = "random",
      ai_calm = 5,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_cleaner",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 10000,
      coefficient = 100,
      ai_actions = {
         calm_action = "elona.calm_special",
         sub = {
            { id = "elona.throw_potion", item_id = "elona.bottle_of_salt" }
         },
         sub_action_chance = 30
      },
      ai_distance = 3,
      ai_move_chance = 50
   },
   {
      _id = "miner",
      elona_id = 273,
      item_type = 0,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.tourist",
      male_image = "elona.chara_miner_male",
      female_image = "elona.chara_miner_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
   },
   {
      _id = "bard",
      elona_id = 326,
      item_type = 0,
      tags = { "man" },
      level = 16,
      portrait = "random",
      ai_calm = 5,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.juere",
      class = "elona.pianist",
      image = "elona.chara_bard",
      fltselect = Enum.FltSelect.Shop,
      rarity = 2000,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_special"
      }
   },
   {
      _id = "sister",
      elona_id = 270,
      item_type = 0,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.tourist",
      male_image = "elona.chara_sister_male",
      female_image = "elona.chara_sister_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
   },
   {
      _id = "holy_beast",
      elona_id = 349,
      item_type = 0,
      tags = { "man", "god" },
      level = 12,
      can_talk = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.tourist",
      image = "elona.chara_holy_beast",
      fltselect = Enum.FltSelect.Sp,
      rarity = 2000,
      coefficient = 400,
      flags = { "IsQuickTempered" },
   },
   {
      _id = "part_time_worker",
      elona_id = 348,
      item_type = 0,
      tags = { "man" },
      level = 35,
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.pianist",
      image = "elona.chara_part_time_worker",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 2000,
      coefficient = 400,
      flags = { "IsQuickTempered" },
      dialog = "elona.part_time_worker",
      ai_actions = {
         calm_action = "elona.calm_stand"
      }
   },
   {
      _id = "fanatic",
      elona_id = 347,
      item_type = 0,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.wizard",
      male_image = "elona.chara_fanatic_male",
      female_image = "elona.chara_fanatic_female",
      fltselect = Enum.FltSelect.Sp,
      rarity = 2000,
      coefficient = 400,
      flags = { "IsQuickTempered" },
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_healing_rain"
         }
      },
      skills = {
         "elona.spell_healing_rain"
      }
   },
   {
      _id = "rogue",
      elona_id = 271,
      item_type = 0,
      tags = { "man" },
      level = 8,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.thief",
      male_image = "elona.chara_rogue_male",
      female_image = "elona.chara_rogue_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_suspicious_hand" }
         },
         sub_action_chance = 50
      },
      skills = {
         "elona.action_suspicious_hand"
      },

      events = {
         {
            id = "elona.on_chara_displaced",
            name = "Steal from passersby",

            callback = function(self, params)
               -- >>>>>>>> shade2/action.hsp:544 			if cId(tc)=271:if rnd(5)=0:if cSleep(tc)=0{ ...
               local displacer = params.chara
               if Rand.one_in(5) and not self:has_effect("elona.sleep") then
                  local gold_stolen = Rand.rnd(math.clamp(displacer.gold, 0, 20) + 1)
                  if displacer:calc("is_protected_from_theft") then
                     gold_stolen = 0
                  end
                  if gold_stolen > 0 then
                     Gui.play_sound("base.getgold1", self.x, self.y)
                     displacer.gold = displacer.gold - gold_stolen
                     self.gold = self.gold + gold_stolen
                     Gui.mes("action.move.displace.dialog", self)
                  end
               end
               -- <<<<<<<< shade2/action.hsp:550 				} ..
            end
         }
      }
   },
   {
      _id = "prostitute",
      elona_id = 335,
      item_type = 0,
      tags = { "man" },
      level = 8,
      portrait = "random",
      ai_calm = 5,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.thief",
      male_image = "elona.chara_prostitute_male",
      female_image = "elona.chara_prostitute_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_special"
      },

      events = {
         {
            id = "elona.calc_dialog_choices",
            name = "Add sex dialog choice",

            callback = function(self, params, result)
               -- >>>>>>>> shade2/chat.hsp:2308 	if cId(tc)=335:if evId()=falseM: chatList 60,lang ...
               if not DeferredEvent.is_pending() then
                  Dialog.add_choice("elona.prostitute:before_confirm", "talk.npc.prostitute.choices.buy", result)
               end
               return result
               -- <<<<<<<< shade2/chat.hsp:2308 	if cId(tc)=335:if evId()=falseM: chatList 60,lang ..
            end
         }
      }
   },
   {
      _id = "prisoner",
      elona_id = 337,
      item_type = 0,
      tags = { "man" },
      level = 3,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.thief",
      male_image = "elona.chara_prisoner_male",
      female_image = "elona.chara_prisoner_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
   },
   {
      _id = "artist",
      elona_id = 272,
      item_type = 0,
      tags = { "man" },
      level = 6,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.wizard",
      male_image = "elona.chara_artist_male",
      female_image = "elona.chara_artist_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
   },
   {
      _id = "noble",
      elona_id = 274,
      item_type = 0,
      tags = { "man" },
      level = 10,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.warrior",
      male_image = "elona.chara_noble_male",
      female_image = "elona.chara_noble_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
   },
   {
      _id = "mage_guild_member",
      elona_id = 289,
      item_type = 3,
      tags = { "man" },
      level = 26,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.eulderna",
      class = "elona.wizard",
      male_image = "elona.chara_mage_guild_member_male",
      female_image = "elona.chara_mage_guild_member_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt"
      }
   },
   {
      _id = "thief_guild_member",
      elona_id = 293,
      item_type = 3,
      tags = { "man" },
      level = 26,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.juere",
      class = "elona.thief",
      male_image = "elona.chara_thief_guild_member_male",
      female_image = "elona.chara_thief_guild_member_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 50
   },
   {
      _id = "fighter_guild_member",
      elona_id = 295,
      item_type = 3,
      tags = { "man" },
      level = 26,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.warrior",
      male_image = "elona.chara_fighter_guild_member_male",
      female_image = "elona.chara_fighter_guild_member_female",
      fltselect = Enum.FltSelect.TownSp,
      rarity = 2000,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 90
   },
   {
      _id = "town_child",
      elona_id = 35,
      item_type = 0,
      tags = { "man" },
      level = 1,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.tourist",
      male_image = "elona.chara_maid_male",
      female_image = "elona.chara_town_child_female",
      fltselect = Enum.FltSelect.Town,
      coefficient = 400,
      can_use_snow = true,
   },
   {
      _id = "old_person",
      elona_id = 36,
      item_type = 0,
      tags = { "man" },
      level = 1,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.tourist",
      male_image = "elona.chara_old_person_male",
      female_image = "elona.chara_old_person_female",
      fltselect = Enum.FltSelect.Town,
      coefficient = 400,
   },
   {
      _id = "punk",
      elona_id = 174,
      item_type = 0,
      tags = { "man", "sf" },
      level = 1,
      portrait = "random",
      can_talk = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.gunner",
      male_image = "elona.chara_punk_male",
      female_image = "elona.chara_punk_female",
      rarity = 60000,
      coefficient = 400,
      ai_distance = 2,
      ai_move_chance = 50
   },
   {
      _id = "wild_sheep",
      elona_id = 10,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      relation = Enum.Relation.Enemy,
      race = "elona.sheep",
      class = "elona.tourist",
      rarity = 30000,
      coefficient = 400,
   },
   {
      _id = "flying_frog",
      elona_id = 11,
      item_type = 1,
      tags = { "wild" },
      level = 2,
      relation = Enum.Relation.Enemy,
      race = "elona.frog",
      class = "elona.tourist",
      coefficient = 400,
      flags = { "IsFloating" },
   },
   {
      _id = "gangster",
      elona_id = 12,
      item_type = 3,
      tags = { "man" },
      level = 3,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.yerles",
      male_image = "elona.chara_gangster_male",
      female_image = "elona.chara_gangster_female",
      coefficient = 400,
   },
   {
      _id = "kobold",
      elona_id = 13,
      item_type = 3,
      level = 3,
      creaturepack = Enum.CharaCategory.Kobolt,
      relation = Enum.Relation.Enemy,
      race = "elona.kobold",
      class = "elona.warrior",
      category = 5,
      coefficient = 400,
      on_eat_corpse = eating_effect.poisonous,
   },
   {
      _id = "yeek",
      elona_id = 236,
      item_type = 3,
      tags = { "yeek" },
      level = 2,
      creaturepack = Enum.CharaCategory.Yeek,
      relation = Enum.Relation.Enemy,
      race = "elona.yeek",
      category = Enum.CharaCategory.Yeek,
      coefficient = 400,
   },
   {
      _id = "yeek_warrior",
      elona_id = 238,
      item_type = 3,
      tags = { "yeek" },
      level = 6,
      creaturepack = Enum.CharaCategory.Yeek,
      relation = Enum.Relation.Enemy,
      race = "elona.yeek",
      color = { 255, 255, 175 },
      category = Enum.CharaCategory.Yeek,
      coefficient = 400,
   },
   {
      _id = "yeek_archer",
      elona_id = 241,
      item_type = 3,
      tags = { "yeek" },
      level = 4,
      creaturepack = Enum.CharaCategory.Yeek,
      relation = Enum.Relation.Enemy,
      race = "elona.yeek",
      class = "elona.archer",
      color = { 175, 255, 175 },
      category = Enum.CharaCategory.Yeek,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.wait_melee" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 30
   },
   {
      _id = "master_yeek",
      elona_id = 240,
      item_type = 3,
      tags = { "yeek" },
      level = 9,
      creaturepack = Enum.CharaCategory.Yeek,
      relation = Enum.Relation.Enemy,
      race = "elona.yeek",
      color = { 185, 155, 215 },
      category = Enum.CharaCategory.Yeek,
      rarity = 50000,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.spell_dark_eye" },
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_summon_yeek" }
         },
         sub_action_chance = 20
      },
      ai_distance = 2,
      ai_move_chance = 70,
      skills = {
         "elona.spell_short_teleport",
         "elona.spell_dark_eye",
         "elona.action_summon_yeek"
      }
   },
   {
      _id = "kamikaze_yeek",
      elona_id = 237,
      item_type = 3,
      tags = { "yeek" },
      level = 6,
      creaturepack = Enum.CharaCategory.Kamikaze,
      relation = Enum.Relation.Enemy,
      race = "elona.yeek",
      color = { 255, 155, 155 },
      category = Enum.CharaCategory.Kamikaze,
      rarity = 150000,
      coefficient = 400,
      is_explodable = true,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.action_suicide_attack" }
         }
      },
      skills = {
         "elona.action_suicide_attack"
      }
   },
   {
      _id = "kamikaze_samurai",
      elona_id = 244,
      item_type = 3,
      level = 18,
      creaturepack = Enum.CharaCategory.Kamikaze,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.warrior",
      image = "elona.chara_kamikaze_samurai",
      category = Enum.CharaCategory.Kamikaze,
      rarity = 25000,
      coefficient = 400,
      is_explodable = true,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.action_suicide_attack" }
         }
      },
      skills = {
         "elona.action_suicide_attack"
      }
   },
   {
      _id = "bomb_rock",
      elona_id = 245,
      item_type = 1,
      level = 25,
      relation = Enum.Relation.Enemy,
      race = "elona.rock",
      class = "elona.predator",
      image = "elona.chara_rock",
      rarity = 20000,
      coefficient = 400,
      is_explodable = true,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.action_suicide_attack" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 10
      },
      ai_distance = 2,
      ai_move_chance = 10,
      skills = {
         "elona.action_suicide_attack",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "hard_gay",
      elona_id = 321,
      item_type = 3,
      level = 10,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.predator",
      gender = "male",
      image = "elona.chara_hard_gay",
      rarity = 15000,
      coefficient = 200,
      is_explodable = true,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.action_suicide_attack" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_suicide_attack"
      }
   },
   {
      _id = "rodlob",
      elona_id = 242,
      item_type = 3,
      tags = { "yeek" },
      level = 14,
      creaturepack = Enum.CharaCategory.Yeek,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.yeek",
      class = "elona.wizard",
      image = "elona.chara_rodlob",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      category = Enum.CharaCategory.Yeek,
      coefficient = 400,
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_cure_of_eris"
         },
         main = {
            { id = "elona.melee" },
            { id = "elona.wait_melee" },
            { id = "elona.skill", skill_id = "elona.action_summon_yeek" },
            { id = "elona.skill", skill_id = "elona.spell_dark_eye" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.action_curse" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.spell_cure_of_eris",
         "elona.action_summon_yeek",
         "elona.spell_dark_eye",
         "elona.spell_short_teleport",
         "elona.action_curse"
      }
   },
   {
      _id = "hot_spring_maniac",
      elona_id = 239,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      male_image = "elona.chara_hot_spring_maniac_male",
      female_image = "elona.chara_hot_spring_maniac_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "centipede",
      elona_id = 14,
      item_type = 2,
      level = 4,
      relation = Enum.Relation.Enemy,
      race = "elona.centipede",
      coefficient = 400,
      on_eat_corpse = eating_effect.poisonous,
   },
   {
      _id = "mushroom",
      elona_id = 15,
      item_type = 2,
      level = 4,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mushroom",
      rarity = 50000,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" },
            { id = "elona.wait_melee" },
            { id = "elona.skill", skill_id = "elona.action_distant_attack_4" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 0,
      skills = {
         "elona.action_distant_attack_4"
      }
   },
   {
      _id = "spore_mushroom",
      elona_id = 283,
      item_type = 2,
      level = 8,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mushroom",
      image = "elona.chara_spore_mushroom",
      rarity = 50000,
      coefficient = 400,
      on_eat_corpse = eating_effect.poisonous,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" },
            { id = "elona.skill", skill_id = "elona.action_distant_attack_7" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 0,
      skills = {
         "elona.action_distant_attack_7"
      },
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 150
   },
   {
      _id = "chaos_mushroom",
      elona_id = 284,
      item_type = 2,
      level = 21,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mushroom",
      image = "elona.chara_spore_mushroom",
      color = { 185, 155, 215 },
      rarity = 50000,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" },
            { id = "elona.skill", skill_id = "elona.action_distant_attack_7" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 0,
      skills = {
         "elona.action_distant_attack_7"
      },
      unarmed_element_id = "elona.chaos",
      unarmed_element_power = 250
   },
   {
      _id = "citizen",
      elona_id = 16,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.warrior",
      male_image = "elona.chara_citizen_male",
      female_image = "elona.chara_citizen_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "citizen2",
      elona_id = 39,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.warrior",
      male_image = "elona.chara_citizen2_male",
      female_image = "elona.chara_citizen2_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "citizen_of_cyber_dome",
      elona_id = 171,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.gunner",
      male_image = "elona.chara_citizen_of_cyber_dome_male",
      female_image = "elona.chara_citizen_of_cyber_dome_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "citizen_of_cyber_dome2",
      elona_id = 172,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.gunner",
      male_image = "elona.chara_citizen_of_cyber_dome2_male",
      female_image = "elona.chara_citizen_of_cyber_dome2_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "sales_person",
      elona_id = 173,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.gunner",
      male_image = "elona.chara_sales_person_male",
      female_image = "elona.chara_sales_person_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "sailor",
      elona_id = 71,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.thief",
      male_image = "elona.chara_sailor_male",
      female_image = "elona.chara_sailor_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "captain",
      elona_id = 72,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "elona.man45",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_captain",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
   },
   {
      _id = "stersha",
      elona_id = 79,
      item_type = 3,
      tags = { "man" },
      level = 25,
      portrait = "elona.stersha",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "female",
      image = "elona.chara_test_subject",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.stersha",
   },
   {
      _id = "xabi",
      elona_id = 80,
      item_type = 3,
      tags = { "man" },
      level = 35,
      portrait = "elona.xabi",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_xabi",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.xabi",
   },
   {
      _id = "orc",
      elona_id = 17,
      item_type = 3,
      level = 5,
      creaturepack = Enum.CharaCategory.Orc,
      relation = Enum.Relation.Enemy,
      race = "elona.orc",
      color = { 225, 225, 255 },
      category = 2,
      coefficient = 400,
   },
   {
      _id = "lizard_man",
      elona_id = 281,
      item_type = 3,
      tags = { "dragon" },
      level = 7,
      relation = Enum.Relation.Enemy,
      race = "elona.lizardman",
      class = "elona.warrior",
      coefficient = 400,
      flags = { "IsQuickTempered" },
   },
   {
      _id = "minotaur",
      elona_id = 282,
      item_type = 3,
      tags = { "mino" },
      level = 18,
      relation = Enum.Relation.Enemy,
      race = "elona.minotaur",
      class = "elona.warrior",
      rarity = 70000,
      coefficient = 400,
   },
   {
      _id = "minotaur_magician",
      elona_id = 296,
      item_type = 3,
      tags = { "mino" },
      level = 22,
      relation = Enum.Relation.Enemy,
      race = "elona.minotaur",
      class = "elona.priest",
      color = { 175, 175, 255 },
      rarity = 70000,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_fire_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_curse" }
         },
         sub_action_chance = 10
      },
      ai_move_chance = 60,
      skills = {
         "elona.spell_fire_bolt",
         "elona.spell_ice_bolt",
         "elona.spell_nether_arrow",
         "elona.action_curse"
      }
   },
   {
      _id = "minotaur_boxer",
      elona_id = 298,
      item_type = 3,
      tags = { "mino" },
      level = 23,
      relation = Enum.Relation.Enemy,
      race = "elona.minotaur",
      class = "elona.predator",
      color = { 255, 155, 155 },
      rarity = 70000,
      coefficient = 400,
      flags = { "IsQuickTempered" },
   },
   {
      _id = "minotaur_king",
      elona_id = 299,
      item_type = 3,
      tags = { "mino" },
      level = 25,
      relation = Enum.Relation.Enemy,
      race = "elona.minotaur",
      class = "elona.warrior",
      color = { 185, 155, 215 },
      cspecialeq = 1,
      eqtwohand = 1,
      rarity = 40000,
      coefficient = 400,
   },
   {
      _id = "ungaga",
      elona_id = 300,
      item_type = 3,
      tags = { "mino" },
      level = 31,
      relation = Enum.Relation.Enemy,
      race = "elona.minotaur",
      class = "elona.warrior",
      color = { 255, 195, 185 },
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 695,
      eqtwohand = 1,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 40000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_boost" }
         },
         sub_action_chance = 5
      },
      skills = {
         "elona.buff_boost"
      }
   },
   {
      _id = "troll",
      elona_id = 251,
      item_type = 3,
      level = 14,
      creaturepack = Enum.CharaCategory.Orc,
      relation = Enum.Relation.Enemy,
      race = "elona.troll",
      resistances = {
         ["elona.fire"] = 50,
      },
      category = 2,
      coefficient = 400,
      on_eat_corpse = eating_effect.troll,
   },
   {
      _id = "warrior_of_elea",
      elona_id = 18,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      creaturepack = Enum.CharaCategory.Elea,
      relation = Enum.Relation.Enemy,
      race = "elona.elea",
      class = "elona.warrior",
      female_image = "elona.chara_warrior_of_elea_female",
      category = 4,
      coefficient = 400,
   },
   {
      _id = "wizard_of_elea",
      elona_id = 24,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      creaturepack = Enum.CharaCategory.Elea,
      relation = Enum.Relation.Enemy,
      race = "elona.elea",
      class = "elona.wizard",
      male_image = "elona.chara_wizard_of_elea_male",
      female_image = "elona.chara_wizard_of_elea_female",
      category = 4,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_nerve_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 20
      },
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_nerve_arrow",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "asura",
      elona_id = 309,
      item_type = 3,
      tags = { "god" },
      level = 12,
      relation = Enum.Relation.Enemy,
      race = "elona.asura",
      class = "elona.warrior",
      cspecialeq = 1,
      eqmultiweapon = 2,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 90
   },
   {
      _id = "mitra",
      elona_id = 310,
      item_type = 3,
      tags = { "god" },
      level = 26,
      relation = Enum.Relation.Enemy,
      race = "elona.asura",
      class = "elona.warrior",
      color = { 175, 255, 175 },
      cspecialeq = 1,
      eqmultiweapon = 266,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 90
   },
   {
      _id = "varuna",
      elona_id = 311,
      item_type = 3,
      tags = { "god" },
      level = 37,
      relation = Enum.Relation.Enemy,
      race = "elona.asura",
      class = "elona.warrior",
      color = { 255, 155, 155 },
      cspecialeq = 1,
      eqmultiweapon = 224,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 90
   },
   {
      _id = "wizard",
      elona_id = 41,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      ai_calm = 2,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.wizard",
      male_image = "elona.chara_wizard_male",
      female_image = "elona.chara_wizard_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_dull",
         main = {
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_mist_of_silence" },
            { id = "elona.skill", skill_id = "elona.buff_slow" },
            { id = "elona.skill", skill_id = "elona.buff_holy_veil" }
         },
         sub_action_chance = 10
      },
      ai_distance = 2,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_nether_arrow",
         "elona.buff_mist_of_silence",
         "elona.buff_slow",
         "elona.buff_holy_veil"
      }
   },
   {
      _id = "warrior",
      elona_id = 75,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "random",
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      male_image = "elona.chara_warrior_male",
      female_image = "elona.chara_warrior_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,
   },
   {
      _id = "mandrake",
      elona_id = 19,
      item_type = 2,
      level = 5,
      relation = Enum.Relation.Enemy,
      race = "elona.mandrake",
      coefficient = 400,
      on_eat_corpse = eating_effect.mandrake,
   },
   {
      _id = "beetle",
      elona_id = 22,
      item_type = 2,
      level = 5,
      relation = Enum.Relation.Enemy,
      race = "elona.beetle",
      class = "elona.predator",
      coefficient = 400,
      on_eat_corpse = eating_effect.beetle,
   },
   {
      _id = "orc_warrior",
      elona_id = 20,
      item_type = 3,
      level = 10,
      creaturepack = Enum.CharaCategory.Orc,
      relation = Enum.Relation.Enemy,
      race = "elona.orc",
      class = "elona.warrior",
      category = 2,
      coefficient = 400,
   },
   {
      _id = "goda",
      elona_id = 25,
      item_type = 3,
      level = 25,
      creaturepack = Enum.CharaCategory.Orc,
      relation = Enum.Relation.Enemy,
      race = "elona.orc",
      class = "elona.warrior",
      color = { 255, 155, 155 },
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.Unique,
      is_unique = true,
      category = 2,
      coefficient = 400,
      flags = { "IsQuickTempered" },
   },
   {
      _id = "zombie",
      elona_id = 21,
      item_type = 3,
      tags = { "undead" },
      level = 8,
      creaturepack = Enum.CharaCategory.Zombie,
      relation = Enum.Relation.Enemy,
      race = "elona.zombie",
      class = "elona.predator",
      category = Enum.CharaCategory.Zombie,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      drops = { "elona.zombie" },
   },
   {
      _id = "bat",
      elona_id = 42,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      relation = Enum.Relation.Enemy,
      race = "elona.bat",
      coefficient = 400,
      flags = { "IsFloating" },
      ai_distance = 2,
      ai_move_chance = 80
   },
   {
      _id = "vampire_bat",
      elona_id = 43,
      item_type = 1,
      tags = { "wild" },
      level = 10,
      relation = Enum.Relation.Enemy,
      race = "elona.bat",
      class = "elona.predator",
      resistances = {
         ["elona.nether"] = 500,
      },
      color = { 255, 155, 155 },
      rarity = 70000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_drain_blood" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 60,
      skills = {
         "elona.action_drain_blood"
      }
   },
   {
      _id = "dragon_bat",
      elona_id = 44,
      item_type = 1,
      tags = { "wild", "fire", "dragon" },
      level = 30,
      relation = Enum.Relation.Enemy,
      race = "elona.bat",
      class = "elona.predator",
      color = { 175, 175, 255 },
      rarity = 60000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_distance = 2,
      ai_move_chance = 60
   },
   {
      _id = "fire_ent",
      elona_id = 45,
      item_type = 1,
      tags = { "fire" },
      level = 15,
      relation = Enum.Relation.Enemy,
      race = "elona.ent",
      class = "elona.predator",
      resistances = {
         ["elona.cold"] = 50,
         ["elona.fire"] = 500,
      },
      color = { 255, 225, 225 },
      coefficient = 400,
      on_eat_corpse = eating_effect.fire_ent,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.fire",
      unarmed_element_power = 200
   },
   {
      _id = "ice_ent",
      elona_id = 46,
      item_type = 1,
      level = 15,
      relation = Enum.Relation.Enemy,
      race = "elona.ent",
      class = "elona.predator",
      resistances = {
         ["elona.fire"] = 50,
         ["elona.cold"] = 500,
      },
      color = { 225, 225, 255 },
      coefficient = 400,
      on_eat_corpse = eating_effect.ice_ent,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.cold",
      unarmed_element_power = 200
   },
   {
      _id = "lich",
      elona_id = 47,
      item_type = 6,
      tags = { "undead" },
      level = 20,
      relation = Enum.Relation.Enemy,
      race = "elona.lich",
      class = "elona.wizard",
      rarity = 60000,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "master_lich",
      elona_id = 48,
      item_type = 6,
      tags = { "undead" },
      level = 30,
      relation = Enum.Relation.Enemy,
      race = "elona.lich",
      class = "elona.wizard",
      color = { 255, 225, 225 },
      rarity = 50000,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" },
            { id = "elona.skill", skill_id = "elona.buff_element_scar" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt",
         "elona.buff_element_scar",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "demi_lich",
      elona_id = 49,
      item_type = 6,
      tags = { "undead" },
      level = 45,
      relation = Enum.Relation.Enemy,
      race = "elona.lich",
      class = "elona.wizard",
      color = { 225, 225, 255 },
      rarity = 40000,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "executioner",
      elona_id = 307,
      item_type = 6,
      tags = { "undead" },
      level = 18,
      relation = Enum.Relation.Enemy,
      race = "elona.lich",
      class = "elona.warrior",
      image = "elona.chara_executioner",
      cspecialeq = 1,
      eqweapon1 = 735,
      eqtwohand = 1,
      rarity = 10000,
      coefficient = 400,
      flags = { "IsDeathMaster" },
      drops = { "elona.executioner" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_lightning_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_death_word" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_lightning_bolt",
         "elona.spell_short_teleport",
         "elona.buff_death_word"
      }
   },
   {
      _id = "messenger_of_death",
      elona_id = 308,
      item_type = 6,
      tags = { "undead" },
      level = 35,
      relation = Enum.Relation.Enemy,
      race = "elona.lich",
      class = "elona.warrior",
      image = "elona.chara_executioner",
      color = { 175, 175, 255 },
      cspecialeq = 1,
      eqweapon1 = 735,
      rarity = 10000,
      coefficient = 400,
      flags = { "IsDeathMaster" },
      drops = { "elona.executioner" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_lightning_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_death_word" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.spell_lightning_bolt",
         "elona.spell_short_teleport",
         "elona.buff_death_word"
      }
   },
   {
      _id = "hound",
      elona_id = 50,
      item_type = 1,
      tags = { "wild" },
      level = 5,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      color = { 255, 255, 175 },
      cspecialeq = 1,
      eqtwohand = 1,
      rarity = 80000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_distance = 2,
      ai_move_chance = 30
   },
   {
      _id = "fire_hound",
      elona_id = 51,
      item_type = 1,
      tags = { "wild", "fire" },
      level = 10,
      creaturepack = Enum.CharaCategory.HoundFire,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.cold"] = 50,
         ["elona.fire"] = 500,
      },
      color = { 255, 155, 155 },
      category = Enum.CharaCategory.HoundFire,
      rarity = 70000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_fire_breath"
      }
   },
   {
      _id = "ice_hound",
      elona_id = 52,
      item_type = 1,
      tags = { "wild" },
      level = 10,
      creaturepack = Enum.CharaCategory.HoundIce,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.fire"] = 50,
         ["elona.cold"] = 500,
      },
      color = { 255, 255, 255 },
      category = Enum.CharaCategory.HoundIce,
      rarity = 70000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_cold_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_cold_breath"
      }
   },
   {
      _id = "lightning_hound",
      elona_id = 53,
      item_type = 1,
      tags = { "wild" },
      level = 12,
      creaturepack = Enum.CharaCategory.HoundLightning,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.lightning"] = 500,
      },
      color = { 255, 215, 175 },
      category = Enum.CharaCategory.HoundLightning,
      rarity = 70000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_lightning_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_lightning_breath"
      }
   },
   {
      _id = "dark_hound",
      elona_id = 54,
      item_type = 1,
      tags = { "wild" },
      level = 12,
      creaturepack = Enum.CharaCategory.HoundDarkness,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.darkness"] = 500,
      },
      color = { 175, 175, 255 },
      category = Enum.CharaCategory.HoundDarkness,
      rarity = 70000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_chaos_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_chaos_breath"
      }
   },
   {
      _id = "illusion_hound",
      elona_id = 55,
      item_type = 1,
      tags = { "wild" },
      level = 18,
      creaturepack = Enum.CharaCategory.HoundMind,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.mind"] = 500,
      },
      color = { 255, 195, 185 },
      category = Enum.CharaCategory.HoundMind,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_nerve_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_nerve_breath"
      }
   },
   {
      _id = "nerve_hound",
      elona_id = 56,
      item_type = 1,
      tags = { "wild" },
      level = 18,
      creaturepack = Enum.CharaCategory.HoundNerve,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.nerve"] = 500,
      },
      color = { 155, 205, 205 },
      category = Enum.CharaCategory.HoundNerve,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_darkness_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_darkness_breath"
      }
   },
   {
      _id = "poison_hound",
      elona_id = 57,
      item_type = 1,
      tags = { "wild" },
      level = 15,
      creaturepack = Enum.CharaCategory.HoundPoison,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.poison"] = 500,
      },
      color = { 175, 255, 175 },
      category = Enum.CharaCategory.HoundPoison,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_mind_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_mind_breath"
      }
   },
   {
      _id = "sound_hound",
      elona_id = 58,
      item_type = 1,
      tags = { "wild" },
      level = 22,
      creaturepack = Enum.CharaCategory.HoundSound,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.sound"] = 500,
      },
      color = { 235, 215, 155 },
      category = Enum.CharaCategory.HoundSound,
      rarity = 40000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_nether_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_nether_breath"
      }
   },
   {
      _id = "nether_hound",
      elona_id = 59,
      item_type = 1,
      tags = { "wild" },
      level = 25,
      creaturepack = Enum.CharaCategory.HoundNether,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.nether"] = 500,
      },
      color = { 205, 205, 205 },
      category = Enum.CharaCategory.HoundNether,
      rarity = 40000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_sound_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_sound_breath"
      }
   },
   {
      _id = "chaos_hound",
      elona_id = 60,
      item_type = 1,
      tags = { "wild" },
      level = 30,
      creaturepack = Enum.CharaCategory.HoundChaos,
      relation = Enum.Relation.Enemy,
      race = "elona.hound",
      class = "elona.predator",
      resistances = {
         ["elona.chaos"] = 500,
      },
      color = { 225, 195, 255 },
      category = Enum.CharaCategory.HoundChaos,
      rarity = 40000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_poison_breath" }
         },
         sub_action_chance = 12
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_poison_breath"
      }
   },
   {
      _id = "giant_squirrel",
      elona_id = 61,
      item_type = 1,
      tags = { "wild" },
      level = 4,
      relation = Enum.Relation.Enemy,
      race = "elona.rabbit",
      class = "elona.predator",
      image = "elona.chara_giant_squirrel",
      color = { 255, 255, 175 },
      coefficient = 400,
      on_eat_corpse = eating_effect.calm,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "killer_squirrel",
      elona_id = 62,
      item_type = 1,
      tags = { "wild" },
      level = 10,
      relation = Enum.Relation.Enemy,
      race = "elona.rabbit",
      class = "elona.predator",
      image = "elona.chara_giant_squirrel",
      color = { 255, 155, 155 },
      coefficient = 400,
      on_eat_corpse = eating_effect.calm,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "grudge",
      elona_id = 63,
      item_type = 3,
      tags = { "undead" },
      level = 7,
      relation = Enum.Relation.Enemy,
      race = "elona.ghost",
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.grudge,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_slow" },
            { id = "elona.skill", skill_id = "elona.buff_mist_of_frailness" }
         },
         sub_action_chance = 10
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_weakness",
         "elona.buff_slow",
         "elona.buff_mist_of_frailness"
      }
   },
   {
      _id = "hungry_demon",
      elona_id = 64,
      item_type = 3,
      tags = { "undead" },
      level = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.ghost",
      color = { 175, 255, 175 },
      rarity = 70000,
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.grudge,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_hunger" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_hunger"
      }
   },
   {
      _id = "hungry_sea_lion",
      elona_id = 312,
      item_type = 3,
      level = 8,
      relation = Enum.Relation.Enemy,
      race = "elona.ent",
      class = "elona.predator",
      image = "elona.chara_hungry_sea_lion",
      rarity = 40000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         main = {
            { id = "elona.melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_scavenge" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_scavenge"
      }
   },
   {
      _id = "super_hungry_sea_lion",
      elona_id = 313,
      item_type = 3,
      level = 19,
      relation = Enum.Relation.Enemy,
      race = "elona.ent",
      class = "elona.predator",
      image = "elona.chara_hungry_sea_lion",
      color = { 255, 225, 225 },
      rarity = 40000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         main = {
            { id = "elona.melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_scavenge" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_scavenge"
      }
   },
   {
      _id = "electric_cloud",
      elona_id = 65,
      item_type = 1,
      level = 12,
      relation = Enum.Relation.Enemy,
      race = "elona.spirit",
      resistances = {
         ["elona.lightning"] = 500,
      },
      color = { 255, 215, 175 },
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.electric_cloud,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_lightning_bolt" },
            { id = "elona.skill", skill_id = "elona.action_lightning_breath" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.spell_lightning_bolt",
         "elona.action_lightning_breath"
      }
   },
   {
      _id = "chaos_cloud",
      elona_id = 66,
      item_type = 1,
      level = 30,
      relation = Enum.Relation.Enemy,
      race = "elona.spirit",
      resistances = {
         ["elona.chaos"] = 500,
      },
      color = { 225, 195, 255 },
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.chaos_cloud,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_chaos_ball" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.spell_chaos_ball"
      },
      unarmed_element_id = "elona.chaos",
      unarmed_element_power = 300
   },
   {
      _id = "floating_eye",
      elona_id = 67,
      item_type = 1,
      level = 2,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.eye",
      resistances = {
         ["elona.mind"] = 500,
         ["elona.nerve"] = 500,
      },
      rarity = 80000,
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.floating_eye,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 15,
      unarmed_element_id = "elona.nerve",
      unarmed_element_power = 250
   },
   {
      _id = "chaos_eye",
      elona_id = 315,
      item_type = 1,
      level = 14,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.eye",
      class = "elona.predator",
      resistances = {
         ["elona.mind"] = 500,
         ["elona.nerve"] = 500,
      },
      color = { 185, 155, 215 },
      rarity = 60000,
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.chaos_eye,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_mutation" }
         },
         sub_action_chance = 10
      },
      ai_distance = 1,
      ai_move_chance = 15,
      skills = {
         "elona.action_eye_of_mutation"
      },
      unarmed_element_id = "elona.chaos",
      unarmed_element_power = 400
   },
   {
      _id = "mad_gaze",
      elona_id = 316,
      item_type = 1,
      level = 7,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.eye",
      resistances = {
         ["elona.mind"] = 500,
         ["elona.nerve"] = 500,
      },
      image = "elona.chara_mad_gaze",
      color = { 175, 175, 255 },
      rarity = 60000,
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.mad_gaze,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_insanity" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 15,
      skills = {
         "elona.action_eye_of_insanity"
      },
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 300
   },
   {
      _id = "death_gaze",
      elona_id = 314,
      item_type = 1,
      level = 29,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.eye",
      class = "elona.predator",
      resistances = {
         ["elona.mind"] = 500,
         ["elona.nerve"] = 500,
      },
      image = "elona.chara_mad_gaze",
      color = { 255, 155, 155 },
      rarity = 60000,
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.floating_eye,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_mana" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 15,
      skills = {
         "elona.action_eye_of_mana"
      },
      unarmed_element_id = "elona.nerve",
      unarmed_element_power = 450
   },
   {
      _id = "wyvern",
      elona_id = 68,
      item_type = 4,
      tags = { "dragon" },
      level = 20,
      relation = Enum.Relation.Enemy,
      race = "elona.wyvern",
      class = "elona.predator",
      resistances = {
         ["elona.fire"] = 500,
      },
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_fire_breath"
      }
   },
   {
      _id = "puppet",
      elona_id = 78,
      item_type = 3,
      level = 15,
      relation = Enum.Relation.Enemy,
      race = "elona.eulderna",
      class = "elona.predator",
      image = "elona.chara_puppet",
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_mist_of_frailness" },
            { id = "elona.skill", skill_id = "elona.buff_slow" },
            { id = "elona.skill", skill_id = "elona.buff_element_scar" }
         },
         sub_action_chance = 20
      },
      ai_distance = 3,
      ai_move_chance = 40,
      skills = {
         "elona.buff_mist_of_frailness",
         "elona.buff_slow",
         "elona.buff_element_scar"
      }
   },
   {
      _id = "wasp",
      elona_id = 81,
      item_type = 2,
      level = 5,
      relation = Enum.Relation.Enemy,
      race = "elona.wasp",
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_poison" }
         },
         sub_action_chance = 30
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_touch_of_poison"
      }
   },
   {
      _id = "red_wasp",
      elona_id = 82,
      item_type = 2,
      tags = { "fire" },
      level = 10,
      relation = Enum.Relation.Enemy,
      race = "elona.wasp",
      color = { 255, 155, 155 },
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_nerve" }
         },
         sub_action_chance = 30
      },
      ai_distance = 2,
      ai_move_chance = 30,
      skills = {
         "elona.action_touch_of_nerve"
      }
   },
   {
      _id = "cyclops",
      elona_id = 83,
      item_type = 3,
      level = 22,
      relation = Enum.Relation.Enemy,
      race = "elona.giant",
      class = "elona.warrior",
      rarity = 60000,
      coefficient = 400,
      flags = { "IsQuickTempered" },
      on_eat_corpse = eating_effect.cyclops,
      ai_distance = 1,
      ai_move_chance = 85
   },
   {
      _id = "titan",
      elona_id = 84,
      item_type = 3,
      level = 40,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.giant",
      class = "elona.warrior",
      color = { 255, 225, 225 },
      rarity = 50000,
      coefficient = 400,
      flags = { "IsQuickTempered" },
      on_eat_corpse = eating_effect.titan,
      ai_distance = 1,
      ai_move_chance = 85
   },
   {
      _id = "imp",
      elona_id = 85,
      item_type = 3,
      tags = { "fire" },
      level = 7,
      relation = Enum.Relation.Enemy,
      race = "elona.imp",
      color = { 255, 225, 225 },
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.imp,
      drops = { "elona.imp" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.buff_element_scar" }
         },
         sub_action_chance = 15
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_short_teleport",
         "elona.buff_element_scar"
      }
   },
   {
      _id = "nether_imp",
      elona_id = 86,
      item_type = 3,
      tags = { "god" },
      level = 16,
      relation = Enum.Relation.Enemy,
      race = "elona.imp",
      color = { 175, 175, 255 },
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.imp,
      drops = { "elona.imp" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 15
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_nether_arrow",
         "elona.spell_magic_dart",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "chaos_imp",
      elona_id = 87,
      item_type = 3,
      level = 27,
      relation = Enum.Relation.Enemy,
      race = "elona.imp",
      color = { 225, 195, 255 },
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.imp,
      drops = { "elona.imp" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_chaos_eye" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 15
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_chaos_eye",
         "elona.spell_magic_dart",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "hand_of_the_dead",
      elona_id = 88,
      item_type = 3,
      tags = { "undead" },
      level = 4,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.hand",
      coefficient = 400,
      on_eat_corpse = eating_effect.hand,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_draw_shadow" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 3,
      ai_move_chance = 25,
      skills = {
         "elona.action_draw_shadow",
         "elona.action_touch_of_weakness"
      },
      unarmed_element_id = "elona.darkness",
      unarmed_element_power = 80
   },
   {
      _id = "hand_of_the_chaos",
      elona_id = 89,
      item_type = 3,
      tags = { "undead" },
      level = 11,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.hand",
      color = { 225, 195, 255 },
      coefficient = 400,
      on_eat_corpse = eating_effect.hand,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_draw_shadow" }
         },
         sub_action_chance = 20
      },
      ai_distance = 3,
      ai_move_chance = 25,
      skills = {
         "elona.action_draw_shadow"
      },
      unarmed_element_id = "elona.chaos",
      unarmed_element_power = 180
   },
   {
      _id = "hand_of_the_murderer",
      elona_id = 90,
      item_type = 3,
      tags = { "undead" },
      level = 15,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.hand",
      class = "elona.warrior",
      color = { 255, 225, 225 },
      cspecialeq = 1,
      eqtwohand = 1,
      coefficient = 400,
      on_eat_corpse = eating_effect.hand,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_draw_shadow" },
            { id = "elona.skill", skill_id = "elona.buff_mist_of_frailness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 3,
      ai_move_chance = 25,
      skills = {
         "elona.action_draw_shadow",
         "elona.buff_mist_of_frailness"
      }
   },
   {
      _id = "ghost",
      elona_id = 91,
      item_type = 3,
      tags = { "undead" },
      level = 5,
      relation = Enum.Relation.Enemy,
      race = "elona.ghost",
      image = "elona.chara_nymph",
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.ghost,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_fear" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_fear",
         "elona.action_touch_of_weakness"
      },
      unarmed_element_id = "elona.nether",
      unarmed_element_power = 80
   },
   {
      _id = "nymph",
      elona_id = 92,
      item_type = 3,
      tags = { "undead" },
      level = 13,
      relation = Enum.Relation.Enemy,
      race = "elona.ghost",
      resistances = {
         ["elona.cold"] = 500,
      },
      image = "elona.chara_nymph",
      color = { 255, 215, 175 },
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.nymph,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_sleep" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_sleep" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.action_cold_breath" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.action_touch_of_sleep",
         "elona.action_touch_of_sleep",
         "elona.spell_ice_bolt",
         "elona.action_cold_breath"
      },
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 200
   },
   {
      _id = "man_eater_flower",
      elona_id = 93,
      item_type = 2,
      level = 8,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mandrake",
      image = "elona.chara_chaos_flower",
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 20,
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 200
   },
   {
      _id = "chaos_flower",
      elona_id = 94,
      item_type = 2,
      level = 19,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mandrake",
      image = "elona.chara_chaos_flower",
      color = { 255, 195, 185 },
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 20,
      unarmed_element_id = "elona.chaos",
      unarmed_element_power = 250
   },
   {
      _id = "cobra",
      elona_id = 95,
      item_type = 1,
      tags = { "wild" },
      level = 10,
      relation = Enum.Relation.Enemy,
      race = "elona.snake",
      color = { 225, 225, 255 },
      coefficient = 400,
      on_eat_corpse = eating_effect.cobra,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_poison" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_poison"
      }
   },
   {
      _id = "king_cobra",
      elona_id = 96,
      item_type = 1,
      tags = { "wild" },
      level = 18,
      relation = Enum.Relation.Enemy,
      race = "elona.snake",
      color = { 255, 225, 225 },
      coefficient = 400,
      on_eat_corpse = eating_effect.cobra,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_poison" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_poison"
      }
   },
   {
      _id = "fire_drake",
      elona_id = 97,
      item_type = 4,
      tags = { "fire", "dragon" },
      level = 16,
      relation = Enum.Relation.Enemy,
      race = "elona.drake",
      resistances = {
         ["elona.fire"] = 500,
      },
      color = { 255, 155, 155 },
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_fire_breath"
      }
   },
   {
      _id = "ice_drake",
      elona_id = 98,
      item_type = 4,
      tags = { "dragon" },
      level = 16,
      relation = Enum.Relation.Enemy,
      race = "elona.drake",
      resistances = {
         ["elona.cold"] = 500,
      },
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_cold_breath" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_cold_breath"
      }
   },
   {
      _id = "lesser_mummy",
      elona_id = 99,
      item_type = 3,
      tags = { "undead" },
      level = 7,
      creaturepack = Enum.CharaCategory.Mummy,
      relation = Enum.Relation.Enemy,
      race = "elona.zombie",
      image = "elona.chara_tuwen",
      category = Enum.CharaCategory.Mummy,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      drops = { "elona.mummy" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_fear" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_fear",
         "elona.action_touch_of_weakness"
      }
   },
   {
      _id = "mummy",
      elona_id = 100,
      item_type = 3,
      tags = { "undead" },
      level = 14,
      creaturepack = Enum.CharaCategory.Mummy,
      relation = Enum.Relation.Enemy,
      race = "elona.zombie",
      class = "elona.warrior",
      image = "elona.chara_tuwen",
      color = { 255, 195, 185 },
      category = Enum.CharaCategory.Mummy,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_fear" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_fear",
         "elona.action_touch_of_weakness"
      }
   },
   {
      _id = "greater_mummy",
      elona_id = 101,
      item_type = 3,
      tags = { "undead" },
      level = 22,
      creaturepack = Enum.CharaCategory.Mummy,
      relation = Enum.Relation.Enemy,
      race = "elona.zombie",
      class = "elona.warrior",
      image = "elona.chara_tuwen",
      color = { 255, 215, 175 },
      category = Enum.CharaCategory.Mummy,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_fear" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_fear",
         "elona.action_touch_of_weakness"
      }
   },
   {
      _id = "tuwen",
      elona_id = 257,
      item_type = 3,
      tags = { "undead" },
      level = 28,
      creaturepack = Enum.CharaCategory.Mummy,
      relation = Enum.Relation.Enemy,
      race = "elona.zombie",
      class = "elona.warrior",
      image = "elona.chara_tuwen",
      color = { 185, 155, 215 },
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      category = Enum.CharaCategory.Mummy,
      coefficient = 400,
      flags = { "IsDeathMaster" },
      on_eat_corpse = eating_effect.rotten_one,
      drops = { "elona.tuwen" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_death_word" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.buff_death_word",
         "elona.action_touch_of_weakness"
      }
   },
   {
      _id = "ancient_coffin",
      elona_id = 254,
      item_type = 3,
      tags = { "undead" },
      level = 19,
      creaturepack = Enum.CharaCategory.Mummy,
      relation = Enum.Relation.Enemy,
      race = "elona.zombie",
      image = "elona.chara_ancient_coffin",
      category = Enum.CharaCategory.Mummy,
      rarity = 50000,
      coefficient = 400,
      on_eat_corpse = eating_effect.rotten_one,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_eye_of_dimness" },
            { id = "elona.skill", skill_id = "elona.buff_mist_of_frailness" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_curse" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_eye_of_dimness",
         "elona.buff_mist_of_frailness",
         "elona.action_curse"
      }
   },
   {
      _id = "goblin",
      elona_id = 102,
      item_type = 3,
      level = 2,
      creaturepack = Enum.CharaCategory.Goblin,
      relation = Enum.Relation.Enemy,
      race = "elona.goblin",
      color = { 255, 225, 225 },
      category = 1,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "goblin_warrior",
      elona_id = 103,
      item_type = 3,
      level = 6,
      creaturepack = Enum.CharaCategory.Goblin,
      relation = Enum.Relation.Enemy,
      race = "elona.goblin",
      class = "elona.warrior",
      color = { 255, 215, 175 },
      category = 1,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "goblin_shaman",
      elona_id = 104,
      item_type = 3,
      level = 8,
      creaturepack = Enum.CharaCategory.Goblin,
      relation = Enum.Relation.Enemy,
      race = "elona.goblin",
      class = "elona.warmage",
      color = { 225, 195, 255 },
      category = 1,
      coefficient = 400,
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_heal_light"
         },
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_fire_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_summon_wild" },
            { id = "elona.skill", skill_id = "elona.buff_slow" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 85,
      skills = {
         "elona.spell_heal_light",
         "elona.spell_fire_bolt",
         "elona.spell_summon_wild",
         "elona.buff_slow"
      }
   },
   {
      _id = "goblin_wizard",
      elona_id = 105,
      item_type = 3,
      level = 10,
      creaturepack = Enum.CharaCategory.Goblin,
      relation = Enum.Relation.Enemy,
      race = "elona.goblin",
      class = "elona.wizard",
      color = { 175, 175, 255 },
      category = 1,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart"
      }
   },
   {
      _id = "red_baptist",
      elona_id = 106,
      item_type = 3,
      tags = { "undead", "fire" },
      level = 12,
      relation = Enum.Relation.Enemy,
      race = "elona.ghost",
      class = "elona.wizard",
      resistances = {
         ["elona.fire"] = 500,
      },
      image = "elona.chara_baptist",
      color = { 255, 155, 155 },
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_fire_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 25
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_fire_bolt",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "blue_baptist",
      elona_id = 107,
      item_type = 3,
      tags = { "undead" },
      level = 12,
      relation = Enum.Relation.Enemy,
      race = "elona.ghost",
      class = "elona.wizard",
      resistances = {
         ["elona.cold"] = 500,
      },
      image = "elona.chara_baptist",
      color = { 175, 175, 255 },
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 25
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_ice_bolt",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "brown_bear",
      elona_id = 108,
      item_type = 1,
      tags = { "wild" },
      level = 4,
      creaturepack = Enum.CharaCategory.Bear,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.bear",
      category = Enum.CharaCategory.Bear,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "grizzly",
      elona_id = 109,
      item_type = 1,
      tags = { "wild" },
      level = 10,
      creaturepack = Enum.CharaCategory.Bear,
      relation = Enum.Relation.Enemy,
      race = "elona.bear",
      color = { 255, 155, 155 },
      category = Enum.CharaCategory.Bear,
      coefficient = 400,
      flags = { "IsQuickTempered" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "mammoth",
      elona_id = 344,
      item_type = 1,
      tags = { "wild" },
      level = 28,
      creaturepack = Enum.CharaCategory.Bear,
      relation = Enum.Relation.Enemy,
      race = "elona.bear",
      image = "elona.chara_mammoth",
      category = Enum.CharaCategory.Bear,
      rarity = 50000,
      coefficient = 400,
      on_eat_corpse = eating_effect.mammoth,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "living_armor",
      elona_id = 110,
      item_type = 3,
      tags = { "undead" },
      level = 15,
      relation = Enum.Relation.Enemy,
      race = "elona.armor",
      class = "elona.warrior",
      rarity = 40000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "steel_mass",
      elona_id = 111,
      item_type = 3,
      tags = { "undead" },
      level = 25,
      relation = Enum.Relation.Enemy,
      race = "elona.armor",
      class = "elona.warrior",
      color = { 225, 225, 255 },
      rarity = 30000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "golden_armor",
      elona_id = 112,
      item_type = 3,
      tags = { "undead" },
      level = 35,
      relation = Enum.Relation.Enemy,
      race = "elona.armor",
      class = "elona.warrior",
      color = { 255, 215, 175 },
      rarity = 30000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "death_armor",
      elona_id = 113,
      item_type = 3,
      level = 45,
      relation = Enum.Relation.Enemy,
      race = "elona.armor",
      class = "elona.warrior",
      color = { 255, 225, 225 },
      rarity = 30000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 10
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_weakness"
      }
   },
   {
      _id = "medusa",
      elona_id = 114,
      item_type = 3,
      tags = { "god" },
      level = 22,
      relation = Enum.Relation.Enemy,
      race = "elona.medusa",
      class = "elona.warmage",
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "euryale",
      elona_id = 115,
      item_type = 3,
      tags = { "god" },
      level = 33,
      relation = Enum.Relation.Enemy,
      race = "elona.medusa",
      class = "elona.warmage",
      color = { 255, 215, 175 },
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "stheno",
      elona_id = 116,
      item_type = 3,
      tags = { "god" },
      level = 44,
      relation = Enum.Relation.Enemy,
      race = "elona.medusa",
      class = "elona.warmage",
      color = { 255, 225, 225 },
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "cupid_of_love",
      elona_id = 117,
      item_type = 3,
      tags = { "god" },
      level = 8,
      relation = Enum.Relation.Enemy,
      race = "elona.cupid",
      class = "elona.archer",
      coefficient = 400,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.cupid_of_love,
      drops = { "elona.cupid_of_love" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_mist_of_silence" }
         },
         sub_action_chance = 20
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.buff_mist_of_silence"
      }
   },
   {
      _id = "lesser_phantom",
      elona_id = 118,
      item_type = 3,
      tags = { "undead" },
      level = 9,
      relation = Enum.Relation.Enemy,
      race = "elona.phantom",
      class = "elona.wizard",
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_slow" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.buff_slow"
      }
   },
   {
      _id = "tyrannosaurus",
      elona_id = 248,
      item_type = 1,
      tags = { "dragon" },
      level = 30,
      relation = Enum.Relation.Enemy,
      race = "elona.dinosaur",
      class = "elona.predator",
      rarity = 50000,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "harpy",
      elona_id = 119,
      item_type = 3,
      level = 13,
      relation = Enum.Relation.Enemy,
      race = "elona.harpy",
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "green_dragon",
      elona_id = 120,
      item_type = 5,
      tags = { "dragon" },
      level = 32,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      class = "elona.predator",
      color = { 215, 255, 215 },
      rarity = 30000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_power_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_power_breath"
      }
   },
   {
      _id = "red_dragon",
      elona_id = 121,
      item_type = 5,
      tags = { "fire", "dragon" },
      level = 40,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      class = "elona.predator",
      resistances = {
         ["elona.fire"] = 500,
      },
      color = { 255, 155, 155 },
      rarity = 20000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_fire_breath"
      }
   },
   {
      _id = "white_dragon",
      elona_id = 122,
      item_type = 5,
      tags = { "dragon" },
      level = 40,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      class = "elona.predator",
      resistances = {
         ["elona.cold"] = 500,
      },
      rarity = 20000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_cold_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_cold_breath"
      }
   },
   {
      _id = "elec_dragon",
      elona_id = 123,
      item_type = 5,
      tags = { "dragon" },
      level = 40,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      class = "elona.predator",
      resistances = {
         ["elona.lightning"] = 500,
      },
      color = { 255, 215, 175 },
      rarity = 20000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_lightning_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_lightning_breath"
      }
   },
   {
      _id = "nether_dragon",
      elona_id = 124,
      item_type = 5,
      tags = { "undead", "dragon" },
      level = 45,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      class = "elona.predator",
      resistances = {
         ["elona.nether"] = 500,
      },
      color = { 175, 175, 255 },
      rarity = 10000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_sound_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_sound_breath"
      }
   },
   {
      _id = "chaos_dragon",
      elona_id = 125,
      item_type = 5,
      tags = { "dragon" },
      level = 50,
      relation = Enum.Relation.Enemy,
      race = "elona.dragon",
      class = "elona.predator",
      resistances = {
         ["elona.chaos"] = 500,
      },
      color = { 225, 195, 255 },
      rarity = 10000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_poison_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_poison_breath"
      }
   },
   {
      _id = "cerberus",
      elona_id = 126,
      item_type = 4,
      tags = { "fire" },
      level = 23,
      relation = Enum.Relation.Enemy,
      race = "elona.cerberus",
      class = "elona.predator",
      resistances = {
         ["elona.fire"] = 500,
      },
      rarity = 40000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_fire_breath"
      }
   },
   {
      _id = "scorpion",
      elona_id = 255,
      item_type = 2,
      tags = { "wild" },
      level = 4,
      relation = Enum.Relation.Enemy,
      race = "elona.centipede",
      resistances = {
         ["elona.poison"] = 500,
      },
      image = "elona.chara_scorpion",
      coefficient = 400,
      on_eat_corpse = eating_effect.cobra,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.poison",
      unarmed_element_power = 150
   },
   {
      _id = "king_scorpion",
      elona_id = 256,
      item_type = 2,
      tags = { "wild" },
      level = 24,
      relation = Enum.Relation.Enemy,
      race = "elona.centipede",
      resistances = {
         ["elona.poison"] = 500,
      },
      image = "elona.chara_scorpion",
      color = { 255, 155, 155 },
      coefficient = 400,
      on_eat_corpse = eating_effect.cobra,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.poison",
      unarmed_element_power = 350
   },
   {
      _id = "spider",
      elona_id = 127,
      item_type = 2,
      tags = { "wild" },
      level = 3,
      creaturepack = Enum.CharaCategory.Spider,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.spider",
      resistances = {
         ["elona.poison"] = 500,
      },
      category = Enum.CharaCategory.Spider,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_web" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.spell_web"
      }
   },
   {
      _id = "black_widow",
      elona_id = 128,
      item_type = 2,
      tags = { "wild" },
      level = 11,
      creaturepack = Enum.CharaCategory.Spider,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.spider",
      resistances = {
         ["elona.poison"] = 500,
      },
      color = { 215, 255, 215 },
      category = Enum.CharaCategory.Spider,
      coefficient = 400,
      on_eat_corpse = eating_effect.cobra,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_web" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.spell_web"
      },
      unarmed_element_id = "elona.poison",
      unarmed_element_power = 150
   },
   {
      _id = "paralyzer",
      elona_id = 129,
      item_type = 2,
      tags = { "wild" },
      level = 21,
      creaturepack = Enum.CharaCategory.Spider,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.spider",
      resistances = {
         ["elona.poison"] = 500,
      },
      color = { 225, 225, 255 },
      category = Enum.CharaCategory.Spider,
      coefficient = 400,
      on_eat_corpse = eating_effect.cobra,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_web" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.spell_web"
      },
      unarmed_element_id = "elona.nerve",
      unarmed_element_power = 150
   },
   {
      _id = "tarantula",
      elona_id = 130,
      item_type = 2,
      tags = { "wild" },
      level = 15,
      creaturepack = Enum.CharaCategory.Spider,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.spider",
      resistances = {
         ["elona.poison"] = 500,
      },
      color = { 255, 215, 175 },
      category = Enum.CharaCategory.Spider,
      coefficient = 400,
      on_eat_corpse = eating_effect.cobra,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_web" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.spell_web"
      },
      unarmed_element_id = "elona.poison",
      unarmed_element_power = 200
   },
   {
      _id = "blood_spider",
      elona_id = 131,
      item_type = 2,
      tags = { "undead" },
      level = 28,
      creaturepack = Enum.CharaCategory.Spider,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.spider",
      resistances = {
         ["elona.poison"] = 500,
      },
      color = { 255, 225, 225 },
      category = Enum.CharaCategory.Spider,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_web" }
         },
         sub_action_chance = 15
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.spell_web"
      },
      unarmed_element_id = "elona.nether",
      unarmed_element_power = 100
   },
   {
      _id = "wooden_golem",
      elona_id = 132,
      item_type = 3,
      level = 13,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.golem",
      color = { 255, 255, 175 },
      rarity = 40000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "stone_golem",
      elona_id = 133,
      item_type = 3,
      tags = { "fire" },
      level = 19,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.golem",
      rarity = 40000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "steel_golem",
      elona_id = 134,
      item_type = 3,
      tags = { "fire" },
      level = 25,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.golem",
      class = "elona.predator",
      color = { 205, 205, 205 },
      rarity = 40000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "golden_golem",
      elona_id = 135,
      item_type = 3,
      level = 30,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.golem",
      class = "elona.predator",
      color = { 255, 215, 175 },
      rarity = 30000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "mithril_golem",
      elona_id = 136,
      item_type = 3,
      level = 35,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.golem",
      class = "elona.predator",
      color = { 225, 225, 255 },
      rarity = 20000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "sky_golem",
      elona_id = 137,
      item_type = 3,
      level = 40,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.golem",
      class = "elona.predator",
      color = { 155, 205, 205 },
      rarity = 15000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "adamantium_golem",
      elona_id = 138,
      item_type = 3,
      level = 50,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.golem",
      class = "elona.predator",
      color = { 175, 255, 175 },
      rarity = 15000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "fire_crab",
      elona_id = 147,
      item_type = 2,
      tags = { "fire" },
      level = 16,
      relation = Enum.Relation.Enemy,
      race = "elona.crab",
      resistances = {
         ["elona.fire"] = 500,
      },
      coefficient = 400,
      on_eat_corpse = eating_effect.fire_crab,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.fire",
      unarmed_element_power = 150
   },
   {
      _id = "fire_centipede",
      elona_id = 148,
      item_type = 2,
      tags = { "fire" },
      level = 18,
      relation = Enum.Relation.Enemy,
      race = "elona.centipede",
      resistances = {
         ["elona.fire"] = 500,
      },
      image = "elona.chara_fire_centipede",
      coefficient = 400,
      on_eat_corpse = eating_effect.fire_centipede,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.fire",
      unarmed_element_power = 200
   },
   {
      _id = "cultist_of_fire",
      elona_id = 149,
      item_type = 3,
      tags = { "fire" },
      level = 20,
      relation = Enum.Relation.Enemy,
      race = "elona.goblin",
      class = "elona.warmage",
      resistances = {
         ["elona.fire"] = 500,
      },
      image = "elona.chara_cultist_of_fire",
      coefficient = 400,
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_heal_light"
         },
         main = {
            { id = "elona.melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_summon_fire" },
            { id = "elona.skill", skill_id = "elona.buff_element_scar" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 85,
      skills = {
         "elona.spell_heal_light",
         "elona.action_summon_fire",
         "elona.buff_element_scar"
      }
   },
   {
      _id = "skeleton_warrior",
      elona_id = 150,
      item_type = 3,
      tags = { "undead" },
      level = 12,
      creaturepack = Enum.CharaCategory.Zombie,
      relation = Enum.Relation.Enemy,
      race = "elona.skeleton",
      class = "elona.warrior",
      category = Enum.CharaCategory.Zombie,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "skeleton_berserker",
      elona_id = 151,
      item_type = 3,
      tags = { "undead" },
      level = 20,
      creaturepack = Enum.CharaCategory.Zombie,
      relation = Enum.Relation.Enemy,
      race = "elona.skeleton",
      class = "elona.warrior",
      color = { 255, 155, 155 },
      cspecialeq = 1,
      eqtwohand = 1,
      category = Enum.CharaCategory.Zombie,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "missionary_of_darkness",
      elona_id = 152,
      item_type = 3,
      tags = { "man" },
      level = 20,
      creaturepack = Enum.CharaCategory.Zombie,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.eulderna",
      image = "elona.chara_missionary_of_darkness",
      category = Enum.CharaCategory.Zombie,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_touch_of_weakness"
      },
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 150
   },
   {
      _id = "pawn",
      elona_id = 153,
      item_type = 3,
      tags = { "pawn" },
      level = 12,
      relation = Enum.Relation.Enemy,
      race = "elona.piece",
      class = "elona.warrior",
      coefficient = 400,
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "rook",
      elona_id = 154,
      item_type = 3,
      tags = { "pawn" },
      level = 16,
      relation = Enum.Relation.Enemy,
      race = "elona.piece",
      class = "elona.predator",
      image = "elona.chara_rook",
      coefficient = 400,
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "bishop",
      elona_id = 155,
      item_type = 3,
      tags = { "pawn" },
      level = 18,
      relation = Enum.Relation.Enemy,
      race = "elona.piece",
      class = "elona.wizard",
      image = "elona.chara_bishop",
      coefficient = 400,
      on_eat_corpse = eating_effect.iron,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.buff_slow" }
         },
         sub_action_chance = 20
      },
      ai_distance = 2,
      ai_move_chance = 40,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_short_teleport",
         "elona.buff_slow"
      }
   },
   {
      _id = "knight",
      elona_id = 156,
      item_type = 3,
      tags = { "pawn" },
      level = 18,
      relation = Enum.Relation.Enemy,
      race = "elona.piece",
      class = "elona.warrior",
      image = "elona.chara_knight",
      cspecialeq = 1,
      eqtwohand = 1,
      coefficient = 400,
      on_eat_corpse = eating_effect.iron,
      ai_actions = {
         main = {
            { id = "elona.melee" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 30
   },
   {
      _id = "queen",
      elona_id = 157,
      item_type = 3,
      level = 22,
      relation = Enum.Relation.Enemy,
      race = "elona.piece",
      class = "elona.wizard",
      image = "elona.chara_queen",
      coefficient = 400,
      on_eat_corpse = eating_effect.iron,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_nether_arrow",
         "elona.spell_magic_dart",
         "elona.spell_short_teleport"
      }
   },
   {
      _id = "king",
      elona_id = 158,
      item_type = 3,
      level = 22,
      relation = Enum.Relation.Enemy,
      race = "elona.piece",
      class = "elona.warrior",
      image = "elona.chara_king",
      coefficient = 400,
      on_eat_corpse = eating_effect.iron,
      ai_actions = {
         main = {
            { id = "elona.melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_summon_pawn" }
         },
         sub_action_chance = 20
      },
      ai_distance = 3,
      ai_move_chance = 40,
      skills = {
         "elona.action_summon_pawn"
      }
   },
   {
      _id = "mercenary_warrior",
      elona_id = 159,
      item_type = 3,
      tags = { "man", "shopguard" },
      level = 20,
      creaturepack = Enum.CharaCategory.Mercenary,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.warrior",
      image = "elona.chara_mercenary_warrior",
      category = Enum.CharaCategory.Mercenary,
      rarity = 25000,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 80
   },
   {
      _id = "mercenary_archer",
      elona_id = 160,
      item_type = 3,
      tags = { "man", "shopguard" },
      level = 20,
      creaturepack = Enum.CharaCategory.Mercenary,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.archer",
      image = "elona.chara_mercenary_archer",
      category = Enum.CharaCategory.Mercenary,
      rarity = 25000,
      coefficient = 400,
      ai_move_chance = 50
   },
   {
      _id = "mercenary_wizard",
      elona_id = 161,
      item_type = 3,
      tags = { "man", "shopguard" },
      level = 20,
      creaturepack = Enum.CharaCategory.Mercenary,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.norland",
      class = "elona.wizard",
      image = "elona.chara_mercenary_wizard",
      category = Enum.CharaCategory.Mercenary,
      rarity = 25000,
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_magic_dart"
      }
   },
   {
      _id = "rogue_boss",
      elona_id = 302,
      item_type = 3,
      tags = { "man", "rogue" },
      level = 12,
      portrait = "elona.man47",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.warrior",
      image = "elona.chara_rogue_boss",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 25000,
      coefficient = 400,
      drops = { "elona.rogue", "elona.rogue_boss" },
      dialog = "elona.rogue_boss",
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_boost" }
         },
         sub_action_chance = 4
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.buff_boost"
      }
   },
   {
      _id = "rogue_warrior",
      elona_id = 303,
      item_type = 3,
      tags = { "man", "rogue", "rogue_guard" },
      level = 10,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.thief",
      image = "elona.chara_gangster_male",
      cspecialeq = 1,
      eqtwohand = 1,
      rarity = 25000,
      coefficient = 400,
      drops = { "elona.rogue" },
      ai_distance = 1,
      ai_move_chance = 80
   },
   {
      _id = "rogue_archer",
      elona_id = 304,
      item_type = 3,
      tags = { "man", "rogue", "rogue_guard" },
      level = 10,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.gunner",
      image = "elona.chara_rogue_archer",
      rarity = 25000,
      coefficient = 400,
      drops = { "elona.rogue" },
      ai_actions = {
         main = {
            { id = "elona.ranged" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 50
   },
   {
      _id = "rogue_wizard",
      elona_id = 305,
      item_type = 3,
      tags = { "man", "rogue", "rogue_guard" },
      level = 10,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.priest",
      image = "elona.chara_rogue_wizard",
      rarity = 25000,
      coefficient = 400,
      drops = { "elona.rogue" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_fire_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.buff_slow" }
         },
         sub_action_chance = 30
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_fire_bolt",
         "elona.spell_magic_dart",
         "elona.buff_slow"
      }
   },
   {
      _id = "yerles_machine_infantry",
      elona_id = 162,
      item_type = 3,
      tags = { "man" },
      level = 5,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.yerles",
      class = "elona.gunner",
      image = "elona.chara_yerles_machine_infantry",
      coefficient = 400,
      ai_distance = 3,
      ai_move_chance = 40
   },
   {
      _id = "yerles_elite_machine_infantry",
      elona_id = 234,
      item_type = 3,
      tags = { "man" },
      level = 22,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.yerles",
      class = "elona.gunner",
      image = "elona.chara_yerles_machine_infantry",
      color = { 255, 155, 155 },
      coefficient = 400,
      ai_distance = 3,
      ai_move_chance = 40
   },
   {
      _id = "gilbert_the_colonel",
      elona_id = 231,
      item_type = 3,
      tags = { "man" },
      level = 45,
      portrait = "elona.gilbert",
      ai_calm = 2,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_gilbert_the_colonel",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.gilbert",
      ai_actions = {
         calm_action = "elona.calm_dull"
      },
      ai_distance = 3,
      ai_move_chance = 40
   },
   {
      _id = "yerles_self_propelled_gun",
      elona_id = 232,
      item_type = 3,
      level = 17,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.yerles",
      class = "elona.gunner",
      image = "elona.chara_yerles_self_propelled_gun",
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.ranged" }
         }
      },
      ai_distance = 4,
      ai_move_chance = 0
   },
   {
      _id = "juere_infantry",
      elona_id = 233,
      item_type = 3,
      tags = { "man" },
      level = 7,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.warrior",
      image = "elona.chara_juere_swordman",
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 95
   },
   {
      _id = "juere_swordman",
      elona_id = 235,
      item_type = 3,
      tags = { "man" },
      level = 15,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.thief",
      image = "elona.chara_juere_swordman",
      color = { 175, 175, 255 },
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "rock_thrower",
      elona_id = 163,
      item_type = 3,
      tags = { "man" },
      level = 9,
      relation = Enum.Relation.Enemy,
      race = "elona.yerles",
      class = "elona.thief",
      image = "elona.chara_rock_thrower",
      cspecialeq = 1,
      eqrange_0 = 210,
      coefficient = 400,
      eqrange = 210,
      ai_distance = 3,
      ai_move_chance = 25
   },
   {
      _id = "cat",
      elona_id = 164,
      item_type = 1,
      tags = { "wild", "cat" },
      level = 4,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.cat",
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.cat,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "silver_cat",
      elona_id = 246,
      item_type = 1,
      tags = { "wild", "cat" },
      level = 3,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.cat",
      image = "elona.chara_stray_cat",
      rarity = 1000,
      coefficient = 0,
      on_eat_corpse = eating_effect.cat,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "stray_cat",
      elona_id = 332,
      item_type = 1,
      tags = { "wild", "cat" },
      level = 9,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.cat",
      image = "elona.chara_stray_cat",
      color = { 255, 255, 175 },
      rarity = 10000,
      coefficient = 0,
      on_eat_corpse = eating_effect.cat,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "lion",
      elona_id = 229,
      item_type = 1,
      tags = { "wild", "cat" },
      level = 18,
      creaturepack = Enum.CharaCategory.Dog,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.cat",
      class = "elona.predator",
      image = "elona.chara_lion",
      category = Enum.CharaCategory.Dog,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "cacy",
      elona_id = 230,
      item_type = 1,
      tags = { "wild", "cat" },
      level = 25,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.catgod",
      class = "elona.wizard",
      image = "elona.chara_cacy",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_summon_cats" }
         },
         sub_action_chance = 15
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.action_summon_cats"
      }
   },
   {
      _id = "carbuncle",
      elona_id = 228,
      item_type = 1,
      tags = { "wild", "cat" },
      level = 20,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.cat",
      class = "elona.wizard",
      image = "elona.chara_carbuncle",
      coefficient = 400,
      ai_actions = {
         main = {
            { id = "elona.melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_web" },
            { id = "elona.skill", skill_id = "elona.action_eye_of_dimness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.spell_web",
         "elona.action_eye_of_dimness"
      }
   },
   {
      _id = "dog",
      elona_id = 165,
      item_type = 1,
      tags = { "wild" },
      level = 4,
      creaturepack = Enum.CharaCategory.Dog,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.dog",
      category = Enum.CharaCategory.Dog,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "poppy",
      elona_id = 225,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.dog",
      image = "elona.chara_poppy",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      dialog = "elona.poppy",
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "rilian",
      elona_id = 226,
      item_type = 3,
      tags = { "man" },
      level = 4,
      portrait = "elona.woman17",
      ai_calm = 2,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.roran",
      image = "elona.chara_rilian",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.rilian",
      ai_actions = {
         calm_action = "elona.calm_dull"
      },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "tam",
      elona_id = 227,
      item_type = 3,
      tags = { "man" },
      level = 5,
      portrait = "elona.man17",
      ai_calm = 2,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      gender = "male",
      image = "elona.chara_tam",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.tam",
      ai_actions = {
         calm_action = "elona.calm_dull"
      },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "little_girl",
      elona_id = 166,
      item_type = 3,
      tags = { "man" },
      level = 4,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.roran",
      class = "elona.warrior",
      image = "elona.chara_elea_female",
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "rat",
      elona_id = 167,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.rat",
      color = { 255, 255, 175 },
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "hermit_crab",
      elona_id = 168,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      relation = Enum.Relation.Enemy,
      race = "elona.shell",
      class = "elona.predator",
      coefficient = 400,
      on_eat_corpse = eating_effect.calm,
      drops = { "elona.hermit_crab" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "public_performer",
      elona_id = 170,
      item_type = 3,
      tags = { "man" },
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.yerles",
      class = "elona.thief",
      image = "elona.chara_public_performer",
      cspecialeq = 1,
      eqrange_0 = 210,
      coefficient = 400,
      eqrange = 210,
      ai_distance = 2,
      ai_move_chance = 70
   },
   {
      _id = "frisia",
      elona_id = 175,
      item_type = 3,
      tags = { "god" },
      level = 80,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.catgod",
      image = "elona.chara_frisia",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      drops = { "elona.god_boss" },
      ai_distance = 1,
      ai_move_chance = 50
   },
   {
      _id = "younger_sister",
      elona_id = 176,
      item_type = 3,
      tags = { "man" },
      level = 1,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.roran",
      class = "elona.thief",
      image = "elona.chara_maid_female",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
   },
   {
      _id = "younger_sister_of_mansion",
      elona_id = 249,
      item_type = 3,
      tags = { "man" },
      level = 50,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.roran",
      class = "elona.thief",
      image = "elona.chara_maid_female",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_summon_sister" }
         },
         sub_action_chance = 100
      },
      skills = {
         "elona.action_summon_sister"
      }
   },
   {
      _id = "younger_cat_sister",
      elona_id = 210,
      item_type = 3,
      tags = { "man" },
      level = 1,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.catsister",
      class = "elona.thief",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
   },
   {
      _id = "young_lady",
      elona_id = 211,
      item_type = 3,
      tags = { "man" },
      level = 1,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.roran",
      class = "elona.warmage",
      image = "elona.chara_young_lady",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      can_use_snow = true,
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_healing_rain"
         },
         sub = {
            { id = "elona.throw_potion", id_set = Filters.isetthrowpotionmajor },
            { id = "elona.skill", skill_id = "elona.buff_mist_of_frailness" },
            { id = "elona.skill", skill_id = "elona.buff_slow" }
         },
         sub_action_chance = 10
      },
      skills = {
         "elona.spell_healing_rain",
         "elona.buff_mist_of_frailness",
         "elona.buff_slow"
      }
   },
   {
      _id = "utima",
      elona_id = 177,
      item_type = 3,
      tags = { "god" },
      level = 80,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.machinegod",
      class = "elona.gunner",
      image = "elona.chara_machinegod",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 1,
      eqrange_0 = 514,
      eqammo_0 = 25030,
      eqammo_1 = 3,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      drops = { "elona.god_boss" },
      eqammo = { 25030, 3 },
      eqrange = 514,
      ai_actions = {
         main = {
            { id = "elona.ranged" },
            { id = "elona.melee" },
            { id = "elona.melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_boost" }
         },
         sub_action_chance = 4
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.buff_boost"
      }
   },
   {
      _id = "azzrssil",
      elona_id = 178,
      item_type = 6,
      tags = { "undead", "god" },
      level = 80,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.undeadgod",
      class = "elona.wizard",
      gender = "male",
      image = "elona.chara_issizzle",
      color = { 255, 155, 155 },
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      on_eat_corpse = eating_effect.insanity,
      drops = { "elona.god_boss" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_ice_bolt" },
            { id = "elona.skill", skill_id = "elona.spell_darkness_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.buff_mist_of_silence" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_ice_bolt",
         "elona.spell_darkness_bolt",
         "elona.spell_short_teleport",
         "elona.buff_mist_of_silence"
      }
   },
   {
      _id = "pet_arena_master",
      elona_id = 179,
      item_type = 3,
      tags = { "man" },
      level = 35,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      image = "elona.chara_undeadgod",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "garokk",
      elona_id = 208,
      item_type = 3,
      tags = { "man" },
      level = 45,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.dwarf",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_garokk",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.garokk",
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "miral",
      elona_id = 209,
      item_type = 3,
      tags = { "man" },
      level = 45,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.dwarf",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_miral",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.miral",
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "twintail",
      elona_id = 180,
      item_type = 1,
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.cat",
      image = "elona.chara_twintail",
      fltselect = Enum.FltSelect.Friend,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "silver_wolf",
      elona_id = 181,
      item_type = 1,
      tags = { "god" },
      level = 10,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.hound",
      image = "elona.chara_silver_wolf",
      fltselect = Enum.FltSelect.Friend,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "nurse",
      elona_id = 182,
      item_type = 3,
      tags = { "man" },
      level = 8,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.norland",
      class = "elona.wizard",
      image = "elona.chara_nurse",
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.spell_healing_touch" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 50,
      skills = {
         "elona.spell_healing_touch"
      }
   },
   {
      _id = "rich_person",
      elona_id = 183,
      item_type = 3,
      tags = { "man" },
      level = 15,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      male_image = "elona.chara_rich_person_male",
      female_image = "elona.chara_rich_person_female",
      fltselect = Enum.FltSelect.Shop,
      rarity = 20000,
      coefficient = 400,

      calc_initial_gold = function()
         return 5000 + Rand.rnd(11000)
      end
   },
   {
      _id = "noble_child",
      elona_id = 184,
      item_type = 3,
      tags = { "man" },
      level = 9,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      male_image = "elona.chara_noble_child_male",
      female_image = "elona.chara_noble_child_female",
      fltselect = Enum.FltSelect.Shop,
      rarity = 40000,
      coefficient = 400,

      calc_initial_gold = function()
         return 2000 + Rand.rnd(5000)
      end
   },
   {
      _id = "tourist",
      elona_id = 185,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.gunner",
      male_image = "elona.chara_tourist_male",
      female_image = "elona.chara_citizen_of_cyber_dome_female",
      fltselect = Enum.FltSelect.Shop,
      coefficient = 400,

      calc_initial_gold = function()
         return 1000 + Rand.rnd(3000)
      end
   },
   {
      _id = "festival_tourist",
      elona_id = 350,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "random",
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.yerles",
      class = "elona.gunner",
      male_image = "elona.chara_festival_tourist_male",
      female_image = "elona.chara_festival_tourist_female",
      color = { 255, 255, 255 },
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
   },
   {
      _id = "blade",
      elona_id = 186,
      item_type = 3,
      level = 5,
      relation = Enum.Relation.Enemy,
      race = "elona.machine",
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.cut",
      unarmed_element_power = 100
   },
   {
      _id = "blade_alpha",
      elona_id = 187,
      item_type = 3,
      level = 13,
      relation = Enum.Relation.Enemy,
      race = "elona.machine",
      class = "elona.predator",
      color = { 225, 225, 255 },
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.cut",
      unarmed_element_power = 120
   },
   {
      _id = "blade_omega",
      elona_id = 188,
      item_type = 3,
      level = 30,
      relation = Enum.Relation.Enemy,
      race = "elona.machine",
      class = "elona.predator",
      color = { 255, 155, 155 },
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.cut",
      unarmed_element_power = 150
   },
   {
      _id = "kaneda_bike",
      elona_id = 345,
      item_type = 3,
      level = 22,
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.bike",
      class = "elona.predator",
      image = "elona.chara_kaneda_bike",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      flags = { "IsImmuneToFear", "IsSuitableForMount" },
      on_eat_corpse = eating_effect.iron,
      dialog = "elona.kaneda_bike",
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1,
      ai_move_chance = 0
   },
   {
      _id = "cub",
      elona_id = 346,
      item_type = 3,
      level = 8,
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Dislike,
      race = "elona.bike",
      class = "elona.predator",
      image = "elona.chara_bike",
      rarity = 5000,
      coefficient = 400,
      flags = { "IsImmuneToFear", "IsSuitableForMount" },
      on_eat_corpse = eating_effect.iron,
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1,
      ai_move_chance = 0
   },
   {
      _id = "mine_dog",
      elona_id = 341,
      item_type = 3,
      level = 15,
      relation = Enum.Relation.Enemy,
      race = "elona.machine",
      image = "elona.chara_mine_dog",
      rarity = 25000,
      coefficient = 400,
      flags = { "IsImmuneToFear", "CuresMpFrequently" },
      is_immune_to_mines = true,
      on_eat_corpse = eating_effect.iron,
      drops = { "elona.mine_dog" },
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.action_drop_mine" },
            { id = "elona.random_move" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_gravity" }
         },
         sub_action_chance = 15
      },
      ai_distance = 3,
      ai_move_chance = 40,
      skills = {
         "elona.action_drop_mine",
         "elona.spell_gravity"
      }
   },
   {
      _id = "iron_maiden",
      elona_id = 258,
      item_type = 3,
      level = 25,
      relation = Enum.Relation.Enemy,
      race = "elona.machine",
      image = "elona.chara_iron_maiden",
      damage_reaction = { id = "elona.cut", power = 250 },
      rarity = 50000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      ai_distance = 1,
      ai_move_chance = 100,
      unarmed_element_id = "elona.cut",
      unarmed_element_power = 150
   },
   {
      _id = "deformed_eye",
      elona_id = 189,
      item_type = 3,
      tags = { "undead" },
      level = 8,
      relation = Enum.Relation.Enemy,
      race = "elona.eye",
      image = "elona.chara_deformed_eye",
      rarity = 60000,
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.deformed_eye,
      drops = { "elona.deformed_eye" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_mutation" }
         },
         sub_action_chance = 10
      },
      ai_distance = 2,
      ai_move_chance = 80,
      skills = {
         "elona.action_eye_of_mutation"
      }
   },
   {
      _id = "impure_eye",
      elona_id = 190,
      item_type = 3,
      tags = { "undead" },
      level = 19,
      relation = Enum.Relation.Enemy,
      race = "elona.eye",
      image = "elona.chara_deformed_eye",
      color = { 255, 155, 155 },
      rarity = 60000,
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.deformed_eye,
      drops = { "elona.deformed_eye" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_mutation" }
         },
         sub_action_chance = 20
      },
      ai_distance = 2,
      ai_move_chance = 80,
      skills = {
         "elona.action_eye_of_mutation"
      }
   },
   {
      _id = "wisp",
      elona_id = 191,
      item_type = 3,
      tags = { "undead", "ether" },
      level = 14,
      relation = Enum.Relation.Enemy,
      race = "elona.wisp",
      resistances = {
         ["elona.lightning"] = 500,
      },
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating", "IsImmuneToFear" },
      on_eat_corpse = eating_effect.ether,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_lightning_bolt" },
            { id = "elona.skill", skill_id = "elona.action_lightning_breath" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_ether" }
         },
         sub_action_chance = 20
      },
      ai_distance = 2,
      ai_move_chance = 80,
      skills = {
         "elona.spell_lightning_bolt",
         "elona.action_lightning_breath",
         "elona.action_eye_of_ether"
      }
   },
   {
      _id = "hedgehog",
      elona_id = 192,
      item_type = 1,
      tags = { "wild" },
      level = 5,
      relation = Enum.Relation.Enemy,
      race = "elona.crab",
      image = "elona.chara_shining_hedgehog",
      damage_reaction = { id = "elona.ether", power = 200 },
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "shining_hedgehog",
      elona_id = 193,
      item_type = 1,
      tags = { "wild", "ether" },
      level = 15,
      relation = Enum.Relation.Enemy,
      race = "elona.crab",
      image = "elona.chara_shining_hedgehog",
      color = { 225, 225, 255 },
      damage_reaction = { id = "elona.ether", power = 500 },
      rarity = 70000,
      coefficient = 400,
      on_eat_corpse = eating_effect.ether,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "chicken",
      elona_id = 195,
      item_type = 1,
      tags = { "wild" },
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.chicken",
      rarity = 30000,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "pumpkin",
      elona_id = 196,
      item_type = 2,
      tags = { "undead" },
      level = 7,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mandrake",
      image = "elona.chara_pumpkin",
      rarity = 60000,
      coefficient = 400,
      on_eat_corpse = eating_effect.pumpkin,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.throw_potion", id_set = Filters.isetthrowpotionminor }
         },
         sub_action_chance = 30
      },
      ai_distance = 2,
      ai_move_chance = 50,
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 100
   },
   {
      _id = "puppy",
      elona_id = 201,
      item_type = 2,
      tags = { "undead" },
      level = 5,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mandrake",
      image = "elona.chara_pumpkin",
      color = { 255, 215, 175 },
      rarity = 20000,
      coefficient = 400,
      is_invisible = true,
      on_eat_corpse = eating_effect.pumpkin,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.throw_potion", id_set = Filters.isetthrowpotionminor }
         },
         sub_action_chance = 10
      },
      ai_distance = 3,
      ai_move_chance = 80,
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 150
   },
   {
      _id = "greater_pumpkin",
      elona_id = 197,
      item_type = 2,
      tags = { "undead" },
      level = 18,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mandrake",
      image = "elona.chara_pumpkin",
      color = { 175, 175, 255 },
      rarity = 60000,
      coefficient = 400,
      is_invisible = true,
      on_eat_corpse = eating_effect.greater_pumpkin,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.throw_potion", id_set = Filters.isetthrowpotionmajor }
         },
         sub_action_chance = 30
      },
      ai_distance = 2,
      ai_move_chance = 50,
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 200
   },
   {
      _id = "halloween_nightmare",
      elona_id = 198,
      item_type = 2,
      tags = { "undead" },
      level = 30,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.mandrake",
      image = "elona.chara_pumpkin",
      color = { 255, 155, 155 },
      rarity = 60000,
      coefficient = 400,
      is_invisible = true,
      on_eat_corpse = eating_effect.halloween_nightmare,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.throw_potion", id_set = Filters.isetthrowpotiongreater }
         },
         sub_action_chance = 30
      },
      ai_distance = 2,
      ai_move_chance = 50,
      unarmed_element_id = "elona.mind",
      unarmed_element_power = 250
   },
   {
      _id = "stalker",
      elona_id = 199,
      item_type = 3,
      tags = { "undead" },
      level = 12,
      relation = Enum.Relation.Enemy,
      race = "elona.stalker",
      class = "elona.predator",
      image = "elona.chara_stalker",
      rarity = 30000,
      coefficient = 400,
      is_invisible = true,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.stalker,
      ai_actions = {
         main = {
            { id = "elona.melee" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 80
   },
   {
      _id = "shadow_stalker",
      elona_id = 200,
      item_type = 3,
      tags = { "undead" },
      level = 26,
      relation = Enum.Relation.Enemy,
      race = "elona.stalker",
      class = "elona.predator",
      image = "elona.chara_stalker",
      color = { 255, 155, 155 },
      rarity = 30000,
      coefficient = 400,
      is_invisible = true,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.stalker,
      ai_actions = {
         main = {
            { id = "elona.melee" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 70
   },
   {
      _id = "ebon",
      elona_id = 202,
      item_type = 3,
      level = 80,
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.giant",
      resistances = {
         ["elona.fire"] = 500,
      },
      gender = "male",
      image = "elona.chara_ebon2",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_stand",
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 65
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_fire_breath"
      }
   },
   {
      _id = "moyer_the_crooked",
      elona_id = 203,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "random",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_moyer_the_crooked",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,
      ai_actions = {
         calm_action = "elona.calm_stand"
      }
   },
   {
      _id = "maid",
      elona_id = 205,
      item_type = 3,
      tags = { "man" },
      level = 1,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.tourist",
      male_image = "elona.chara_maid_male",
      female_image = "elona.chara_maid_female",
      fltselect = Enum.FltSelect.Sp,
      coefficient = 400,

      events = {
         {
            id = "base.on_chara_instantiated",
            name = "Set image",

            callback = function(self)
               -- >>>>>>>> shade2/chara.hsp:513 	if cId(rc)=205{ ..
               -- TODO
               local id = Rand.rnd(33) * 2 + 1
               if self.gender == "female" then
                  id = id + 1
               end
               self.image = data["base.chip"]:iter():filter(function(c) return c.elona_id == id end):extract("_id"):nth(1)
               assert(self.image)
               -- <<<<<<<< shade2/chara.hsp:515 		} ..
            end
         }
      }
   },
   {
      _id = "ebon2",
      elona_id = 207,
      item_type = 3,
      tags = { "god" },
      level = 30,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.giant",
      resistances = {
         ["elona.fire"] = 500,
      },
      gender = "male",
      image = "elona.chara_ebon2",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_fire_breath" }
         },
         sub_action_chance = 65
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_fire_breath"
      }
   },
   -- "Has" the same name as "Stersha" in "EN", but is named "実験台" in "JP".
   {
      _id = "test_subject",
      elona_id = 212,
      item_type = 3,
      level = 1,
      portrait = "elona.stersha",
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.warrior",
      gender = "female",
      image = "elona.chara_test_subject",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqweapon1 = 56,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
   },
   {
      _id = "gwen",
      elona_id = 213,
      item_type = 3,
      tags = { "man" },
      level = 1,
      ai_calm = 4,
      can_talk = true,
      relation = Enum.Relation.Dislike,
      race = "elona.roran",
      class = "elona.warmage",
      gender = "female",
      image = "elona.chara_gwen",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      drops = { "elona.gwen" },
      ai_actions = {
         calm_action = "elona.calm_follow"
      },
      ai_distance = 1
   },
   {
      _id = "pael",
      elona_id = 221,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "elona.woman16",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.roran",
      class = "elona.thief",
      gender = "female",
      image = "elona.chara_pael",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.pael",
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1
   },
   {
      _id = "lily",
      elona_id = 222,
      item_type = 3,
      tags = { "man" },
      level = 15,
      portrait = "elona.woman14",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.roran",
      class = "elona.warrior",
      gender = "female",
      image = "elona.chara_lily",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.lily",
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1
   },
   {
      _id = "raphael",
      elona_id = 223,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "elona.man15",
      ai_calm = 2,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_raphael",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.raphael",
      ai_actions = {
         calm_action = "elona.calm_dull"
      },
      ai_distance = 1
   },
   {
      _id = "ainc",
      elona_id = 224,
      item_type = 3,
      tags = { "man" },
      level = 7,
      portrait = "elona.man19",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_ainc",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.ainc",
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1
   },
   {
      _id = "arnord",
      elona_id = 243,
      item_type = 3,
      tags = { "man" },
      level = 15,
      portrait = "elona.arnord",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_arnord",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.arnord",
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1
   },
   {
      _id = "mia",
      elona_id = 247,
      item_type = 3,
      tags = { "man" },
      level = 4,
      portrait = "elona.mia",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      gender = "female",
      image = "elona.chara_mia",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.mia",
      ai_distance = 1
   },
   {
      _id = "renton",
      elona_id = 252,
      item_type = 3,
      tags = { "man" },
      level = 45,
      portrait = "elona.man6",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.wizard",
      gender = "male",
      image = "elona.chara_renton",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.renton",
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.spell_chaos_eye" },
            { id = "elona.skill", skill_id = "elona.spell_raging_roar" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_mutation" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_chaos_eye",
         "elona.spell_raging_roar",
         "elona.spell_nether_arrow",
         "elona.spell_mutation"
      }
   },
   {
      _id = "marks",
      elona_id = 253,
      item_type = 3,
      tags = { "man" },
      level = 25,
      portrait = "elona.man2",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.thief",
      gender = "male",
      image = "elona.chara_marks",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.marks",
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_suspicious_hand" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.action_suspicious_hand"
      }
   },
   {
      _id = "noel",
      elona_id = 259,
      item_type = 3,
      tags = { "man" },
      level = 20,
      portrait = "elona.woman16",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.thief",
      gender = "female",
      image = "elona.chara_catgod",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.noel",
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_suspicious_hand" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.action_suspicious_hand"
      }
   },
   {
      _id = "conery",
      elona_id = 301,
      item_type = 3,
      tags = { "man" },
      level = 38,
      portrait = "elona.conery",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_conery",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqtwohand = 1,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      flags = { "IsQuickTempered" },
      dialog = "elona.conery",
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "thief",
      elona_id = 214,
      item_type = 3,
      tags = { "man" },
      level = 2,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      image = "elona.chara_master_thief",
      rarity = 30000,
      coefficient = 400,
      flags = { "DropsGold" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_suspicious_hand" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.action_suspicious_hand"
      }
   },
   {
      _id = "robber",
      elona_id = 215,
      item_type = 3,
      tags = { "man" },
      level = 5,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.thief",
      image = "elona.chara_master_thief",
      color = { 255, 155, 155 },
      rarity = 30000,
      coefficient = 400,
      flags = { "DropsGold" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_suspicious_hand" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.action_suspicious_hand"
      }
   },
   {
      _id = "master_thief",
      elona_id = 217,
      item_type = 3,
      tags = { "man" },
      level = 35,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.juere",
      class = "elona.thief",
      image = "elona.chara_master_thief",
      color = { 175, 175, 255 },
      rarity = 30000,
      coefficient = 400,
      flags = { "DropsGold" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_suspicious_hand" }
         },
         sub_action_chance = 25
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.action_suspicious_hand"
      }
   },
   {
      _id = "great_race_of_yith",
      elona_id = 216,
      item_type = 1,
      level = 50,
      relation = Enum.Relation.Enemy,
      race = "elona.yith",
      class = "elona.predator",
      resistances = {
         ["elona.mind"] = 500,
      },
      rarity = 20000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.yith,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_drain_blood" },
            { id = "elona.skill", skill_id = "elona.action_eye_of_insanity" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_drain_blood",
         "elona.action_eye_of_insanity"
      }
   },
   {
      _id = "shub_niggurath",
      elona_id = 218,
      item_type = 1,
      level = 45,
      ai_calm = 3,
      relation = Enum.Relation.Enemy,
      race = "elona.yith",
      class = "elona.predator",
      resistances = {
         ["elona.mind"] = 500,
      },
      image = "elona.chara_shub_niggurath",
      rarity = 40000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.yith,
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.wait_melee" },
            { id = "elona.wait_melee" },
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.action_eye_of_insanity" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_summon_monsters" }
         },
         sub_action_chance = 10
      },
      ai_distance = 3,
      ai_move_chance = 0,
      skills = {
         "elona.spell_short_teleport",
         "elona.action_eye_of_insanity",
         "elona.spell_summon_monsters"
      }
   },
   {
      _id = "gagu",
      elona_id = 219,
      item_type = 3,
      level = 38,
      relation = Enum.Relation.Enemy,
      race = "elona.orc",
      class = "elona.warrior",
      image = "elona.chara_gagu",
      rarity = 80000,
      coefficient = 400,
      on_eat_corpse = eating_effect.yith,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         },
         sub_action_chance = 20
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_touch_of_weakness"
      }
   },
   {
      _id = "spiral_king",
      elona_id = 220,
      item_type = 3,
      tags = { "god" },
      level = 65,
      relation = Enum.Relation.Enemy,
      race = "elona.yith",
      class = "elona.wizard",
      resistances = {
         ["elona.mind"] = 500,
      },
      image = "elona.chara_spiral_king",
      rarity = 30000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.yith,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.spell_chaos_eye" },
            { id = "elona.skill", skill_id = "elona.spell_raging_roar" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_mutation" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_eye_of_insanity" }
         },
         sub_action_chance = 10
      },
      ai_distance = 2,
      ai_move_chance = 50,
      skills = {
         "elona.spell_chaos_eye",
         "elona.spell_raging_roar",
         "elona.spell_nether_arrow",
         "elona.spell_mutation",
         "elona.action_eye_of_insanity"
      }
   },
   {
      _id = "fairy",
      elona_id = 250,
      item_type = 3,
      level = 13,
      relation = Enum.Relation.Enemy,
      race = "elona.fairy",
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating", "DropsGold" },
      drops = { "elona.fairy" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.spell_mind_bolt" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_short_teleport" },
            { id = "elona.skill", skill_id = "elona.action_suspicious_hand" }
         },
         sub_action_chance = 40
      },
      ai_distance = 1,
      ai_move_chance = 60,
      skills = {
         "elona.spell_mind_bolt",
         "elona.spell_short_teleport",
         "elona.action_suspicious_hand"
      }
   },
   {
      _id = "black_cat",
      elona_id = 260,
      item_type = 3,
      tags = { "god" },
      level = 8,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.servant",
      class = "elona.thief",
      image = "elona.chara_black_cat",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         main = {
            { id = "elona.melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.action_drain_blood" },
            { id = "elona.skill", skill_id = "elona.action_eye_of_insanity" }
         },
         sub_action_chance = 30
      },
      ai_distance = 1,
      ai_move_chance = 75,
      skills = {
         "elona.spell_magic_dart",
         "elona.action_drain_blood",
         "elona.action_eye_of_insanity"
      }
   },
   {
      _id = "cute_fairy",
      elona_id = 261,
      item_type = 3,
      tags = { "god" },
      level = 8,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.servant",
      class = "elona.archer",
      image = "elona.chara_cute_fairy",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         main = {
            { id = "elona.ranged" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_mist_of_silence" },
            { id = "elona.skill", skill_id = "elona.buff_slow" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" }
         },
         sub_action_chance = 20
      },
      ai_distance = 2,
      ai_move_chance = 40,
      skills = {
         "elona.buff_mist_of_silence",
         "elona.buff_slow",
         "elona.spell_nether_arrow"
      }
   },
   {
      _id = "android",
      elona_id = 262,
      item_type = 3,
      tags = { "god" },
      level = 8,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.servant",
      class = "elona.gunner",
      image = "elona.chara_android",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_boost" }
         },
         sub_action_chance = 3
      },
      ai_distance = 2,
      ai_move_chance = 40,
      skills = {
         "elona.buff_boost"
      }
   },
   {
      _id = "black_angel",
      elona_id = 263,
      item_type = 3,
      tags = { "god" },
      level = 8,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.servant",
      class = "elona.archer",
      gender = "female",
      image = "elona.chara_black_angel",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating", "IsSuitableForMount" },
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_insult" },
            { id = "elona.ranged" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_speed" },
            { id = "elona.skill", skill_id = "elona.buff_boost" },
            { id = "elona.skill", skill_id = "elona.buff_slow" }
         },
         sub_action_chance = 8
      },
      ai_distance = 1,
      ai_move_chance = 70,
      skills = {
         "elona.action_insult",
         "elona.buff_speed",
         "elona.buff_boost",
         "elona.buff_slow"
      }
   },
   {
      _id = "exile",
      elona_id = 264,
      item_type = 3,
      tags = { "god" },
      level = 8,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.servant",
      class = "elona.wizard",
      image = "elona.chara_exile",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating" },
      can_cast_rapid_magic = true,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_dark_eye" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 65,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_nether_arrow",
         "elona.spell_dark_eye"
      }
   },
   {
      _id = "golden_knight",
      elona_id = 265,
      item_type = 3,
      tags = { "god" },
      level = 8,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.servant",
      class = "elona.warrior",
      gender = "female",
      image = "elona.chara_golden_knight",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating" },
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_heal_critical"
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_insult" },
            { id = "elona.skill", skill_id = "elona.buff_regeneration" }
         },
         sub_action_chance = 8
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.spell_heal_critical",
         "elona.action_insult",
         "elona.buff_regeneration"
      }
   },
   {
      _id = "defender",
      elona_id = 266,
      item_type = 3,
      tags = { "god" },
      level = 8,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.servant",
      class = "elona.warmage",
      gender = "male",
      image = "elona.chara_defender",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsFloating", "HasLayHand" },
      has_lay_hand = true,
      ai_actions = {
         low_health_action = {
            id = "elona.skill", skill_id = "elona.spell_healing_rain"
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.buff_holy_shield" },
            { id = "elona.skill", skill_id = "elona.buff_regeneration" }
         },
         sub_action_chance = 8
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.spell_healing_rain",
         "elona.buff_holy_shield",
         "elona.buff_regeneration"
      }
   },
   {
      _id = "lame_horse",
      elona_id = 267,
      item_type = 1,
      tags = { "wild", "horse" },
      level = 1,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.horse",
      color = { 225, 225, 255 },
      rarity = 10000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.horse,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "wild_horse",
      elona_id = 276,
      item_type = 1,
      tags = { "wild", "horse" },
      level = 4,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.horse",
      class = "elona.predator",
      color = { 255, 255, 175 },
      rarity = 10000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.horse,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "noyel_horse",
      elona_id = 275,
      item_type = 1,
      tags = { "wild", "horse" },
      level = 10,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.horse",
      class = "elona.predator",
      color = { 205, 205, 205 },
      rarity = 10000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.horse,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "yowyn_horse",
      elona_id = 268,
      item_type = 1,
      tags = { "wild", "horse" },
      level = 15,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.horse",
      class = "elona.predator",
      color = { 255, 225, 225 },
      rarity = 10000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.horse,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "wild_horse2",
      elona_id = 277,
      item_type = 1,
      tags = { "wild", "horse" },
      level = 20,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Dislike,
      race = "elona.horse",
      class = "elona.predator",
      color = { 255, 195, 185 },
      rarity = 10000,
      coefficient = 400,
      flags = { "IsSuitableForMount" },
      on_eat_corpse = eating_effect.horse,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "mutant",
      elona_id = 278,
      item_type = 3,
      level = 6,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.mutant",
      class = "elona.warrior",
      image = "elona.chara_mutant",
      rarity = 70000,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 100
   },
   {
      _id = "icolle",
      elona_id = 279,
      item_type = 3,
      tags = { "man" },
      level = 15,
      portrait = "elona.man18",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.yerles",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_icolle",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.icolle",
      ai_distance = 1,
      ai_move_chance = 70
   },
   {
      _id = "balzak",
      elona_id = 280,
      item_type = 3,
      tags = { "man" },
      level = 10,
      portrait = "elona.balzak",
      ai_calm = 5,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      gender = "male",
      image = "elona.chara_balzak",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.balzak",
      ai_actions = {
         calm_action = "elona.calm_special"
      },
      ai_distance = 1,
      ai_move_chance = 70
   },
   {
      _id = "revlus",
      elona_id = 288,
      item_type = 3,
      tags = { "man" },
      level = 55,
      portrait = "elona.man14",
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.wizard",
      gender = "male",
      image = "elona.chara_revlus",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      flags = { "IsFloating" },
      can_cast_rapid_magic = true,
      ai_actions = {
         main = {
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_dark_eye" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 65,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_nether_arrow",
         "elona.spell_dark_eye"
      }
   },
   {
      _id = "lexus",
      elona_id = 290,
      item_type = 3,
      tags = { "man" },
      level = 38,
      portrait = "elona.man6",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.wizard",
      gender = "male",
      image = "elona.chara_doria",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      flags = { "IsFloating" },
      can_cast_rapid_magic = true,
      dialog = "elona.lexus",
      ai_actions = {
         calm_action = "elona.calm_stand",
         main = {
            { id = "elona.skill", skill_id = "elona.spell_magic_dart" },
            { id = "elona.skill", skill_id = "elona.spell_nether_arrow" },
            { id = "elona.skill", skill_id = "elona.spell_dark_eye" }
         }
      },
      ai_distance = 2,
      ai_move_chance = 65,
      skills = {
         "elona.spell_magic_dart",
         "elona.spell_nether_arrow",
         "elona.spell_dark_eye"
      }
   },
   {
      _id = "sin",
      elona_id = 292,
      item_type = 3,
      tags = { "man" },
      level = 55,
      portrait = "elona.man7",
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.thief",
      gender = "male",
      image = "elona.chara_sin",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 65
   },
   {
      _id = "abyss",
      elona_id = 294,
      item_type = 3,
      tags = { "man" },
      level = 38,
      portrait = "elona.man6",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.thief",
      gender = "male",
      image = "elona.chara_doria",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.abyss",
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1,
      ai_move_chance = 65
   },
   {
      _id = "fray",
      elona_id = 291,
      item_type = 3,
      tags = { "man" },
      level = 55,
      portrait = "elona.woman18",
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "female",
      image = "elona.chara_fray",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      ai_distance = 1,
      ai_move_chance = 90
   },
   {
      _id = "doria",
      elona_id = 297,
      item_type = 3,
      tags = { "man" },
      level = 38,
      portrait = "elona.man6",
      ai_calm = 3,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.norland",
      class = "elona.warrior",
      gender = "male",
      image = "elona.chara_doria",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      coefficient = 400,
      dialog = "elona.doria",
      ai_actions = {
         calm_action = "elona.calm_stand"
      },
      ai_distance = 1,
      ai_move_chance = 90
   },
   {
      _id = "silver_eyed_witch",
      elona_id = 317,
      item_type = 3,
      level = 28,
      can_talk = true,
      has_own_name = true,
      relation = Enum.Relation.Enemy,
      race = "elona.roran",
      class = "elona.claymore",
      gender = "female",
      image = "elona.chara_silver_eyed_witch",
      cspecialeq = 1,
      eqweapon1 = 232,
      eqtwohand = 1,
      rarity = 50000,
      coefficient = 400,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_insult" }
         },
         sub_action_chance = 10
      },
      ai_distance = 1,
      ai_move_chance = 80,
      skills = {
         "elona.action_insult"
      }
   },
   {
      _id = "big_daddy",
      elona_id = 318,
      item_type = 3,
      level = 30,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.machinegod",
      class = "elona.gunner",
      gender = "male",
      image = "elona.chara_big_daddy",
      quality = Enum.Quality.Unique,
      cspecialeq = 1,
      eqrange_0 = 496,
      eqrange_1 = 4,
      eqammo_0 = 25020,
      eqammo_1 = 3,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      flags = { "IsImmuneToFear" },
      on_eat_corpse = eating_effect.iron,
      eqammo = { 25020, 3 },
      eqrange = { 496, 4 },
      ai_distance = 3,
      ai_move_chance = 25
   },
   {
      _id = "little_sister",
      elona_id = 319,
      item_type = 3,
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.mutant",
      class = "elona.tourist",
      gender = "female",
      image = "elona.chara_little_sister",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      ai_distance = 5,
      ai_move_chance = 100
   },
   {
      _id = "strange_scientist",
      elona_id = 322,
      item_type = 3,
      tags = { "man" },
      level = 15,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.roran",
      class = "elona.gunner",
      gender = "female",
      image = "elona.chara_strange_scientist",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      dialog = "elona.strange_scientist",
      ai_distance = 3,
      ai_move_chance = 100
   },
   {
      _id = "mysterious_producer",
      elona_id = 334,
      item_type = 3,
      tags = { "man" },
      level = 7,
      can_talk = true,
      relation = Enum.Relation.Neutral,
      race = "elona.juere",
      class = "elona.tourist",
      gender = "male",
      image = "elona.chara_mysterious_producer",
      quality = Enum.Quality.Unique,
      fltselect = Enum.FltSelect.SpUnique,
      rarity = 50000,
      coefficient = 400,
      ai_distance = 3,
      ai_move_chance = 100
   },
   {
      _id = "shade",
      elona_id = 323,
      item_type = 3,
      tags = { "undead" },
      level = 12,
      relation = Enum.Relation.Enemy,
      race = "elona.ghost",
      image = "elona.chara_shade",
      rarity = 10000,
      coefficient = 0,
      flags = { "IsFloating" },
      on_eat_corpse = eating_effect.ghost,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_fear" },
            { id = "elona.skill", skill_id = "elona.action_touch_of_weakness" }
         }
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_touch_of_fear",
         "elona.action_touch_of_weakness"
      },
      unarmed_element_id = "elona.nether",
      unarmed_element_power = 400
   },
   {
      _id = "quickling",
      elona_id = 324,
      item_type = 3,
      level = 10,
      relation = Enum.Relation.Enemy,
      race = "elona.quickling",
      color = { 215, 255, 215 },
      rarity = 15000,
      coefficient = 400,
      flags = { "IsUnsuitableForMount", "IsImmuneToElementalDamage" },
      on_eat_corpse = eating_effect.quickling,
      ai_distance = 2,
      ai_move_chance = 50
   },
   {
      _id = "quickling_archer",
      elona_id = 325,
      item_type = 3,
      level = 17,
      relation = Enum.Relation.Enemy,
      race = "elona.quickling",
      class = "elona.archer",
      color = { 255, 215, 175 },
      rarity = 15000,
      coefficient = 400,
      flags = { "IsUnsuitableForMount", "IsImmuneToElementalDamage" },
      on_eat_corpse = eating_effect.quickling,
      ai_actions = {
         main = {
            { id = "elona.melee" },
            { id = "elona.wait_melee" },
            { id = "elona.wait_melee" }
         },
         sub = {
            { id = "elona.skill", skill_id = "elona.action_insult" }
         },
         sub_action_chance = 2
      },
      ai_distance = 3,
      ai_move_chance = 50,
      skills = {
         "elona.action_insult"
      }
   },
   {
      _id = "silver_bell",
      elona_id = 328,
      item_type = 1,
      level = 3,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.metal",
      rarity = 2000,
      coefficient = 0,
      flags = { "IsUnsuitableForMount", "IsMetal", "IsImmuneToElementalDamage", "IsFloating" },
      on_eat_corpse = eating_effect.iron,
      drops = { "elona.silver_bell" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_vanish" }
         },
         sub_action_chance = 1
      },
      ai_distance = 4,
      ai_move_chance = 30,
      skills = {
         "elona.action_vanish"
      }
   },
   {
      _id = "gold_bell",
      elona_id = 329,
      item_type = 1,
      level = 1,
      can_talk = true,
      relation = Enum.Relation.Enemy,
      race = "elona.metal",
      color = { 255, 215, 175 },
      rarity = 5000,
      coefficient = 0,
      flags = { "IsUnsuitableForMount", "IsMetal", "IsImmuneToElementalDamage", "IsFloating" },
      on_eat_corpse = eating_effect.iron,
      drops = { "elona.gold_bell" },
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_vanish" }
         },
         sub_action_chance = 1
      },
      ai_distance = 3,
      ai_move_chance = 30,
      skills = {
         "elona.action_vanish"
      }
   },
   {
      _id = "alien",
      elona_id = 330,
      item_type = 1,
      tags = { "dragon" },
      level = 19,
      relation = Enum.Relation.Enemy,
      race = "elona.dinosaur",
      class = "elona.predator",
      image = "elona.chara_alien",
      color = { 225, 225, 255 },
      rarity = 40000,
      coefficient = 400,
      on_eat_corpse = eating_effect.alien,
      ai_actions = {
         sub = {
            { id = "elona.skill", skill_id = "elona.action_pregnant" }
         },
         sub_action_chance = 7
      },
      ai_distance = 1,
      ai_move_chance = 100,
      skills = {
         "elona.action_pregnant"
      },
      unarmed_element_id = "elona.acid",
      unarmed_element_power = 250
   },
   -- For debug
   -- chara spiral_putit {
   --     _id = 500,
   --     item_type = 1,
   --     tags = { "slime" },
   --     level = 1,
   --     creaturepack = Enum.CharaCategory.Slime,
   --     relation = Enum.Relation.Enemy,
   --     race = "elona.slime",
   --     class = "elona.wizard",
   --     eesistances = {
   --        ["elona.mind"] = 500,
   --     },
   --     image = 430,
   --     category = 3,
   --     rarity = 0,
   --     coefficient = 0,
   -- },
   --
   -- For debug
   -- chara dragon_putit {
   --     _id = 501,
   --     item_type = 5,
   --     tags = { "dragon" },
   --     level = 1,
   --     relation = Enum.Relation.Enemy,
   --     race = "elona.dragon",
   --     class = "elona.predator",
   --     rarity = 0,
   --     coefficient = 0,
   -- },
}

data:add_multi("base.chara", chara)
