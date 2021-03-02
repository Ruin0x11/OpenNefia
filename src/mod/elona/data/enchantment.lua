local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local Calc = require("mod.elona.api.Calc")
local Map = require("api.Map")
local Magic = require("mod.elona_sys.api.Magic")
local Enchantment = require("mod.elona.api.Enchantment")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local I18N = require("api.I18N")
local Const = require("api.Const")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Effect = require("mod.elona.api.Effect")
local Log = require("api.Log")
local Hunger = require("mod.elona.api.Hunger")

---
--- Parameterized enchantments
---

local function filter_categories(cats)
   return function(item)
      return fun.iter(cats):all(function(cat) return item:has_category(cat) end)
   end
end

data:add {
   _type = "base.enchantment",
   _id = "modify_attribute",
   elona_id = 1,

   level = 1,
   value = 120,
   rarity = 3000,

   icon = 2,
   color = { 0, 0, 100 },

   params = { skill_id = "id:base.skill" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:555 		if enc=encModAttb{ ..
      self.params.skill_id = Skill.random_attribute()
      if params.curse_power > 0 and Rand.rnd(100) < params.curse_power then
         self.power = self.power * - 2
      end

      return true
      -- <<<<<<<< shade2/item_data.hsp:559 			} ..
   end,

   adjusted_power = function(power)
      -- >>>>>>>> shade2/item_data.hsp:208 	#define global ctype calcEncAttb(%%1)		( %%1/50 +1  ...
       return math.ceil(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:208 	#define global ctype calcEncAttb(%%1)		( %%1/50 +1  ..
   end,

   alignment = function(power)
      if power < 0 then
         return "negative"
      end
      return "positive"
   end,

   localize = function(power, params, item)
      -- >>>>>>>> shade2/item_data.hsp:351 		if val(10)=encModAttb{ ..
      local adjusted_power = math.ceil(power / 50) + 1
      local skill_name = "ability." .. params.skill_id .. ".name"
      if item:has_category("elona.food") then
         if adjusted_power < 0 then
            return I18N.get("enchantment.with_parameters.attribute.in_food.decreases", skill_name) .. " " .. Enchantment.power_text(adjusted_power)
         else
            return I18N.get("enchantment.with_parameters.attribute.in_food.increases", skill_name) .. " " .. Enchantment.power_text(adjusted_power)
         end
      else
         if adjusted_power < 0 then
            return I18N.get("enchantment.with_parameters.attribute.other.decreases", skill_name, math.abs(adjusted_power))
         else
            return I18N.get("enchantment.with_parameters.attribute.other.increases", skill_name, math.abs(adjusted_power))
         end
      end
      -- <<<<<<<< shade2/item_data.hsp:361 		} ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:454 		if rp2=encModAttb	: sdata(rp3,r1)+=calcEncAttb(i ..
      local adjusted_power = math.floor(power / 50) + 1
      chara:mod_skill_level(params.skill_id, adjusted_power, "add")
      -- <<<<<<<< shade2/calculation.hsp:454 		if rp2=encModAttb	: sdata(rp3,r1)+=calcEncAttb(i ..
   end,

   on_eat_food = function(power, enc_params, item, chara)
      -- >>>>>>>> shade2/item.hsp:1192 		if enc2=encModAttb{ ...
      local adjusted_power = math.floor(power / 50) + 1
      local exp = adjusted_power * 100
      if not chara:is_player() then
         exp = exp * 5
      end
      Skill.gain_skill_exp(chara, enc_params.skill_id, exp)
      local skill_name = "ability." .. enc_params.skill_id .. ".name"
      if exp >= 0 then
         Gui.mes_visible("food.effect.ability.develops", chara.x, chara.y, chara, skill_name)
      else
         Gui.mes_visible("food.effect.ability.deteriorates", chara.x, chara.y, chara, skill_name)
      end
      -- <<<<<<<< shade2/item.hsp:1196 		} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "modify_resistance",
   elona_id = 2,

   level = 2,
   value = 150,
   rarity = 2500,

   icon = 3,
   color = { 80, 100, 0 },

   params = { element_id = "id:base.element" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:560 		if enc=encModRes{ ..
      self.params.element_id = Skill.random_resistance_by_rarity()
      if params.curse_power > 0 and Rand.rnd(100) < params.curse_power then
         self.power = self.power * - 2
      end

      return true
      -- <<<<<<<< shade2/item_data.hsp:564 			} ..
   end,

   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:209 	#define global ctype calcEncRes(%%1)		( %%1/2 ) ...
       return math.floor(power / 2)
       -- <<<<<<<< shade2/item_data.hsp:209 	#define global ctype calcEncRes(%%1)		( %%1/2 ) ..
   end,

   alignment = function(power)
      if power < 0 then
         return "negative"
      end
      return "positive"
   end,

   localize = function(power, params, item)
      -- >>>>>>>> shade2/item_data.hsp:362 		if val(10)=encModRes{ ..
      local adjusted_power = math.floor(power / 2)
      local grade = adjusted_power / Const.RESIST_GRADE
      local element_name = "element." .. params.element_id .. ".name"
      if power < 0 then
         return I18N.get("enchantment.with_parameters.resistance.decreases", element_name) .. " " .. Enchantment.power_text(grade)
      else
         return I18N.get("enchantment.with_parameters.resistance.increases", element_name) .. " " .. Enchantment.power_text(grade)
      end
      -- <<<<<<<< shade2/item_data.hsp:372 			} ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:455 		if rp2=encModRes{ ..
      local adjusted_power = math.floor(power / 2)
      chara:mod_resist_level(params.element_id, adjusted_power, "add")
      if chara:resist_level(params.element_id) < 1 then
         chara:mod_resist_level(params.element_id, 1, "set")
      end
      -- <<<<<<<< shade2/calculation.hsp:458 			} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "modify_skill",
   elona_id = 3,

   level = 0,
   value = 120,
   rarity = 4500,

   icon = 1,
   color = { 0, 100, 0 },

   params = { skill_id = "id:base.skill" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:565 		if enc=encModSkill{ ..
      self.params.skill_id = Skill.random_skill()
      if params.curse_power > 0 and Rand.rnd(100) < params.curse_power then
         self.power = self.power * - 2
      end

      return true
      -- <<<<<<<< shade2/item_data.hsp:569 			} ..
   end,

   adjusted_power = function(power)
      -- >>>>>>>> shade2/item_data.hsp:210 	#define global ctype calcEncSkill(%%1)		( %%1/50 +1 ...
      return math.ceil(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:210 	#define global ctype calcEncSkill(%%1)		( %%1/50 +1 ..
   end,

   alignment = function(power)
      if power < 0 then
         return "negative"
      end
      return "positive"
   end,

   localize = function(power, params, item)
      -- >>>>>>>> shade2/item_data.hsp:373 		if val(10)=encModSkill{ ..
      local adjusted_power = math.ceil(power / 50)
      local grade = adjusted_power / 5
      local skill_name = "ability." .. params.skill_id .. ".name"
      if power < 0 then
         return I18N.get("enchantment.with_parameters.skill.decreases", skill_name) .. " " .. Enchantment.power_text(grade)
      else
         local s = I18N.get_optional("ability." .. params.skill_id .. ".enchantment_description")
         if s == nil then
            s = I18N.get("enchantment.with_parameters.skill.increases", skill_name)
         end
         s = s .. " " .. Enchantment.power_text(grade)
         return s
      end
      -- <<<<<<<< shade2/item_data.hsp:383 			} ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:459 		if rp2=encModSkill{ ..
      local adjusted_power = math.ceil(power / 50)
      if chara:has_skill(params.skill_id) then
         chara:mod_skill_level(params.skill_id, adjusted_power, "add")
         if chara:skill_level(params.skill_id) < 1 then
            chara:mod_skill_level(params.skill_id, 1, "set")
         end
      end
      -- <<<<<<<< shade2/calculation.hsp:463 		}else{ ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "sustain_attribute",
   elona_id = 6,

   level = 0,
   value = 120,
   rarity = 4500,

   icon = 8,
   color = { 0, 100, 100 },

   params = { skill_id = "id:base.skill" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:570 		if enc=encSustain{ ..
      self.params.skill_id = Skill.random_attribute()

      return true
      -- <<<<<<<< shade2/item_data.hsp:573 			} ..
   end,

   adjusted_power = function(power)
      -- >>>>>>>> shade2/item_data.hsp:387 			if val(3)=fltFood:s=lang(""+skillName(sId)+"の成長 ...
      return math.floor(power / 50) + 1
      -- <<<<<<<< shade2/item_data.hsp:387 			if val(3)=fltFood:s=lang(""+skillName(sId)+"の成長 ..
   end,

   alignment = "positive",

   localize = function(power, params, item)
      -- >>>>>>>> shade2/item_data.hsp:384 		if val(10)=encSustain{ ..
      local adjusted_power = math.floor(power / 50) + 1
      local skill_name = "ability." .. params.skill_id .. ".name"
      if item:has_category("elona.food") then
         local grade = adjusted_power / 5
         return I18N.get("enchantment.with_parameters.skill_maintenance.in_food", skill_name) .. " " .. Enchantment.power_text(grade)
      else
         return I18N.get("enchantment.with_parameters.skill_maintenance.other", skill_name)
      end
      -- <<<<<<<< shade2/item_data.hsp:388 			} ..
   end,

   on_eat_food = function(power, enc_params, item, chara)
      -- >>>>>>>> shade2/item.hsp:1197 		if enc2=encSustain{ ...
      local skill_name = "ability." .. enc_params.skill_id .. ".name"
      Gui.mes_visible("food.effect.sustains_growth", chara.x, chara.y, chara, skill_name)
      local adjusted_power = math.floor(power / 50) + 1

      local food_buff = Hunger.food_buff_for_stat(enc_params.skill_id)
      if food_buff then
         local buff_power = adjusted_power * 5
         if not chara:is_player() then
            buff_power = buff_power * 2
         end
         Effect.add_buff(chara, chara, food_buff, buff_power, 2000)
      else
         Log.error("Can't find a food buff for skill '%s'", enc_params.skill_id)
      end
      -- <<<<<<<< shade2/item.hsp:1201 		} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "elemental_damage",
   elona_id = 7,

   level = 1,
   value = 120,
   rarity = 300,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },

   params = { element_id = "id:base.element" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:574 		if enc=encEleDmg{ ..
      self.params.element_id = Skill.random_resistance_by_rarity()

      return true
      -- <<<<<<<< shade2/item_data.hsp:577 			} ..
   end,

   adjusted_power = function(power)
      -- >>>>>>>> shade2/item_data.hsp:209 	#define global ctype calcEncRes(%%1)		( %%1/2 ) ...
      return math.floor(power / 2)
      -- <<<<<<<< shade2/item_data.hsp:209 	#define global ctype calcEncRes(%%1)		( %%1/2 ) ..
   end,

   alignment = "positive",

   localize = function(power, params, item)
      -- >>>>>>>> shade2/item_data.hsp:362 		if val(10)=encModRes{ ..
      local adjusted_power = math.floor(power / 2)
      local grade = adjusted_power / Const.RESIST_GRADE
      local element_name = "element." .. params.element_id .. ".name"
      return I18N.get("enchantment.with_parameters.extra_damage", element_name) .. " " .. Enchantment.power_text(grade)
      -- <<<<<<<< shade2/item_data.hsp:372 			} ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1448 		if i=encEleDmg{ ..
      if params.original_damage <= 1 then
         return
      end

      if not Chara.is_alive(params.target) then
         return
      end

      local damage = Rand.rnd(params.original_damage * (100 + power) / 1000 + 1) + 5
      local dmg_params = {
         element = enc_params.element_id,
         element_power = power / 2 + 100
      }
      params.target:damage_hp(damage, chara, dmg_params)
      -- <<<<<<<< shade2/action.hsp:1453 			continue} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "invoke_skill",
   elona_id = 8,

   level = 99,
   value = 300,
   rarity = 15000,

   params = { enchantment_skill_id = "id:base.enchantment_skill" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:578 		if enc=encProc{ ..
      -- Find a list of invokable skills that can be added onto this item.
      local filter = function(enc_skill)
         if not (enc_skill.categories and #enc_skill.categories > 0) then
            return true
         end
         for _, cat in ipairs(enc_skill.categories or {}) do
            if item:has_category(cat) then
               return true
            end
         end
         return false
      end

      local cands = data["base.enchantment_skill"]:iter():filter(filter)
      if cands:length() == 0 then
         return { skip = true }
      end

      local sampler = WeightedSampler:new()
      for _, cand in cands:unwrap() do
         sampler:add(cand._id, cand.rarity)
      end

      self.params.enchantment_skill_id = sampler:sample()

      return true
      -- <<<<<<<< shade2/item_data.hsp:594 			} ..
   end,

   adjusted_power = function(power)
       return math.floor(power / 50)
   end,

   alignment = "positive",

   localize = function(power, params, item)
      -- >>>>>>>> shade2/item_data.hsp:398 		if val(10)=encProc{ ..
      local enc_skill_data = data["base.enchantment_skill"]:ensure(params.enchantment_skill_id)
      local skill_name = "ability." .. enc_skill_data.skill_id .. ".name"
      return I18N.get("enchantment.with_parameters.invokes", skill_name) .. " " .. Enchantment.power_text(power)
      -- <<<<<<<< shade2/item_data.hsp:403 			} ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> elona122/shade2/action.hsp:1454 		if i=encProc{ ..
      if not Chara.is_alive(params.target) then
         return
      end

      local enc_skill_data = data["base.enchantment_skill"]:ensure(enc_params.enchantment_skill_id)
      local target = params.target
      local target_type = enc_skill_data.target_type
      if target_type == "self_or_nearby" or target_type == "self" then
         target = chara
      end

      if Rand.rnd(100) < enc_skill_data.chance then
         local magic_params = {
            source = chara,
            target = target,
            power = power + chara:skill_level(params.attack_skill) * 10
         }
         local skill_data = data["base.skill"]:ensure(enc_skill_data.skill_id)
         Magic.cast(skill_data.effect_id, magic_params)
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1465 			continue} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "ammo",
   elona_id = 9,

   level = 1,
   value = 120,
   rarity = 50000,
   filter = filter_categories { "elona.equip_ammo" },

   -- >>>>>>>> shade2/item_data.hsp:612 		if refType@=fltAmmo:return ...
   no_merge = true,
   -- <<<<<<<< shade2/item_data.hsp:612 		if refType@=fltAmmo:return ..

   params = {
      ammo_enchantment_id = "id:base.ammo_enchantment",
      ammo_max = "number",
      ammo_current = "number"
   },
   compare = function(my_params, other_params)
      return my_params.ammo_enchantment_id == other_params.ammo_enchantment_id
   end,
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:578 		if enc=encProc{ ..
      if not item:has_category("elona.equip_ammo") then
         return { skip = true }
      end

      local cands = data["base.ammo_enchantment"]:iter():to_list()

      if #cands == 0 then
         return false
      end

      local idx = Rand.rnd(Rand.rnd(#cands) + 1) + 1

      self.params.ammo_enchantment_id = cands[idx]._id

      return true
      -- <<<<<<<< shade2/item_data.hsp:594 			} ..
   end,
   on_initialize = function(self, item, params)
      local ammo_enc_data = data["base.ammo_enchantment"]:ensure(self.params.ammo_enchantment_id)

      self.params.ammo_current = math.floor(math.clamp(self.power, 0, 500) * ammo_enc_data.ammo_factor / 500) + ammo_enc_data.ammo_amount
      self.params.ammo_max = self.params.ammo_current
   end,

   alignment = "positive",

   adjusted_power = function(power)
       return power
   end,

   localize = function(power, params, item)
      -- >>>>>>>> shade2/item_data.hsp:405 		if val(10)=encAmmo{ ..
      local ammo_name = "_.base.ammo_enchantment." .. params.ammo_enchantment_id .. ".name"
      local s = I18N.get("enchantment.with_parameters.ammo.text", ammo_name)
      s = s .. " " .. I18N.get("enchantment.with_parameters.ammo.max", params.ammo_max)
      return s
      -- <<<<<<<< shade2/item_data.hsp:409 			} ..
   end
}

---
--- Unique enchantments
---

data:add {
   _type = "base.enchantment",
   _id = "random_tele",
   elona_id = 21,

   level = -1,
   value = 50,
   rarity = 75,
   alignment = "negative",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:417 	encDisp encRandomTele		,9,0,lang("ランダムなテレポートを引き起こ ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:417 	encDisp encRandomTele		,9,0,lang("ランダムなテレポートを引き起こ ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,

   on_turns_passed = function(power, params, item, chara)
      local map = chara:current_map()
      if Map.is_world_map(map) then
         return
      end

      if Rand.rnd(25) < math.clamp(math.abs(power) / 50, 1, 25) then
         Magic.cast("elona.teleport", { source = chara, target = chara })
      end
   end
}

data:add {
   _type = "base.enchantment",
   _id = "suck_blood",
   elona_id = 22,

   level = -1,
   value = 50,
   rarity = 100,
   alignment = "negative",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:418 	encDisp encSuckBlood		,9,0,lang("使用者の生き血を吸う","suc ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:418 	encDisp encSuckBlood		,9,0,lang("使用者の生き血を吸う","suc ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,

   on_turns_passed = function(power, params, item, chara)
      if Rand.one_in(4) then
         Gui.mes_c_visible("misc.curse.blood_sucked", chara, "Purple")
         local amount = math.abs(power) / 25 + 3
         chara:apply_effect("elona.bleeding", amount)
      end
   end
}

data:add {
   _type = "base.enchantment",
   _id = "suck_exp",
   elona_id = 23,

   level = -1,
   value = 50,
   rarity = 100,
   alignment = "negative",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:419 	encDisp encSuckExp		,9,0,lang("あなたの成長を妨げる","distu ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:419 	encDisp encSuckExp		,9,0,lang("あなたの成長を妨げる","distu ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,

   on_turns_passed = function(power, params, item, chara)
      if Rand.one_in(20) then
         Gui.mes_c_visible("misc.curse.experience_reduced", chara, "Purple")
         local lost_exp = chara.required_experience / (300 - math.clamp(math.abs(power) / 2, 0, 50)) + Rand.rnd(100)
         chara.experience = math.max(chara.experience - lost_exp, 0)
      end
   end
}

data:add {
   _type = "base.enchantment",
   _id = "summon_monster",
   elona_id = 24,

   level = -1,
   value = 50,
   rarity = 50,
   alignment = "negative",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:420 	encDisp encSummonMonster	,9,0,lang("魔物を呼び寄せる","at ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:420 	encDisp encSummonMonster	,9,0,lang("魔物を呼び寄せる","at ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,

   on_turns_passed = function(power, params, item, chara)
      -- >>>>>>>> elona122/shade2/item.hsp:482 	if iEnc(cnt,ci)=encSummonMonster:if mType!mTypeWo ..
      local map = chara:current_map()
      if Map.is_world_map(map) or map:has_type("player_owned") then
         return
      end

      if Rand.rnd(50) < math.clamp(math.abs(power) / 50, 1, 50) then
         Gui.mes_c_visible("misc.curse.creature_summoned", chara, "Purple")
         for _ = 1, Rand.rnd(3) + 1 do
            local level = Calc.calc_object_level(Chara.player():calc("level") * 3 / 2 + 3, map)
            local quality = Calc.calc_object_quality(Enum.Quality.Normal)
            Charagen.create(chara.x, chara.y, { level, quality }, map)
         end
      end
      -- <<<<<<<< elona122/shade2/item.hsp:488 		} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "prevent_tele",
   elona_id = 25,

   level = 1,
   value = 150,
   rarity = 150,
   alignment = "positive",
}

data:add {
   _type = "base.enchantment",
   _id = "res_blind",
   elona_id = 26,

   level = 1,
   value = 120,
   rarity = 400,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:add_effect_immunity("elona.blindness")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_paralyze",
   elona_id = 27,

   level = 2,
   value = 120,
   rarity = 300,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:add_effect_immunity("elona.paralysis")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_confuse",
   elona_id = 28,

   level = 1,
   value = 120,
   rarity = 400,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:add_effect_immunity("elona.confusion")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_fear",
   elona_id = 29,

   level = 1,
   value = 120,
   rarity = 600,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:add_effect_immunity("elona.fear")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_sleep",
   elona_id = 30,

   level = 1,
   value = 120,
   rarity = 600,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:add_effect_immunity("elona.sleep")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_poison",
   elona_id = 31,

   level = 2,
   value = 120,
   rarity = 500,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:add_effect_immunity("elona.poison")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_steal",
   elona_id = 32,

   level = 99,
   value = 300,
   rarity = 1500,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:mod("is_protected_from_theft", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "eater",
   elona_id = 33,

   level = 99,
   value = 300,
   rarity = 2000,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:mod("is_protected_from_rotten_food", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "fast_travel",
   elona_id = 34,

   level = 3,
   value = 200,
   rarity = 25,
   filter = filter_categories { "elona.equip_leg" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:430 	encDisp encFastTravel		,4,0,lang("速度を上げ、ワールドマップでの ...
      return power / 100
      -- <<<<<<<< shade2/item_data.hsp:430 	encDisp encFastTravel		,4,0,lang("速度を上げ、ワールドマップでの ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:466 		if rp2=encFastTravel	:sSPD(r1)+=iEncP(cnt,rp)/50 ...
      chara:mod_skill_level("elona.stat_speed", power / 50 + 1, "add")
      chara:mod("travel_speed", math.floor(power / 8), "add")
      -- <<<<<<<< shade2/calculation.hsp:466 		if rp2=encFastTravel	:sSPD(r1)+=iEncP(cnt,rp)/50 ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_etherwind",
   elona_id = 35,

   level = 3,
   value = 200,
   rarity = 25,
   filter = filter_categories { "elona.equip_back" },
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:mod("is_protected_from_etherwind", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_weather",
   elona_id = 36,

   level = 2,
   value = 200,
   rarity = 40,
   filter = filter_categories { "elona.equip_ring" },
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:mod("is_protected_from_weather", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_pregnancy",
   elona_id = 37,

   level = 1,
   value = 120,
   rarity = 300,
   alignment = "positive"
}

data:add {
   _type = "base.enchantment",
   _id = "float",
   elona_id = 38,

   level = 1,
   value = 130,
   rarity = 250,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:mod("is_floating", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_mutation",
   elona_id = 39,

   level = 3,
   value = 160,
   rarity = 200,
   alignment = "positive"
}

data:add {
   _type = "base.enchantment",
   _id = "power_magic",
   elona_id = 40,

   level = 3,
   value = 170,
   rarity = 250,
   filter = filter_categories { "elona.equip_melee" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:436 	encDisp encPowerMagic		,4,0,lang("魔法の威力を高める","enc ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:436 	encDisp encPowerMagic		,4,0,lang("魔法の威力を高める","enc ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "see_invisi",
   elona_id = 41,

   level = 2,
   value = 170,
   rarity = 100,
   filter = filter_categories { "elona.equip_head", "elona.equip_ring" },
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:mod("can_see_invisible", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "absorb_stamina",
   elona_id = 42,

   level = 99,
   value = 450,
   rarity = 1000,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:438 	encDisp encAbsorbStamina 	,4,0,lang("攻撃対象からスタミナを吸 ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:438 	encDisp encAbsorbStamina 	,4,0,lang("攻撃対象からスタミナを吸 ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1400 	if enc=encAbsorbStamina{ ..
      local target = params.target
      local adjusted_power = math.floor(power / 50)
      local amount = Rand.rnd(adjusted_power + 1) + 1
      chara:heal_stamina(amount)
      target:damage_sp(amount / 2)
      -- <<<<<<<< shade2/action.hsp:1405 		} ..
   end,

   on_eat_food = function(power, enc_params, item, chara)
      -- >>>>>>>> shade2/item.hsp:1169 	if enc=encAbsorbStamina{ ...
      local heal_amount = Rand.rnd(power / 50 + 1) + 1
      chara:heal_stamina(heal_amount)
      -- <<<<<<<< shade2/item.hsp:1173 	} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "ragnarok",
   elona_id = 43,

   level = 99,
   value = 100,
   rarity = 1000,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1413 	if enc=encRagnarok{ ..
      if Rand.one_in(66) then
         local ragnarok = function()
            return DeferredEvents.ragnarok(chara)
         end
         DeferredEvent.add(ragnarok)
      end
      -- <<<<<<<< shade2/action.hsp:1416 		} ..
   end,

   on_eat_food = function(power, enc_params, item, chara)
      -- >>>>>>>> shade2/item.hsp:1179 	if enc=encRagnarok{ ...
      local ragnarok = function()
         return DeferredEvents.ragnarok(chara)
      end
      DeferredEvent.add(ragnarok)
      -- <<<<<<<< shade2/item.hsp:1182 	} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "absorb_mana",
   elona_id = 44,

   level = 99,
   value = 450,
   rarity = 1000,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:440 	encDisp encAbsorbMana		,4,0,lang("攻撃対象からマナを吸収する", ...
       return math.floor(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:440 	encDisp encAbsorbMana		,4,0,lang("攻撃対象からマナを吸収する", ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1406 	if enc=encAbsorbMana{ ..
      local target = params.target
      local adjusted_power = math.floor(power / 25)
      local amount = Rand.rnd(adjusted_power * 2 + 1) + 1
      chara:heal_mp(amount / 5)
      if Chara.is_alive(target) then
         target:damage_mp(amount)
      end
      -- <<<<<<<< shade2/action.hsp:1412 		} ..
   end,

   on_eat_food = function(power, enc_params, item, chara)
      -- >>>>>>>> shade2/item.hsp:1174 	if enc=encAbsorbMana{ ...
      local heal_amount = Rand.rnd(power / 25 + 1) + 1
      chara:heal_mp(heal_amount/5)
      -- <<<<<<<< shade2/item.hsp:1178 	} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "pierce",
   elona_id = 45,

   level = 99,
   value = 500,
   rarity = 500,
   filter = filter_categories { "elona.equip_melee", "elona.equip_wrist" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:441 	encDisp encVopal		,4,0,lang("完全貫通攻撃発動の機会を増やす","gi ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:441 	encDisp encVopal		,4,0,lang("完全貫通攻撃発動の機会を増やす","gi ..
   end,

   on_refresh = function(power, params, item, chara)
      chara:mod("pierce_rate", math.floor(power / 50), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "crit",
   elona_id = 46,

   level = 99,
   value = 300,
   rarity = 10000,
   filter = filter_categories { "elona.equip_melee" },"elona.equip_neck",
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:442 	encDisp encCrit			,4,0,lang("クリティカルヒットの機会を増やす","i ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:442 	encDisp encCrit			,4,0,lang("クリティカルヒットの機会を増やす","i ..
   end,

   on_refresh = function(power, params, item, chara)
      chara:mod("critical_rate", math.floor(power / 50), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "extra_melee",
   elona_id = 47,

   level = 3,
   value = 180,
   rarity = 150,
   filter = filter_categories { "elona.equip_ring", "elona.equip_neck" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:443 	encDisp encExtraMelee		,4,0,lang("追加打撃の機会を増やす","i ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:443 	encDisp encExtraMelee		,4,0,lang("追加打撃の機会を増やす","i ..
   end,

   on_refresh = function(power, params, item, chara)
      chara:mod("extra_melee_attack_rate", math.floor(power / 15), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "extra_shoot",
   elona_id = 48,

   level = 3,
   value = 180,
   rarity = 150,
   filter = filter_categories { "elona.equip_ring", "elona.equip_neck" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:444 	encDisp encExtraShoot		,4,0,lang("追加射撃の機会を増やす","i ...
       return math.floor(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:444 	encDisp encExtraShoot		,4,0,lang("追加射撃の機会を増やす","i ..
   end,

   on_refresh = function(power, params, item, chara)
      chara:mod("extra_ranged_attack_rate", math.floor(power / 15), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "stop_time",
   elona_id = 49,

   level = 99,
   value = 550,
   rarity = 500,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:445 	encDisp encStopTime		,4,0,lang("稀に時を止める","occasio ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:445 	encDisp encStopTime		,4,0,lang("稀に時を止める","occasio ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1417 	if enc=encStopTime:if gTimeStopTime=0{ ..
      if Rand.one_in(25) then
         Gui.mes_c("action.time_stop.begins", "SkyBlue", chara)
         Effect.stop_time(chara, (power / 100) + 1)
      end
      -- <<<<<<<< shade2/action.hsp:1423 		} ..
   end,

   on_eat_food = function(power, enc_params, item, chara)
      -- >>>>>>>> shade2/item.hsp:1183 	if enc=encStopTime:if gTimeStopTime=0{ ...
      Gui.mes_c("action.time_stop.begins", "SkyBlue", chara)
      Effect.stop_time(chara, (power / 100) + 1)
      -- <<<<<<<< shade2/item.hsp:1187 	} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_curse",
   elona_id = 50,

   level = 99,
   value = 150,
   rarity = 2000,
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:446 	encDisp encResCurse		,4,0,lang("呪いの言葉から保護する","pro ...
       return math.floor(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:446 	encDisp encResCurse		,4,0,lang("呪いの言葉から保護する","pro ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "strad",
   elona_id = 51,

   level = 100,
   value = 120,
   rarity = 300,
   filter = filter_categories { "elona.furniture" },
   alignment = "positive",
}

data:add {
   _type = "base.enchantment",
   _id = "damage_resistance",
   elona_id = 52,

   level = 1,
   value = 140,
   rarity = 750,
   filter = filter_categories { "elona.equip_shield" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:448 	encDisp encResDamage		,4,0,lang("被る物理ダメージを軽減する"," ...
       return math.floor(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:448 	encDisp encResDamage		,4,0,lang("被る物理ダメージを軽減する"," ..
   end,

   on_refresh = function(power, params, item, chara)
      chara:mod("damage_resistance", math.floor(power / 40 + 5), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "damage_immunity",
   elona_id = 53,

   level = 2,
   value = 160,
   rarity = 500,
   filter = filter_categories { "elona.equip_shield" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:449 	encDisp encImmuneDamage		,4,0,lang("被るダメージを稀に無効にす ...
       return math.floor(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:449 	encDisp encImmuneDamage		,4,0,lang("被るダメージを稀に無効にす ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:479 		if rp2=encImmuneDamage	:cImmuneDamage(r1)+	=iEnc ...
      chara:mod("damage_immunity_rate", math.floor(power / 60 + 3), "add")
      -- <<<<<<<< shade2/calculation.hsp:479 		if rp2=encImmuneDamage	:cImmuneDamage(r1)+	=iEnc ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "damage_reflection",
   elona_id = 54,

   level = 3,
   value = 180,
   rarity = 250,
   filter = filter_categories { "elona.equip_shield", "elona.equip_body" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:450 	encDisp encReflectDamage	,4,0,lang("攻撃された時、相手に切り傷 ...
       return math.floor(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:450 	encDisp encReflectDamage	,4,0,lang("攻撃された時、相手に切り傷 ..
   end,

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:480 		if rp2=encReflectDamage	:cReflectDamage(r1)+	=iE ...
      chara:mod("damage_reflection", math.floor(power / 5), "add")
      -- <<<<<<<< shade2/calculation.hsp:480 		if rp2=encReflectDamage	:cReflectDamage(r1)+	=iE ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "cure_bleeding",
   elona_id = 55,

   level = 3,
   value = 130,
   rarity = 40,
   filter = filter_categories { "elona.equip_cloak", "elona.equip_neck" },
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:478 		if rp2=encResDamage	:cResDamage(r1)+	=iEncP(cnt, ...
      chara:mod("is_resistant_to_bleeding", true)
      -- <<<<<<<< shade2/calculation.hsp:478 		if rp2=encResDamage	:cResDamage(r1)+	=iEncP(cnt, ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "god_talk",
   elona_id = 56,

   level = 0,
   value = 200,
   rarity = 30,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:464 		if rp2=encGodTalk	:if r1=pc:gGodTalk=true				:co ...
      chara:mod("can_catch_god_signals", true)
      -- <<<<<<<< shade2/calculation.hsp:464 		if rp2=encGodTalk	:if r1=pc:gGodTalk=true				:co ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "dragon_bane",
   elona_id = 57,

   level = 2,
   value = 170,
   rarity = 200,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:453 	encDisp encDragonBane		,4,0,lang("竜族に対して強力な威力を発揮す ...
       return math.floor(power / 50)
       -- <<<<<<<< shade2/item_data.hsp:453 	encDisp encDragonBane		,4,0,lang("竜族に対して強力な威力を発揮す ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1424 	if enc=encDragonBane{ ..
      local target = params.target
      if target:has_tag("dragon") then
         local damage = params.original_damage
         target:damage_hp(damage / 2, chara, { tense = "enemy" })
      end
      -- <<<<<<<< shade2/action.hsp:1430 	} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "undead_bane",
   elona_id = 58,

   level = 2,
   value = 170,
   rarity = 200,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:454 	encDisp encUndeadBane		,4,0,lang("不死者に対して強力な威力を発揮 ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:454 	encDisp encUndeadBane		,4,0,lang("不死者に対して強力な威力を発揮 ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1438 	if enc=encUndeadBane{ ..
      local target = params.target
      if target:has_tag("undead") then
         local damage = params.original_damage
         target:damage_hp(damage / 2, chara, { tense = "enemy" })
      end
      -- <<<<<<<< shade2/action.hsp:1444 	} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "god_detect",
   elona_id = 59,

   level = 0,
   value = 200,
   rarity = 30,
   alignment = "positive",

   on_refresh = function(power, params, item, chara)
      chara:mod("can_detect_religion", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "gould",
   elona_id = 60,

   level = 100,
   value = 120,
   rarity = 300,
   filter = filter_categories { "elona.furniture" },
   alignment = "positive",
}

data:add {
   _type = "base.enchantment",
   _id = "god_bane",
   elona_id = 61,

   level = 2,
   value = 170,
   rarity = 150,
   filter = filter_categories { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(power, params)
      -- >>>>>>>> shade2/item_data.hsp:457 	encDisp encGodBane		,4,0,lang("神に対して強力な威力を発揮する"," ...
      return math.floor(power / 50)
      -- <<<<<<<< shade2/item_data.hsp:457 	encDisp encGodBane		,4,0,lang("神に対して強力な威力を発揮する"," ..
   end,

   on_attack_hit = function(power, enc_params, chara, params)
      -- >>>>>>>> shade2/action.hsp:1431 	if enc=encGodBane{ ..
      local target = params.target
      if target:has_tag("god") then
         local damage = params.original_damage
         target:damage_hp(damage / 2, chara, { tense = "enemy" })
      end
      -- <<<<<<<< shade2/action.hsp:1437 	} ..
   end
}
