local skill = {
   {
      _id = "stat_life",
      type = "stat_special",
      elona_id = 2,
      cost = 0,
      range = 0,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   },
   {
      _id = "stat_mana",
      type = "stat_special",
      elona_id = 3,
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
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_constitution",
      type = "stat",
      elona_id = 11,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_dexterity",
      type = "stat",
      elona_id = 12,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_perception",
      type = "stat",
      elona_id = 13,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_learning",
      type = "stat",
      elona_id = 14,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_will",
      type = "stat",
      elona_id = 15,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_magic",
      type = "stat",
      elona_id = 16,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_charisma",
      type = "stat",
      elona_id = 17,
      cost = 0,
      range = 0,
   },
   {
      _id = "stat_speed",
      type = "stat",
      elona_id = 18,
      cost = 0,
      range = 0,

      calc_initial_level = function(level, chara)
         -- >>>>>>>> shade2/calculation.hsp:954 	if sId=rsSPD : p(1)=a*(100+cLevel(c)*2)/100 : els ..
         return math.floor(level * (100 + chara.level * 2) / 100)
         -- <<<<<<<< shade2/calculation.hsp:954 	if sId=rsSPD : p(1)=a*(100+cLevel(c)*2)/100 : els ..
      end
   },
   {
      _id = "stat_luck",
      type = "stat",
      elona_id = 19,
      cost = 0,
      range = 0,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   },
   {
      _id = "long_sword",
      type = "weapon_proficiency",
      elona_id = 100,
      related_skill = "elona.stat_strength",
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "short_sword",
      type = "weapon_proficiency",
      elona_id = 101,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "axe",
      type = "weapon_proficiency",
      elona_id = 102,
      related_skill = "elona.stat_strength",
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "blunt",
      type = "weapon_proficiency",
      elona_id = 103,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "polearm",
      type = "weapon_proficiency",
      elona_id = 104,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "stave",
      type = "weapon_proficiency",
      elona_id = 105,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "martial_arts",
      type = "weapon_proficiency",
      elona_id = 106,
      related_skill = "elona.stat_strength",
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
      type = "weapon_proficiency",
      elona_id = 107,
      related_skill = "elona.stat_strength",
      cost = 0,
      range = 0,

      attack_animation = 1,
   },
   {
      _id = "bow",
      type = "weapon_proficiency",
      elona_id = 108,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,

      is_main_skill = true,
      attack_animation = 2,
   },
   {
      _id = "crossbow",
      type = "weapon_proficiency",
      elona_id = 109,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,

      attack_animation = 2,
   },
   {
      _id = "firearm",
      type = "weapon_proficiency",
      elona_id = 110,
      related_skill = "elona.stat_perception",
      cost = 0,
      range = 0,

      attack_animation = 2,
   },
   {
      _id = "throwing",
      type = "weapon_proficiency",
      elona_id = 111,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,

      attack_animation = 2,
   },
   {
      _id = "shield",
      type = "skill",
      elona_id = 168,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "evasion",
      type = "skill",
      elona_id = 173,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,

      is_main_skill = true
   },
   {
      _id = "dual_wield",
      type = "skill",
      elona_id = 166,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,
   },
   {
      _id = "two_hand",
      type = "skill",
      elona_id = 167,
      related_skill = "elona.stat_strength",
      cost = 0,
      range = 0,
   },
   {
      _id = "weight_lifting",
      type = "skill",
      elona_id = 153,
      related_skill = "elona.stat_strength",
      cost = 0,
      range = 0,
   },
   {
      _id = "tactics",
      type = "skill",
      elona_id = 152,
      related_skill = "elona.stat_strength",
      cost = 0,
      range = 0,
   },
   {
      _id = "marksman",
      type = "skill",
      elona_id = 189,
      related_skill = "elona.stat_perception",
      cost = 0,
      range = 0,
   },
   {
      _id = "healing",
      type = "skill",
      elona_id = 154,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "mining",
      type = "skill",
      elona_id = 163,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "carpentry",
      type = "skill",
      elona_id = 176,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "heavy_armor",
      type = "skill",
      elona_id = 169,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "medium_armor",
      type = "skill",
      elona_id = 170,
      related_skill = "elona.stat_constitution",
      cost = 0,
      range = 0,
   },
   {
      _id = "light_armor",
      type = "skill",
      elona_id = 171,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,
   },
   {
      _id = "lock_picking",
      type = "skill",
      elona_id = 158,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,
   },
   {
      _id = "disarm_trap",
      type = "skill",
      elona_id = 175,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,
   },
   {
      _id = "tailoring",
      type = "skill",
      elona_id = 177,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,
   },
   {
      _id = "jeweler",
      type = "skill",
      elona_id = 179,
      related_skill = "elona.stat_dexterity",
      cost = 0,
      range = 0,
   },
   {
      _id = "stealth",
      type = "skill",
      elona_id = 157,
      related_skill = "elona.stat_perception",
      cost = 0,
      range = 0,
   },
   {
      _id = "detection",
      type = "skill",
      elona_id = 159,
      related_skill = "elona.stat_perception",
      cost = 0,
      range = 0,
   },
   {
      _id = "sense_quality",
      type = "skill",
      elona_id = 162,
      related_skill = "elona.stat_perception",
      cost = 0,
      range = 0,
   },
   {
      _id = "eye_of_mind",
      type = "skill",
      elona_id = 186,
      related_skill = "elona.stat_perception",
      cost = 0,
      range = 0,
   },
   {
      _id = "greater_evasion",
      type = "skill",
      elona_id = 187,
      related_skill = "elona.stat_perception",
      cost = 0,
      range = 0,
   },
   {
      _id = "anatomy",
      type = "skill",
      elona_id = 161,
      related_skill = "elona.stat_learning",
      cost = 0,
      range = 0,
   },
   {
      _id = "literacy",
      type = "skill",
      elona_id = 150,
      related_skill = "elona.stat_learning",
      cost = 0,
      range = 0,
   },
   {
      _id = "memorization",
      type = "skill",
      elona_id = 165,
      related_skill = "elona.stat_learning",
      cost = 0,
      range = 0,
   },
   {
      _id = "alchemy",
      type = "skill",
      elona_id = 178,
      related_skill = "elona.stat_learning",
      cost = 0,
      range = 0,
   },
   {
      _id = "gardening",
      type = "skill",
      elona_id = 180,
      related_skill = "elona.stat_learning",
      cost = 0,
      range = 0,
   },
   {
      _id = "gene_engineer",
      type = "skill",
      elona_id = 151,
      related_skill = "elona.stat_learning",
      cost = 0,
      range = 0,
   },
   {
      _id = "meditation",
      type = "skill",
      elona_id = 155,
      related_skill = "elona.stat_magic",
      cost = 0,
      range = 0,
   },
   {
      _id = "magic_device",
      type = "skill",
      elona_id = 174,
      related_skill = "elona.stat_magic",
      cost = 0,
      range = 0,
   },
   {
      _id = "casting",
      type = "skill",
      elona_id = 172,
      related_skill = "elona.stat_magic",
      cost = 0,
      range = 0,
   },
   {
      _id = "control_magic",
      type = "skill",
      elona_id = 188,
      related_skill = "elona.stat_magic",
      cost = 0,
      range = 0,
   },
   {
      _id = "magic_capacity",
      type = "skill",
      elona_id = 164,
      related_skill = "elona.stat_will",
      cost = 0,
      range = 0,
   },
   {
      _id = "faith",
      type = "skill",
      elona_id = 181,
      related_skill = "elona.stat_will",
      cost = 0,
      range = 0,
   },
   {
      _id = "traveling",
      type = "skill",
      elona_id = 182,
      related_skill = "elona.stat_will",
      cost = 0,
      range = 0,
   },
   {
      _id = "negotiation",
      type = "skill",
      elona_id = 156,
      related_skill = "elona.stat_charisma",
      cost = 0,
      range = 0,
   },
   {
      _id = "investing",
      type = "skill",
      elona_id = 160,
      related_skill = "elona.stat_charisma",
      cost = 0,
      range = 0,
   },
}

data:add_multi("base.skill", skill)
