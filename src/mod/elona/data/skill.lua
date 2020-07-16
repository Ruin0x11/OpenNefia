local skill = {
   {
      _id = "stat_life",
      type = "stat",
      elona_id = 2,
      ability_type = 0,
      cost = 0,
      range = 0,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   },
   {
      _id = "stat_mana",
      type = "stat",
      elona_id = 3,
      ability_type = 0,
      cost = 0,
      range = 0,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   },
   {
      _id = "stat_strength",
      type = "stat",
      elona_id = 10,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_constitution",
      type = "stat",
      elona_id = 11,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_dexterity",
      type = "stat",
      elona_id = 12,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_perception",
      type = "stat",
      elona_id = 13,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_learning",
      type = "stat",
      elona_id = 14,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_will",
      type = "stat",
      elona_id = 15,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_magic",
      type = "stat",
      elona_id = 16,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_charisma",
      type = "stat",
      elona_id = 17,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_speed",
      type = "stat",
      elona_id = 18,
      ability_type = 0,
      cost = 0,
      range = 0,

      calc_initial_level = function(level, chara)
         return math.floor(level * (100 + chara.level * 2) / 100)
      end
   },
   {
      _id = "stat_luck",
      type = "stat",
      elona_id = 19,
      ability_type = 0,
      cost = 0,
      range = 0,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   },
   {
      _id = "long_sword",
      elona_id = 100,
      related_skill = "elona.stat_strength",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "short_sword",
      elona_id = 101,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "axe",
      elona_id = 102,
      related_skill = "elona.stat_strength",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "blunt",
      elona_id = 103,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "polearm",
      elona_id = 104,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "stave",
      elona_id = 105,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "martial_arts",
      elona_id = 106,
      related_skill = "elona.stat_strength",
      ability_type = 0,
      cost = 0,
      range = 0,

      is_main_skill = true,

      calc_damage_params = function(self, chara, weapon, target)
         local related = "elona.stat_strength"
         local dmgfix = chara:skill_level(related) / 8 + chara:skill_level(self._id) / 8 + chara:calc("damage_bonus")
         local dice_x = 2
         local dice_y = chara:skill_level(self._id) /8 + 5
         local multiplier = 0.5
            + (chara:skill_level(related)
                  + chara:skill_level(self._id) / 5
                  + chara:skill_level("elona.tactics"))
            / 40
         local pierce_rate = math.clamp(chara:skill_level(self._id) / 5, 5, 50)
         return {
            dmgfix = dmgfix,
            dice_x = dice_x,
            dice_y = dice_y,
            multiplier = multiplier,
            pierce_rate = pierce_rate
         }
      end,

      calc_critical_damage = function(self, damage_params)
         damage_params.multiplier = damage_params.multiplier * 1.25
         return damage_params
      end
   },
   {
      _id = "scythe",
      elona_id = 107,
      related_skill = "elona.stat_strength",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "bow",
      elona_id = 108,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,

      is_main_skill = true,
      attack_animation = 2,
   },
   {
      _id = "crossbow",
      elona_id = 109,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 2,
   },
   {
      _id = "firearm",
      elona_id = 110,
      related_skill = "elona.stat_perception",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 2,
   },
   {
      _id = "throwing",
      elona_id = 111,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,

      attack_animation = 2,
   },
   {
      _id = "shield",
      elona_id = 168,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "evasion",
      elona_id = 173,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,

      is_main_skill = true
   },
   {
      _id = "dual_wield",
      elona_id = 166,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "two_hand",
      elona_id = 167,
      related_skill = "elona.stat_strength",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "element_fire",
      elona_id = 50,
      ability_type = 0,
      cost = 0,
      range = 1,
   },
   {
      _id = "element_cold",
      elona_id = 51,
      ability_type = 0,
      cost = 0,
      range = 1,
   },
   {
      _id = "element_lightning",
      elona_id = 52,
      ability_type = 0,
      cost = 0,
      range = 1,
   },
   {
      _id = "element_darkness",
      elona_id = 53,
      ability_type = 0,
      cost = 0,
      range = 2,
   },
   {
      _id = "element_mind",
      elona_id = 54,
      ability_type = 0,
      cost = 0,
      range = 2,
   },
   {
      _id = "element_nether",
      elona_id = 56,
      ability_type = 0,
      cost = 0,
      range = 4,
   },
   {
      _id = "element_poison",
      elona_id = 55,
      ability_type = 0,
      cost = 0,
      range = 3,
   },
   {
      _id = "element_sound",
      elona_id = 57,
      ability_type = 0,
      cost = 0,
      range = 3,
   },
   {
      _id = "element_chaos",
      elona_id = 59,
      ability_type = 0,
      cost = 0,
      range = 4,
   },
   {
      _id = "element_nerve",
      elona_id = 58,
      ability_type = 0,
      cost = 0,
      range = 3,
   },
   {
      _id = "element_magic",
      elona_id = 60,
      ability_type = 0,
      cost = 0,
      range = 5,
   },
   {
      _id = "element_cut",
      elona_id = 61,
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "weight_lifting",
      elona_id = 153,
      related_skill = "elona.stat_strength",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "tactics",
      elona_id = 152,
      related_skill = "elona.stat_strength",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "marksman",
      elona_id = 189,
      related_skill = "elona.stat_perception",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "healing",
      elona_id = 154,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "mining",
      elona_id = 163,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "carpentry",
      elona_id = 176,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "heavy_armor",
      elona_id = 169,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,

      calc_armor_penalty = function(self, chara)
         return 17 - chara:skill_level(self._id) / 5
      end
   },
   {
      _id = "medium_armor",
      elona_id = 170,
      related_skill = "elona.stat_constitution",
      ability_type = 0,
      cost = 0,
      range = 0,

      calc_armor_penalty = function(self, chara)
         return 12 - chara:skill_level(self._id) / 5
      end
   },
   {
      _id = "light_armor",
      elona_id = 171,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "lock_picking",
      elona_id = 158,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "disarm_trap",
      elona_id = 175,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "tailoring",
      elona_id = 177,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "jeweler",
      elona_id = 179,
      related_skill = "elona.stat_dexterity",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "stealth",
      elona_id = 157,
      related_skill = "elona.stat_perception",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "detection",
      elona_id = 159,
      related_skill = "elona.stat_perception",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "sense_quality",
      elona_id = 162,
      related_skill = "elona.stat_perception",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "eye_of_mind",
      elona_id = 186,
      related_skill = "elona.stat_perception",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "greater_evasion",
      elona_id = 187,
      related_skill = "elona.stat_perception",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "anatomy",
      elona_id = 161,
      related_skill = "elona.stat_learning",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "literacy",
      elona_id = 150,
      related_skill = "elona.stat_learning",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "memorization",
      elona_id = 165,
      related_skill = "elona.stat_learning",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "alchemy",
      elona_id = 178,
      related_skill = "elona.stat_learning",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "gardening",
      elona_id = 180,
      related_skill = "elona.stat_learning",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "gene_engineer",
      elona_id = 151,
      related_skill = "elona.stat_learning",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "meditation",
      elona_id = 155,
      related_skill = "elona.stat_magic",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "magic_device",
      elona_id = 174,
      related_skill = "elona.stat_magic",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "casting",
      elona_id = 172,
      related_skill = "elona.stat_magic",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "control_magic",
      elona_id = 188,
      related_skill = "elona.stat_magic",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "magic_capacity",
      elona_id = 164,
      related_skill = "elona.stat_will",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "faith",
      elona_id = 181,
      related_skill = "elona.stat_will",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "traveling",
      elona_id = 182,
      related_skill = "elona.stat_will",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "negotiation",
      elona_id = 156,
      related_skill = "elona.stat_charisma",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
   {
      _id = "investing",
      elona_id = 160,
      related_skill = "elona.stat_charisma",
      ability_type = 0,
      cost = 0,
      range = 0,
   },
}

data:add_multi("base.skill", skill)
