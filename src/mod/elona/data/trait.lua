-- TODO categories need to be corrected

local trait = {
  {
    _id = "desire_for_violence",
    elona_id = 207,
    category = "feat",

    on_refresh = function(self, chara)
      local dv_delta = -(15 + math.floor(chara:calc("level") * 3 / 2))
      chara:mod("dv", dv_delta, "add")
    end
  },
  {
    _id = "opatos",
    elona_id = 164,
    category = "etc"
  },
  {
    _id = "long_distance_runner",
    elona_id = 24,
    category = "feat"
  },
  {
    _id = "extra_bonus_points",
    elona_id = 154,
    category = "feat"
  },
  {
    _id = "extra_body_parts",
    elona_id = 0,
    category = "race"
  },
  {
    _id = "weight_lifting",
    elona_id = 201,
    category = "feat"
  },
  {
    _id = "weight_lifting_2",
    elona_id = 205,
    category = "feat",

    on_refresh = function(self, chara)
      chara:mod("is_floating", true)
      local speed_delta = 12 + math.floor(chara:calc("level") / 4)
      chara:mod_skill_level("elona.stat_speed", speed_delta, "add")
    end
  },
  {
    _id = "slow_digestion",
    elona_id = 158,
    category = "feat"
  },
  {
    _id = "more_materials",
    elona_id = 159,
    category = "feat"
  },
  {
    _id = "reduce_overcast_damage",
    elona_id = 156,
    category = "feat"
  },
  {
    _id = "slow_ether_disease",
    elona_id = 168,
    category = "feat"
  },
  {
    _id = "magic_resistance",
    elona_id = 153,
    category = "feat",

    on_refresh = function(self, chara)
      chara:mod_resist_level("elona.magic", self.level * 50, "add")
    end
  },
  {
    _id = "fairy_resistances",
    elona_id = 160,
    category = "race",

    on_refresh = function(self, chara)
      chara:mod_resist_level("elona.magic", 150, "add")
      chara:mod_resist_level("elona.lightning", 100, "add")
      chara:mod_resist_level("elona.darkness", 200, "add")
      chara:mod_resist_level("elona.sound", 50, "add")
      chara:mod_resist_level("elona.chaos", 100, "add")
      chara:mod_resist_level("elona.mind", 200, "add")
      chara:mod_resist_level("elona.nerve", 100, "add")
      chara:mod_resist_level("elona.cold", 100, "add")
    end
  },
  {
    _id = "fairy_equip_restriction",
    elona_id = 161,
    category = "race",

    on_refresh = function(self, chara)
      local dv = chara:calc("dv")
      if dv > 0 then
        dv = math.floor(dv * 125 / 100) + 50
        chara:mod("dv", dv)
      end
    end
  },
  {
    _id = "resist_cold",
    elona_id = 151,
    category = "feat",

    on_refresh = function(self, chara)
      chara:mod_resist_level("elona.cold", self.level * 50, "add")
    end
  },
  {
    _id = "resist_poison",
    elona_id = 152,
    category = "feat",

    on_refresh = function(self, chara)
      chara:mod_resist_level("elona.poison", self.level * 50, "add")
    end
  },
  {
    _id = "resist_darkness",
    elona_id = 155,
    category = "feat",

    on_refresh = function(self, chara)
      chara:mod_resist_level("elona.darkness", self.level * 50, "add")
    end
  },
  {
    _id = "immune_to_dimming",
    elona_id = 157,
    category = "feat"
  },
  {
    _id = "no_guilt",
    elona_id = 162,
    category = "feat"
  },
  {
    _id = "good_person",
    elona_id = 169,
    category = "feat"
  },
  {
    _id = "can_eat_human_flesh",
    elona_id = 41,
    category = "mutation"
  },
  {
    _id = "cures_sanity",
    elona_id = 166,
    category = "race"
  },
  {
    _id = "no_inflict_fear",
    elona_id = 44,
    category = "feat"
  }
}
data:add_multi("base.trait", trait)

