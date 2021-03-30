local God = require("mod.elona.api.God")

local function secret_treasure(id)
   return { id = "elona.secret_treasure", param1 = id, nostack = true }
end

local god = {
   {
      _id = "mani",
      elona_id = 1,
      is_primary_god = true,

      wish_name = "mani",
      summon = "elona.mani",
      servant = "elona.android",
      items = {
         { id = "elona.gemstone_of_mani", _only_once = true }
      },
      artifact = "elona.winchester_premium",
      blessings = {
         God.make_skill_blessing("elona.stat_dexterity", 400, 8),
         God.make_skill_blessing("elona.stat_perception", 300, 14),
         God.make_skill_blessing("elona.healing", 500, 8),
         God.make_skill_blessing("elona.firearm", 250, 18),
         God.make_skill_blessing("elona.detection", 350, 8),
         God.make_skill_blessing("elona.lock_picking", 250, 16),
         God.make_skill_blessing("elona.carpentry", 300, 10),
         God.make_skill_blessing("elona.jeweler", 350, 12),
      },
      offerings = {
         "elona.equip_ranged_gun",
         "elona.equip_ranged_laser_gun",
         "elona.offering_sf"
      }
   },
   {
      _id = "lulwy",
      elona_id = 2,
      is_primary_god = true,

      wish_name = "lulwy",
      summon = "elona.lulwy",
      servant = "elona.black_angel",
      items = {
         { id = "elona.lulwys_gem_stone_of_god_speed", _only_once = true }
      },
      artifact = "elona.wind_bow",
      blessings = {
         God.make_skill_blessing("elona.stat_perception", 450, 10),
         God.make_skill_blessing("elona.stat_speed", 350, 30),
         God.make_skill_blessing("elona.bow", 350, 16),
         God.make_skill_blessing("elona.crossbow", 450, 12),
         God.make_skill_blessing("elona.stealth", 450, 12),
         God.make_skill_blessing("elona.magic_device", 550, 8),
      },
      offerings = {
         "elona.equip_ranged_bow",
         "elona.equip_ranged_crossbow",
      },
   },
   {
      _id = "itzpalt",
      elona_id = 3,
      is_primary_god = true,

      wish_name = "itzpalt",
      servant = "elona.exile",
      items = {
         secret_treasure(165),
      },
      artifact = "elona.elemental_staff",
      blessings = {
         God.make_skill_blessing("elona.stat_magic", 300, 18),
         God.make_skill_blessing("elona.meditation", 350, 15),
         God.make_skill_blessing("elona.element_fire", 50, 200),
         God.make_skill_blessing("elona.element_cold", 50, 200),
         God.make_skill_blessing("elona.element_lightning", 50, 200),
      },
      offerings = {
         "elona.equip_melee_staff",
      },
   },
   {
      _id = "ehekatl",
      elona_id = 4,
      is_primary_god = true,

      wish_name = "ehekatl",
      summon = "elona.ehekatl",
      servant = "elona.black_cat",
      items = {
         secret_treasure(163),
      },
      artifact = "elona.lucky_dagger",
      blessings = {
         God.make_skill_blessing("elona.stat_charisma", 250, 20),
         God.make_skill_blessing("elona.stat_luck", 100, 50),
         God.make_skill_blessing("elona.evasion", 300, 15),
         God.make_skill_blessing("elona.magic_capacity", 350, 17),
         God.make_skill_blessing("elona.fishing", 300, 12),
         God.make_skill_blessing("elona.lock_picking", 450, 8),
      },
      offerings = {
         "elona.offering_fish"
      }
   },
   {
      _id = "opatos",
      elona_id = 5,
      is_primary_god = true,

      wish_name = "opatos",
      summon = "elona.opatos",
      servant = "elona.golden_knight",
      items = {
         secret_treasure(164),
      },
      artifact = "elona.gaia_hammer",
      blessings = {
         God.make_skill_blessing("elona.stat_strength", 450, 11),
         God.make_skill_blessing("elona.stat_constitution", 350, 16),
         God.make_skill_blessing("elona.shield", 350, 15),
         God.make_skill_blessing("elona.weight_lifting", 300, 16),
         God.make_skill_blessing("elona.mining", 350, 12),
         God.make_skill_blessing("elona.magic_device", 450, 8),
      },
      offerings = {
         "elona.offering_ore"
      }
   },
   {
      _id = "jure",
      elona_id = 6,
      is_primary_god = true,

      wish_name = "jure",
      servant = "elona.defender",
      items = {
         { id = "elona.jures_gem_stone_of_holy_rain", _only_once = true },
         secret_treasure(166),
      },
      artifact = "elona.holy_lance",
      blessings = {
         God.make_skill_blessing("elona.stat_will", 300, 16),
         God.make_skill_blessing("elona.healing", 250, 18),
         God.make_skill_blessing("elona.meditation", 400, 10),
         God.make_skill_blessing("elona.anatomy", 400, 9),
         God.make_skill_blessing("elona.cooking", 450, 8),
         God.make_skill_blessing("elona.magic_device", 400, 10),
         God.make_skill_blessing("elona.magic_capacity", 400, 12),
      },
      offerings = {
         "elona.offering_ore",
      },
   },
   {
      _id = "kumiromi",
      elona_id = 7,
      is_primary_god = true,

      wish_name = "kumiromi",
      summon = "elona.kumiromi",
      servant = "elona.cute_fairy",
      items = {
         { id = "elona.kumiromis_gem_stone_of_rejuvenation", _only_once = true },
      },
      artifact = "elona.kumiromi_scythe",
      blessings = {
         God.make_skill_blessing("elona.stat_perception", 400, 8),
         God.make_skill_blessing("elona.stat_dexterity", 350, 12),
         God.make_skill_blessing("elona.stat_learning", 250, 16),
         God.make_skill_blessing("elona.gardening", 300, 12),
         God.make_skill_blessing("elona.alchemy", 350, 10),
         God.make_skill_blessing("elona.tailoring", 350, 9),
         God.make_skill_blessing("elona.literacy", 350, 8),
      },
      offerings = {
         "elona.offering_vegetable",
         "elona.crop_seed",
      }
   },
}

data:add_multi("elona.god", god)
