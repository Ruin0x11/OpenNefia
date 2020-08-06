local Anim = require("mod.elona_sys.api.Anim")
local Input = require("api.Input")
local Enchantment = require("mod.elona.api.Enchantment")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local WeightedSampler = require("mod.tools.api.WeightedSampler")
local I18N = require("api.I18N")
local Const = require("api.Const")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")

-- see:
-- shade2/item_data.hsp:260 	encRef(0,encRandomTele)		=-1,50	,75	,0		 ..
-- shade2/item_data.hsp:313 	encProcRef(0,0)	=spWeakEle,tgEnemy,1000	,fltWea ..
-- shade2/item_data.hsp:415 ;	encDisp encModHP		:s=lang("ＨＰを上昇させる", "increases  ..

---
--- Parameterized enchantments
---

data:add {
   _type = "base.enchantment",
   _id = "modify_attribute",
   elona_id = 1,

   level = 1,
   value = 120,
   rarity = 3000,

   params = { skill_id = "id:base.skill" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:555 		if enc=encModAttb{ ..
      self.params.skill_id = Skill.random_stat()
      if params.curse_power > 0 and Rand.rnd(100) < params.curse_power then
         self.power = self.power * - 2
      end
      -- <<<<<<<< shade2/item_data.hsp:559 			} ..
   end,

   adjusted_power = function(self)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:454 		if rp2=encModAttb	: sdata(rp3,r1)+=calcEncAttb(i ..
      chara:mod_skill_level(self.params.skill_id, self:adjusted_power(), "add")
      -- <<<<<<<< shade2/calculation.hsp:454 		if rp2=encModAttb	: sdata(rp3,r1)+=calcEncAttb(i ..
   end,

   alignment = function(self)
      if self:adjusted_power() < 0 then
         return "negative"
      end
      return "positive"
   end,

   localize = function(self, item)
      -- >>>>>>>> shade2/item_data.hsp:351 		if val(10)=encModAttb{ ..
      local power = self:adjusted_power()
      local skill_name = "ability." .. self.params.skill_id .. ".name"
      if item:has_category("elona.food") then
         if power < 0 then
            return I18N.get("enchantment.with_parameters.attribute.in_food.decreases", skill_name) .. " " .. Enchantment.power_text(power)
         else
            return I18N.get("enchantment.with_parameters.attribute.in_food.increases", skill_name) .. " " .. Enchantment.power_text(power)
         end
      else
         if power < 0 then
            return I18N.get("enchantment.with_parameters.attribute.other.decreases", skill_name, math.abs(power))
         else
            return I18N.get("enchantment.with_parameters.attribute.other.increases", skill_name, math.abs(power))
         end
      end
      -- <<<<<<<< shade2/item_data.hsp:361 		} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "modify_resistance",
   elona_id = 2,

   level = 2,
   value = 150,
   rarity = 2500,

   params = { element_id = "id:base.element" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:560 		if enc=encModRes{ ..
      self.params.element_id = Skill.random_resistance_by_rarity()
      if params.curse_power > 0 and Rand.rnd(100) < params.curse_power then
         self.power = self.power * - 2
      end
      -- <<<<<<<< shade2/item_data.hsp:564 			} ..
   end,

   on_refresh = function(self, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:455 		if rp2=encModRes{ ..
      chara:mod_resist_level(self.params.element_id, self:adjusted_power(), "add")
      if chara:resist_level(self.params.element_id) < 1 then
         chara:mod_resist_level(self.params.element_id, 1, "set")
      end
      -- <<<<<<<< shade2/calculation.hsp:458 			} ..
   end,

   adjusted_power = function(self)
       return math.floor(self.power / 2)
   end,

   alignment = function(self)
      if self:adjusted_power() < 0 then
         return "negative"
      end
      return "positive"
   end,

   localize = function(self, item)
      -- >>>>>>>> shade2/item_data.hsp:362 		if val(10)=encModRes{ ..
      local power = self:adjusted_power()
      local grade = power / Const.RESIST_GRADE
      local element_name = "element." .. self.params.element_id .. ".name"
      if power < 0 then
         return I18N.get("enchantment.with_parameters.resistance.decreases", element_name) .. " " .. Enchantment.power_text(grade)
      else
         return I18N.get("enchantment.with_parameters.resistance.increases", element_name) .. " " .. Enchantment.power_text(grade)
      end
      -- <<<<<<<< shade2/item_data.hsp:372 			} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "modify_skill",
   elona_id = 3,

   level = 0,
   value = 120,
   rarity = 4500,

   params = { element_id = "id:base.skill" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:565 		if enc=encModSkill{ ..
      self.params.element_id = Skill.random_skill()
      if params.curse_power > 0 and Rand.rnd(100) < params.curse_power then
         self.power = self.power * - 2
      end
      -- <<<<<<<< shade2/item_data.hsp:569 			} ..
   end,

   on_refresh = function(self, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:459 		if rp2=encModSkill{ ..
      if chara:has_skill(self.params.skill_id) then
         chara:mod_skill_level(self.params.skill_id, self:adjusted_power(), "add")
         if chara:skill_level(self.params.skill_id) < 1 then
            chara:mod_skill_level(self.params.skill_id, 1, "set")
         end
      end
      -- <<<<<<<< shade2/calculation.hsp:463 		}else{ ..
   end,

   adjusted_power = function(self)
       return math.floor(self.power / 50)
   end,

   alignment = function(self)
      if self:adjusted_power() < 0 then
         return "negative"
      end
      return "positive"
   end,

   localize = function(self, item)
      -- >>>>>>>> shade2/item_data.hsp:373 		if val(10)=encModSkill{ ..
      local power = self:adjusted_power()
      local grade = power / 5
      local skill_name = "ability." .. self.params.skill_id .. ".name"
      if power < 0 then
         return I18N.get("enchantment.with_parameters.skill.decreases", skill_name) .. " " .. Enchantment.power_text(grade)
      else
         local s = I18N.get_optional("ability." .. self.params.skill_id .. ".enchantment_description")
         if s == nil then
            s = I18N.get("enchantment.with_parameters.skill.increases", skill_name)
         end
         s = s .. " " .. Enchantment.power_text(grade)
         return s
      end
      -- <<<<<<<< shade2/item_data.hsp:383 			} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "sustain_attribute",
   elona_id = 6,

   level = 0,
   value = 120,
   rarity = 4500,

   params = { skill_id = "id:base.skill" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:570 		if enc=encSustain{ ..
      self.params.skill_id = Skill.random_stat()
      -- <<<<<<<< shade2/item_data.hsp:573 			} ..
   end,

   adjusted_power = function(self)
       return math.floor(self.power / 50)
   end,

   alignment = 8,

   localize = function(self, item)
      -- >>>>>>>> shade2/item_data.hsp:384 		if val(10)=encSustain{ ..
      local power = self:adjusted_power()
      local skill_name = "ability." .. self.params.skill_id .. ".name"
      if item:has_category("elona.food") then
         local grade = power / 5
         return I18N.get("enchantment.with_parameters.skill_maintenance.in_food", skill_name) .. " " .. Enchantment.power_text(grade)
      else
         return I18N.get("enchantment.with_parameters.skill_maintenance.other", skill_name)
      end
      -- <<<<<<<< shade2/item_data.hsp:388 			} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "elemental_damage",
   elona_id = 7,

   level = 1,
   value = 120,
   rarity = 300,
   categories = { "elona.equip_melee", "elona.equip_ranged" },

   params = { element_id = "id:base.element" },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:574 		if enc=encEleDmg{ ..
      self.params.element_id = Skill.random_resistance_by_rarity()
      -- <<<<<<<< shade2/item_data.hsp:577 			} ..
   end,

   adjusted_power = function(self)
       return math.floor(self.power / 2)
   end,

   alignment = "positive",

   localize = function(self, item)
      -- >>>>>>>> shade2/item_data.hsp:362 		if val(10)=encModRes{ ..
      local power = self:adjusted_power()
      local grade = power / Const.RESIST_GRADE
      local element_name = "element." .. self.params.element_id .. ".name"
      return I18N.get("enchantment.with_parameters.extra_damage", element_name) .. " " .. Enchantment.power_text(grade)
      -- <<<<<<<< shade2/item_data.hsp:372 			} ..
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
      -- <<<<<<<< shade2/item_data.hsp:594 			} ..
   end,

   adjusted_power = function(self)
       return math.floor(self.power / 50)
   end,

   alignment = "positive",

   localize = function(self, item)
      -- >>>>>>>> shade2/item_data.hsp:398 		if val(10)=encProc{ ..
      local power = self:adjusted_power()
      local enc_skill_data = data["base.enchantment_skill"]:ensure(self.params.enchantment_skill_id)
      local skill_name = "skill." .. enc_skill_data.skill_id .. ".name"
      return I18N.get("enchantment.with_parameters.invokes", skill_name) .. " " .. Enchantment.power_text(power)
      -- <<<<<<<< shade2/item_data.hsp:403 			} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "ammo",
   elona_id = 9,

   level = 1,
   value = 120,
   rarity = 50000,
   categories = { "elona.equip_ammo" },

   params = {
      ammo_enchantment_id = "id:base.ammo_enchantment",
      ammo_max = "number",
      ammo_current = "number"
   },
   on_generate = function(self, item, params)
      -- >>>>>>>> shade2/item_data.hsp:578 		if enc=encProc{ ..
      if not item:has_category("elona.equip_ammo") then
         return { skip = true }
      end

      local cands = data["base.ammo_enchantment"]:iter():to_list()

      if #cands == 0 then
         return { skip = true }
      end

      local idx = Rand.rnd(Rand.rnd(#cands) + 1) + 1

      self.params.ammo_enchantment_id = cands[idx]
      local ammo_enc_data = data["base.ammo_enchantment"]:ensure(self.params.ammo_enchantment_id)

      self.ammo_current = math.floor(math.clamp(self.power, 0, 500) * ammo_enc_data.ammo_factor / 500) + ammo_enc_data.ammo_amount
      self.ammo_max = self.ammo_current
      -- <<<<<<<< shade2/item_data.hsp:594 			} ..
   end,

   alignment = "positive",

   adjusted_power = function(self)
       return self.power
   end,

   localize = function(self, item)
      -- >>>>>>>> shade2/item_data.hsp:405 		if val(10)=encAmmo{ ..
      local ammo_name = "_.ammo_enchantment." .. self.params.ammo_enchantment_id .. ".name"
      local s = I18N.get("enchantment.with_parameters.ammo.text", ammo_name)
      s = s .. I18N.get("enchantment.with_parameters.ammo.max", self.params.ammo_max)
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
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,
}

data:add {
   _type = "base.enchantment",
   _id = "suck_blood",
   elona_id = 22,

   level = -1,
   value = 50,
   rarity = 100,
   alignment = "negative",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,
}

data:add {
   _type = "base.enchantment",
   _id = "suck_exp",
   elona_id = 23,

   level = -1,
   value = 50,
   rarity = 100,
   alignment = "negative",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,
}

data:add {
   _type = "base.enchantment",
   _id = "summon_monster",
   elona_id = 24,

   level = -1,
   value = 50,
   rarity = 50,
   alignment = "negative",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      -- >>>>>>>> shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
      chara:mod("has_cursed_enchantment", true)
      -- <<<<<<<< shade2/calculation.hsp:485 		if (rp2=encRandomTele)or(rp2=encSuckBlood)or(rp2 ..
   end,
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

   on_refresh = function(self, item, chara)
      chara.temp["effect_immunities"]["elona.blindness"] = true
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

   on_refresh = function(self, item, chara)
      chara.temp["effect_immunities"]["elona.paralysis"] = true
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

   on_refresh = function(self, item, chara)
      chara.temp["effect_immunities"]["elona.confusion"] = true
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

   on_refresh = function(self, item, chara)
      chara.temp["effect_immunities"]["elona.fear"] = true
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

   on_refresh = function(self, item, chara)
      chara.temp["effect_immunities"]["elona.sleep"] = true
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

   on_refresh = function(self, item, chara)
      chara.temp["effect_immunities"]["elona.poison"] = true
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

   on_refresh = function(self, item, chara)
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

   on_refresh = function(self, item, chara)
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
   categories = { "elona.equip_leg" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
      return self.power / 100
   end,

   on_refresh = function(self, item, chara)
      chara:mod_skill_level("elona.stat_speed", self:adjusted_power() * 2, "add")
      chara:mod("travel_speed", math.floor(self.power / 8), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "res_ether_wind",
   elona_id = 35,

   level = 3,
   value = 200,
   rarity = 25,
   categories = { "elona.equip_back" },
   alignment = "positive",

   on_refresh = function(self, item, chara)
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
   categories = { "elona.equip_ring" },
   alignment = "positive",

   on_refresh = function(self, item, chara)
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

   on_refresh = function(self, item, chara)
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
   categories = { "elona.equip_melee" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "see_invisi",
   elona_id = 41,

   level = 2,
   value = 170,
   rarity = 100,
   categories = { "elona.equip_head", "elona.equip_ring" },
   alignment = "positive",

   on_refresh = function(self, item, chara)
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
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_attack = function (self, params)
      -- >>>>>>>> shade2/action.hsp:1400 	if enc=encAbsorbStamina{ ..
      local attacker = params.attacker
      local target = params.target
      local amount = Rand.rnd(self:adjusted_power() + 1) + 1
      attacker:heal_stamina(amount)
      target:damage_stamina(amount / 2)
      -- <<<<<<<< shade2/action.hsp:1405 		} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "ragnarok",
   elona_id = 43,

   level = 99,
   value = 100,
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",

   on_attack = function (self, params)
      -- >>>>>>>> shade2/action.hsp:1413 	if enc=encRagnarok{ ..
      local attacker = params.attacker
      local ragnarok = function()
         -- TODO weather
         Gui.mes("event.ragnarok")
         Input.query_more()
         local cb = Anim.ragnarok()
         Gui.start_draw_callback(cb)

         local map = attacker:current_map()

         for _ = 1, 200 do
            for _ = 1, 2 do
               local x = Rand.rnd(map:width())
               local y = Rand.rnd(map:height())
               map:set_tile(x, y, "elona.destroyed")
            end

            -- TODO
            local sx, sy, ox, oy = Draw.get_coords():get_start_offset(x, y, Draw.get_width(), Draw.get_height())
            local tx, ty, tdx, tdy = Draw.get_coords():find_bounds(x, y, self.width, self.height)
         end
      end
      DeferredEvent.add(ragnarok)
      -- <<<<<<<< shade2/action.hsp:1416 		} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "absorb_mana",
   elona_id = 44,

   level = 99,
   value = 450,
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_attack = function (self, params)
      -- >>>>>>>> shade2/action.hsp:1406 	if enc=encAbsorbMana{ ..
      local attacker = params.attacker
      local target = params.target
      local amount = Rand.rnd(self:adjusted_power() * 2 + 1) + 1
      attacker:heal_mp(amount / 5)
      if Chara.is_alive(target) then
         target:damage_mp(amount)
      end
      -- <<<<<<<< shade2/action.hsp:1412 		} ..
   end
}

data:add {
   _type = "base.enchantment",
   _id = "vopal",
   elona_id = 45,

   level = 99,
   value = 500,
   rarity = 500,
   categories = { "elona.equip_melee", "elona.equip_wrist" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      chara:mod("vorpal_rate", self:power(), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "crit",
   elona_id = 46,

   level = 99,
   value = 300,
   rarity = 10000,
   categories = { "elona.equip_melee" },"elona.equip_neck",
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      chara:mod("critical_rate", self:power(), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "extra_melee",
   elona_id = 47,

   level = 3,
   value = 180,
   rarity = 150,
   categories = { "elona.equip_ring", "elona.equip_neck" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      chara:mod("extra_melee_attacks", self:power(), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "extra_shoot",
   elona_id = 48,

   level = 3,
   value = 180,
   rarity = 150,
   categories = { "elona.equip_ring", "elona.equip_neck" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      chara:mod("extra_ranged_attacks", self:power(), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "stop_time",
   elona_id = 49,

   level = 99,
   value = 550,
   rarity = 500,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
      return self.power
   end,

   on_attack = function (self, params)
      -- >>>>>>>> shade2/action.hsp:1417 	if enc=encStopTime:if gTimeStopTime=0{ ..
      if Rand.one_in(25) then
         Gui.mes_c("action.time_stop.begins", "SkyBlue", params.attacker)
         Gui.mes("TODO")
      end
      -- <<<<<<<< shade2/action.hsp:1423 		} ..
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
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "strad",
   elona_id = 51,

   level = 100,
   value = 120,
   rarity = 300,
   categories = { "elona.furniture" },
   alignment = "positive",
}

data:add {
   _type = "base.enchantment",
   _id = "res_damage",
   elona_id = 52,

   level = 1,
   value = 140,
   rarity = 750,
   categories = { "elona.equip_shield" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_refresh = function(self, item, chara)
      chara:mod("damage_resistance", self:power(), "add")
   end
}

data:add {
   _type = "base.enchantment",
   _id = "immune_damage",
   elona_id = 53,

   level = 2,
   value = 160,
   rarity = 500,
   categories = { "elona.equip_shield" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "reflect_damage",
   elona_id = 54,

   level = 3,
   value = 180,
   rarity = 250,
   categories = { "elona.equip_shield", "elona.equip_body" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "cure_bleeding",
   elona_id = 55,

   level = 3,
   value = 130,
   rarity = 40,
   categories = { "elona.equip_cloak", "elona.equip_neck" },
   alignment = "positive",

   on_refresh = function(self, item, chara)
      chara:mod("is_resistant_to_bleeding", true)
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

   on_refresh = function(self, item, chara)
      chara:mod("can_catch_god_signals", true)
   end
}

data:add {
   _type = "base.enchantment",
   _id = "dragon_bane",
   elona_id = 57,

   level = 2,
   value = 170,
   rarity = 200,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_attack = function (self, params)
      -- >>>>>>>> shade2/action.hsp:1424 	if enc=encDragonBane{ ..
      local target = params.target
      if target:has_tag("dragon") then
         local damage = params.original_damage
         target:damage_hp(damage / 2, params.attacker, { tense = "ally" })
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
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_attack = function (self, params)
      -- >>>>>>>> shade2/action.hsp:1438 	if enc=encUndeadBane{ ..
      local target = params.target
      if target:has_tag("undead") then
         local damage = params.original_damage
         target:damage_hp(damage / 2, params.attacker, { tense = "ally" })
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

   on_refresh = function(self, item, chara)
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
   categories = { "elona.furniture" },
   alignment = "positive",
}

data:add {
   _type = "base.enchantment",
   _id = "god_bane",
   elona_id = 61,

   level = 2,
   value = 170,
   rarity = 150,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   alignment = "positive",
   adjusted_power = function(self, item, wearer)
       return math.floor(self.power / 50)
   end,

   on_attack = function (self, params)
      -- >>>>>>>> shade2/action.hsp:1431 	if enc=encGodBane{ ..
      local target = params.target
      if target:has_tag("god") then
         local damage = params.original_damage
         target:damage_hp(damage / 2, params.attacker, { tense = "ally" })
      end
      -- <<<<<<<< shade2/action.hsp:1437 	} ..
   end
}
