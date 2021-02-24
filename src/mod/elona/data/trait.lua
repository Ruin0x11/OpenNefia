local function gain_or_lose_action(skill_id)
   return function(cur_level, chara, prev_level)
      if cur_level > 0 and prev_level <= 0 then
         chara:mod_base_skill_level(skill_id, 1, "set")
      elseif prev_level > 0 and cur_level <= 0 then
         chara:mod_base_skill_level(skill_id, 0, "set")
      end
   end
end

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
      type = "feat",

      -- >>>>>>>> shade2/trait.hsp:142 		spGain(actDrainBlood) ...
      on_modify_level = gain_or_lose_action("elona.action_drain_blood"),
      -- <<<<<<<< shade2/trait.hsp:142 		spGain(actDrainBlood) ..
   },
   {
      _id = "leader",
      elona_id = 40,

      level_min = 0,
      level_max = 1,
      type = "feat",

      -- >>>>>>>> shade2/trait.hsp:153 		spGain(actLeadership) ...
      on_modify_level = gain_or_lose_action("elona.action_leadership"),
      -- <<<<<<<< shade2/trait.hsp:153 		spGain(actLeadership) ..
   },
   {
      _id = "short_teleport",
      elona_id = 13,

      level_min = 0,
      level_max = 1,
      type = "feat",

      -- >>>>>>>> shade2/trait.hsp:164 		spGain(actShortTeleport) ...
      on_modify_level = gain_or_lose_action("elona.action_dimensional_move")
      -- <<<<<<<< shade2/trait.hsp:164 		spGain(actShortTeleport) ..
   },
   {
      _id = "breath_fire",
      elona_id = 14,

      level_min = 0,
      level_max = 1,
      type = "feat",

      -- >>>>>>>> shade2/trait.hsp:174 		spGain(actBreathFire) ...
      on_modify_level = gain_or_lose_action("elona.action_fire_breath")
      -- <<<<<<<< shade2/trait.hsp:174 		spGain(actBreathFire) ..
   },
   {
      _id = "act_sleep",
      elona_id = 22,

      level_min = 0,
      level_max = 1,
      type = "feat",

      -- >>>>>>>> shade2/trait.hsp:185 		spGain(actTouchSleep) ...
      on_modify_level = gain_or_lose_action("elona.action_touch_of_sleep")
      -- <<<<<<<< shade2/trait.hsp:185 		spGain(actTouchSleep) ..
   },
   {
      _id = "act_poison",
      elona_id = 23,

      level_min = 0,
      level_max = 1,
      type = "feat",

      -- >>>>>>>> shade2/trait.hsp:197 		spGain(actTouchPoison) ...
      on_modify_level = gain_or_lose_action("elona.action_touch_of_poison")
      -- <<<<<<<< shade2/trait.hsp:197 		spGain(actTouchPoison) ..
   },
   {
      _id = "sexy",
      elona_id = 21,

      level_min = 0,
      level_max = 2,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_charisma", self.level*4, "add")
      end
   },
   {
      _id = "str",
      elona_id = 5,

      level_min = 0,
      level_max = 3,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_strength", self.level*3, "add")
      end
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
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_constitution", self.level*3, "add")
      end
   },
   {
      _id = "martial",
      elona_id = 20,

      level_min = 0,
      level_max = 2,
      type = "feat",

      can_acquire = function(self, chara)
         return chara:has_skill("elona.martial_arts")
      end,

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.martial_arts", self.level*3, "add")
      end
   },
   {
      _id = "casting",
      elona_id = 12,

      level_min = 0,
      level_max = 2,
      type = "feat",

      on_refresh = function(self, chara)
         if chara:has_skill("elona.casting") then
            chara:mod_skill_level("elona.casting", self.level*4, "add")
         end
      end
   },
   {
      _id = "power_bash",
      elona_id = 43,

      level_min = 0,
      level_max = 1,
      type = "feat",

      can_learn = function(self, chara)
         return chara:has_skill("elona.shield")
      end,

      on_refresh = function(self, chara)
         -- cBitMod cPowerBash,pc,true
      end
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
      type = "feat",

      can_learn = function(self, chara)
         return chara:has_skill("elona.dual_wield")
      end,

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.dual_wield", self.level*4, "add")
      end
   },
   {
      _id = "darkness",
      elona_id = 15,

      level_min = 0,
      level_max = 2,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.darkness", self.level * (50 / 2), "add")
      end
   },
   {
      _id = "poison",
      elona_id = 18,

      level_min = 0,
      level_max = 2,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.poison", self.level * (50 / 2), "add")
      end
   },
   {
      _id = "trade",
      elona_id = 16,

      level_min = 0,
      level_max = 2,
      type = "feat",

      can_learn = function(self, chara)
         return chara:has_skill("elona.negotiation")
      end,

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.negotiation", self.level*4, "add")
      end
   },
   {
      _id = "faith",
      elona_id = 17,

      level_min = 0,
      level_max = 2,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.faith", self.level*4, "add")
      end
   },
   {
      _id = "lucky",
      elona_id = 1,

      level_min = 0,
      level_max = 3,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_luck", self.level*5, "add")
      end
   },
   {
      _id = "hp",
      elona_id = 2,

      level_min = 0,
      level_max = 5,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_life", self.level*5, "add")
      end
   },
   {
      _id = "mp",
      elona_id = 11,

      level_min = 0,
      level_max = 5,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_mana", self.level*5, "add")
      end
   },
   {
      _id = "alert",
      elona_id = 6,

      level_min = 0,
      level_max = 2,
      type = "feat",

      can_learn = function(self, chara)
         return chara:has_skill("elona.detection")
      end,

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.detection", self.level*3, "add")
      end
   },
   {
      _id = "runner",
      elona_id = 4,

      level_min = 0,
      level_max = 2,
      type = "feat",

      can_learn = function(self, chara)
         if self.level == 1 then
            return chara.level >= 5
         end
         return true
      end,

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_speed", self.level*5, "add")
      end
   },
   {
      _id = "hardy",
      elona_id = 7,

      level_min = 0,
      level_max = 3,
      type = "feat",

      can_learn = function(self, chara)
         if self.level == 1 then
            return chara.level >= 5
         end
         return true
      end,

      on_refresh = function(self, chara)
         chara:mod("pv", self.level*5, "add")
      end
   },
   {
      _id = "defense",
      elona_id = 8,

      level_min = 0,
      level_max = 3,
      type = "feat",

      on_refresh = function(self, chara)
         chara:mod("dv", self.level*4, "add")
      end
   },
   {
      _id = "evade",
      elona_id = 10,

      level_min = 0,
      level_max = 3,
      type = "feat",

      can_learn = function(self, chara)
         return chara:has_skill("elona.evasion")
      end,

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.evasion", self.level*2, "add")
      end
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
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod("pv", self.level*3, "add")
      end
   },
   {
      _id = "joint_ache",
      elona_id = 26,

      level_min = -3,
      level_max = 3,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_dexterity", self.level*3, "add")
      end
   },
   {
      _id = "troll_blood",
      elona_id = 27,

      level_min = -2,
      level_max = 2,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.healing", self.level*4, "add")
      end
   },
   {
      _id = "leg",
      elona_id = 28,

      level_min = -3,
      level_max = 3,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_speed", self.level*5, "add")
      end
   },
   {
      _id = "arm",
      elona_id = 29,

      level_min = -3,
      level_max = 3,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_strength", self.level*3, "add")
      end
   },
   {
      _id = "voice",
      elona_id = 30,

      level_min = -2,
      level_max = 2,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_charisma", self.level*5, "add")
      end
   },
   {
      _id = "brain",
      elona_id = 31,

      level_min = -2,
      level_max = 2,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.memorization", self.level*4, "add")
      end
   },
   {
      _id = "res_magic",
      elona_id = 32,

      level_min = -1,
      level_max = 1,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.magic", self.level * 50, "add")
      end
   },
   {
      _id = "res_sound",
      elona_id = 33,

      level_min = -1,
      level_max = 1,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.sound", self.level * 50, "add")
      end
   },
   {
      _id = "res_fire",
      elona_id = 34,

      level_min = -1,
      level_max = 1,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.fire", self.level * 50, "add")
      end
   },
   {
      _id = "res_cold",
      elona_id = 35,

      level_min = -1,
      level_max = 1,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.cold", self.level * 50, "add")
      end
   },
   {
      _id = "res_lightning",
      elona_id = 36,

      level_min = -1,
      level_max = 1,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.lightning", self.level * 50, "add")
      end
   },
   {
      _id = "eye",
      elona_id = 37,

      level_min = -2,
      level_max = 2,
      type = "mutation",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_perception", self.level * 5, "add")
      end
   },
   {
      _id = "perm_fire",
      elona_id = 150,

      level_min = -2,
      level_max = 2,
      type = "race",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.fire", self.level * 50, "add")
      end
   },
   {
      _id = "perm_cold",
      elona_id = 151,

      level_min = -2,
      level_max = 2,
      type = "race",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.cold", self.level * 50, "add")
      end
   },
   {
      _id = "perm_poison",
      elona_id = 152,

      level_min = -2,
      level_max = 2,
      type = "race",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.poison", self.level * 50, "add")
      end
   },
   {
      _id = "perm_darkness",
      elona_id = 155,

      level_min = -2,
      level_max = 2,
      type = "race",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.darkness", self.level * 50, "add")
      end
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
      type = "race",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.magic", 3*50, "add")
         chara:mod_resist_level("elona.lightning", 2*50, "add")
         chara:mod_resist_level("elona.darkness", 4*50, "add")
         chara:mod_resist_level("elona.sound", 1*50, "add")
         chara:mod_resist_level("elona.chaos", 2*50, "add")
         chara:mod_resist_level("elona.mind", 4*50, "add")
         chara:mod_resist_level("elona.nerve", 2*50, "add")
         chara:mod_resist_level("elona.cold", 2*50, "add")
      end
   },
   {
      _id = "perm_weak",
      elona_id = 161,

      level_min = 0,
      level_max = 1,
      type = "race",

      on_refresh = function(self, chara)
         local dv = chara:calc("dv")
         if dv > 0 then
            dv = math.floor(dv * 125 / 100) + 50
            chara:mod("dv", dv)
         end
      end
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
      type = "race",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.magic", self.level * 50, "add")
      end
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
}
data:add_multi("base.trait", trait)