local trait = {
  {
    _id = "stamina",
    elona_id = 24,

    level_min = 0,
    level_max = 3,
    type = "feat"
  },
  {
    _id = "drain_hp",
    elona_id = 3,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "leader",
    elona_id = 40,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "short_teleport",
    elona_id = 13,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "breath_fire",
    elona_id = 14,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "act_sleep",
    elona_id = 22,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "act_poison",
    elona_id = 23,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "sexy",
    elona_id = 21,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "str",
    elona_id = 5,

    level_min = 0,
    level_max = 3,
    type = "feat"
  },
  {
    _id = "tax",
    elona_id = 38,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "good_pay",
    elona_id = 39,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "res_curse",
    elona_id = 42,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "end",
    elona_id = 9,

    level_min = 0,
    level_max = 3,
    type = "feat"
  },
  {
    _id = "martial",
    elona_id = 20,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "casting",
    elona_id = 12,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "power_bash",
    elona_id = 43,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "no_fear",
    elona_id = 44,

    level_min = 0,
    level_max = 1,
    type = "feat"
  },
  {
    _id = "two_wield",
    elona_id = 19,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "darkness",
    elona_id = 15,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "poison",
    elona_id = 18,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "trade",
    elona_id = 16,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "faith",
    elona_id = 17,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "lucky",
    elona_id = 1,

    level_min = 0,
    level_max = 3,
    type = "feat"
  },
  {
    _id = "hp",
    elona_id = 2,

    level_min = 0,
    level_max = 5,
    type = "feat"
  },
  {
    _id = "mp",
    elona_id = 11,

    level_min = 0,
    level_max = 5,
    type = "feat"
  },
  {
    _id = "alert",
    elona_id = 6,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "runner",
    elona_id = 4,

    level_min = 0,
    level_max = 2,
    type = "feat"
  },
  {
    _id = "hardy",
    elona_id = 7,

    level_min = 0,
    level_max = 3,
    type = "feat"
  },
  {
    _id = "defense",
    elona_id = 8,

    level_min = 0,
    level_max = 3,
    type = "feat"
  },
  {
    _id = "evade",
    elona_id = 10,

    level_min = 0,
    level_max = 3,
    type = "feat"
  },
  {
    _id = "eat_human",
    elona_id = 41,

    level_min = 0,
    level_max = 1,
    type = "mutation"
  },
  {
    _id = "iron_skin",
    elona_id = 25,

    level_min = -3,
    level_max = 3,
    type = "mutation"
  },
  {
    _id = "joint_ache",
    elona_id = 26,

    level_min = -3,
    level_max = 3,
    type = "mutation"
  },
  {
    _id = "troll_blood",
    elona_id = 27,

    level_min = -2,
    level_max = 2,
    type = "mutation"
  },
  {
    _id = "leg",
    elona_id = 28,

    level_min = -3,
    level_max = 3,
    type = "mutation"
  },
  {
    _id = "arm",
    elona_id = 29,

    level_min = -3,
    level_max = 3,
    type = "mutation"
  },
  {
    _id = "voice",
    elona_id = 30,

    level_min = -2,
    level_max = 2,
    type = "mutation"
  },
  {
    _id = "brain",
    elona_id = 31,

    level_min = -2,
    level_max = 2,
    type = "mutation"
  },
  {
    _id = "res_magic",
    elona_id = 32,

    level_min = -1,
    level_max = 1,
    type = "mutation"
  },
  {
    _id = "res_sound",
    elona_id = 33,

    level_min = -1,
    level_max = 1,
    type = "mutation"
  },
  {
    _id = "res_fire",
    elona_id = 34,

    level_min = -1,
    level_max = 1,
    type = "mutation"
  },
  {
    _id = "res_cold",
    elona_id = 35,

    level_min = -1,
    level_max = 1,
    type = "mutation"
  },
  {
    _id = "res_lightning",
    elona_id = 36,

    level_min = -1,
    level_max = 1,
    type = "mutation"
  },
  {
    _id = "eye",
    elona_id = 37,

    level_min = -2,
    level_max = 2,
    type = "mutation"
  },
  {
    _id = "perm_fire",
    elona_id = 150,

    level_min = -2,
    level_max = 2,
    type = "race"
  },
  {
    _id = "perm_cold",
    elona_id = 151,

    level_min = -2,
    level_max = 2,
    type = "race"
  },
  {
    _id = "perm_poison",
    elona_id = 152,

    level_min = -2,
    level_max = 2,
    type = "race"
  },
  {
    _id = "perm_darkness",
    elona_id = 155,

    level_min = -2,
    level_max = 2,
    type = "race"
  },
  {
    _id = "perm_capacity",
    elona_id = 156,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_resist",
    elona_id = 160,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_weak",
    elona_id = 161,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_evil",
    elona_id = 162,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_good",
    elona_id = 169,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "god_luck",
    elona_id = 163,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "god_earth",
    elona_id = 164,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "god_element",
    elona_id = 165,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "god_heal",
    elona_id = 166,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "moe",
    elona_id = 167,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_dim",
    elona_id = 157,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_material",
    elona_id = 159,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_slow_food",
    elona_id = 158,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_skill_point",
    elona_id = 154,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_magic",
    elona_id = 153,

    level_min = -2,
    level_max = 2,
    type = "race"
  },
  {
    _id = "perm_chaos_shape",
    elona_id = 0,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "perm_res_ether",
    elona_id = 168,

    level_min = 0,
    level_max = 1,
    type = "race"
  },
  {
    _id = "ether_gravity",
    elona_id = 201,

    level_min = -3,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_ugly",
    elona_id = 202,

    level_min = -3,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_foot",
    elona_id = 203,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_eye",
    elona_id = 204,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_feather",
    elona_id = 205,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_neck",
    elona_id = 206,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_rage",
    elona_id = 207,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_mind",
    elona_id = 208,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_rain",
    elona_id = 209,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_potion",
    elona_id = 210,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_weak",
    elona_id = 211,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_fool",
    elona_id = 212,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_heavy",
    elona_id = 213,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_teleport",
    elona_id = 214,

    level_min = -1,
    level_max = 0,
    type = "disease"
  },
  {
    _id = "ether_staff",
    elona_id = 215,

    level_min = -1,
    level_max = 0,
    type = "disease"
  }
}