local function calc_ether_ugly(self, chara)
   return math.floor(self.level * (4 + chara:calc("level") / 5))
end

local function calc_ether_foot_spd(self, chara)
   return math.floor(20 + chara:calc("level") / 2)
end

local function calc_ether_eye_chr(self, chara)
   return math.floor(-(5 + chara:calc("level") / 3))
end

local function calc_ether_eye_per(self, chara)
   return math.floor(5 + chara:calc("level") / 3)
end

local function calc_ether_feather_spd(self, chara)
   return math.floor(12 + chara:calc("level") / 4)
end

local function calc_ether_neck_pv(self, chara)
   return math.floor(12 + chara:calc("level"))
end

local function calc_ether_neck_chr(self, chara)
   return math.floor(-(5 + chara:calc("level") / 5))
end

local function calc_ether_rage_dv(self, chara)
   return math.floor(-(15 + chara:calc("level") * 3 / 2))
end

local function calc_ether_rage_dmg(self, chara)
   return math.floor(5 + chara:calc("level") * 2 / 3)
end

local function calc_ether_mind_end(self, chara)
   return math.floor(-(5 + chara:calc("level") / 3))
end

local function calc_ether_mind_dex(self, chara)
   return math.floor(-(4 + chara:calc("level") / 4))
end

local function calc_ether_mind_ler(self, chara)
   return math.floor(6 + chara:calc("level") / 2)
end

local function calc_ether_mind_wil(self, chara)
   return math.floor(2 + chara:calc("level") / 6)
end

local function calc_ether_weak_str(self, chara)
   return math.floor(-(4 * chara:calc("level") / 2))
end

local function calc_ether_fool_mag(self, chara)
   return math.floor(-(4 * chara:calc("level") / 2))
end

local function calc_ether_heavy_spd(self, chara)
   return math.floor(-(20 + chara:calc("level") / 2))
end

local function calc_ether_heavy_pv(self, chara)
   return math.floor(15 + chara:calc("level") / 2)
end

local function block_or_unblock_body_part(body_part)
   return function(cur_level, chara, prev_level)
      if cur_level < 0 and prev_level >= 0 then
         chara:iter_items_equipped_at(body_part):each(function(item) chara:unequip_item(item) end)
         chara:set_body_part_blocked(body_part, true)
      elseif prev_level < 0 and cur_level >= 0 then
         chara:set_body_part_blocked(body_part, false)
      end
   end
end

local ether_trait = {
   {
      _id = "ether_gravity",
      elona_id = 201,

      level_min = -3,
      level_max = 0,
      type = "ether_disease"
   },
   {
      _id = "ether_ugly",
      elona_id = 202,

      level_min = -3,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_charisma", calc_ether_ugly(self, chara), "add")
      end,

      locale_params = function(self, chara)
         return calc_ether_ugly(self, chara)
      end
   },
   {
      _id = "ether_foot",
      elona_id = 203,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_speed", calc_ether_foot_spd(self, chara), "add")
      end,

      -- >>>>>>>> shade2/chara_func.hsp:751 		if tId@=traitEtherFoot{ ...
      on_modify_level = block_or_unblock_body_part("elona.leg"),
      -- <<<<<<<< shade2/chara_func.hsp:753 			} ..

      locale_params = function(self, chara)
         return calc_ether_foot_spd(self, chara)
      end
   },
   {
      _id = "ether_eye",
      elona_id = 204,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_charisma", calc_ether_eye_chr(self, chara), "add")
         chara:mod_skill_level("elona.stat_perception", calc_ether_eye_per(self, chara), "add")
      end,

      locale_params = function(self, chara)
         return calc_ether_eye_chr(self, chara), calc_ether_eye_per(self, chara)
      end
   },
   {
      _id = "ether_feather",
      elona_id = 205,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod("is_floating", true)
         chara:mod_skill_level("elona.stat_speed", calc_ether_feather_spd(self, chara), "add")
      end,

      -- >>>>>>>> shade2/chara_func.hsp:754 		if tId@=traitEtherFeather{ ...
      on_modify_level = block_or_unblock_body_part("elona.back"),
      -- <<<<<<<< shade2/chara_func.hsp:756 			} ..

      locale_params = function(self, chara)
         return calc_ether_feather_spd(self, chara)
      end
   },
   {
      _id = "ether_neck",
      elona_id = 206,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_charisma", calc_ether_neck_chr(self, chara), "add")
         chara:mod("pv", calc_ether_neck_pv(self, chara), "add")
      end,

      -- >>>>>>>> shade2/chara_func.hsp:757 		if tId@=traitEtherNeck{ ...
      on_modify_level = block_or_unblock_body_part("elona.neck"),
      -- <<<<<<<< shade2/chara_func.hsp:759 			} ..

      locale_params = function(self, chara)
         return calc_ether_neck_chr(self, chara), calc_ether_neck_pv(self, chara)
      end
   },
   {
      _id = "ether_rage",
      elona_id = 207,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod("dv", calc_ether_rage_dv(self, chara), "add")
      end,

      locale_params = function(self, chara)
         return calc_ether_rage_dv(self, chara), calc_ether_rage_dmg(self, chara)
      end
   },
   {
      _id = "ether_mind",
      elona_id = 208,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_constitution", calc_ether_mind_end(self, chara), "add")
         chara:mod_skill_level("elona.stat_dexterity", calc_ether_mind_dex(self, chara), "add")
         chara:mod_skill_level("elona.stat_learning", calc_ether_mind_ler(self, chara), "add")
         chara:mod_skill_level("elona.stat_will", calc_ether_mind_wil(self, chara), "add")
      end,

      locale_params = function(self, chara)
         return calc_ether_mind_end(self, chara),
         calc_ether_mind_dex(self, chara),
         calc_ether_mind_ler(self, chara),
         calc_ether_mind_wil(self, chara)
      end
   },
   {
      _id = "ether_rain",
      elona_id = 209,

      level_min = -1,
      level_max = 0,
      type = "ether_disease"
   },
   {
      _id = "ether_potion",
      elona_id = 210,

      level_min = -1,
      level_max = 0,
      type = "ether_disease"
   },
   {
      _id = "ether_weak",
      elona_id = 211,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_strength", calc_ether_weak_str(self, chara), "add")
         chara:mod_skill_level("elona.stat_life", -15, "add")
      end,

      locale_params = function(self, chara)
         return calc_ether_weak_str(self, chara)
      end
   },
   {
      _id = "ether_fool",
      elona_id = 212,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_magic", calc_ether_fool_mag(self, chara), "add")
         chara:mod_skill_level("elona.stat_mana", -15, "add")
      end,

      locale_params = function(self, chara)
         return calc_ether_fool_mag(self, chara)
      end
   },
   {
      _id = "ether_heavy",
      elona_id = 213,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_skill_level("elona.stat_speed", calc_ether_heavy_spd(self, chara), "add")
         chara:mod("pv", calc_ether_heavy_pv(self, chara), "add")
      end,

      locale_params = function(self, chara)
         return calc_ether_heavy_pv(self, chara), calc_ether_heavy_spd(self, chara)
      end
   },
   {
      _id = "ether_teleport",
      elona_id = 214,

      level_min = -1,
      level_max = 0,
      type = "ether_disease"
   },
   {
      _id = "ether_staff",
      elona_id = 215,

      level_min = -1,
      level_max = 0,
      type = "ether_disease"
   },
   {
      _id = "ether_poison",
      elona_id = 216,

      level_min = -1,
      level_max = 0,
      type = "ether_disease",

      on_refresh = function(self, chara)
         chara:mod_resist_level("elona.poison", 100, "add")
      end
   }
}
data:add_multi("base.trait", ether_trait)
