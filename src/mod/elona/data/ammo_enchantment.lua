local Skill = require("mod.elona_sys.api.Skill")
local Magic = require("mod.elona_sys.api.Magic")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Action = require("api.Action")
local Gui = require("api.Gui")
local ElonaAction = require("mod.elona.api.ElonaAction")

data:add {
   _type = "base.ammo_enchantment",
   _id = "rapid",

   ammo_amount = 30,
   ammo_factor = 70,
   stamina_cost = 1,

   on_ranged_attack = function(chara, weapon, target, skill, ammo, ammo_enchantment_id)
      -- >>>>>>>> elona122/shade2/action.hsp:1164 	if ammoProc=encAmmoRapid{ ..
      for _ = 1, 3 do
         ElonaAction.physical_attack(chara, weapon, target, skill, 0, 0, true, ammo, ammo_enchantment_id)

         if not Chara.is_alive(target) then
            target = Action.find_target(chara)

            if not target then
               return
            end
         end
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1170 	}else{ ..
   end,

   on_calc_damage = function(ammo, params)
      -- >>>>>>>> elona122/shade2/calculation.hsp:326 		if ammoProc=encAmmoRapid : damage/=2 ..
      return {
         damage = params.damage / 2
      }
      -- <<<<<<<< elona122/shade2/calculation.hsp:326 		if ammoProc=encAmmoRapid : damage/=2 ..
   end
}

data:add {
   _type = "base.ammo_enchantment",
   _id = "bomb",

   ammo_amount = 5,
   ammo_factor = 15,
   stamina_cost = 10,

   on_ranged_attack = function(chara, weapon, target, skill, ammo, ammo_enchantment_id)
      local params = {
         source = chara,
         target = target,
         power = chara:skill_level(skill) * 8 + 10,
         x = target.x,
         y = target.y
      }
      Magic.cast("elona.magic_storm", params)
   end
}

data:add {
   _type = "base.ammo_enchantment",
   _id = "magic",

   ammo_amount = 20,
   ammo_factor = 35,
   stamina_cost = 2,

   on_attack_hit = function(chara, params)
      -- >>>>>>>> elona122/shade2/action.hsp:1476 	if ammoProc=encAmmoMagic{ ..
      local target = params.target
      if Chara.is_alive(target) then
         local dmg_params = {
            element = Skill.random_resistance(),
            element_power = chara:skill_level(params.attack_skill) * 10 + 100,
            tense = "enemy"
         }
         target:damage_hp(params.original_damage * 2 / 3, chara, dmg_params)
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1478 	} ..
   end,

   on_calc_damage = function(ammo, params)
      -- >>>>>>>> elona122/shade2/calculation.hsp:328 		if ammoProc=encAmmoMagic : damage/=10 ..
      return {
         damage = params.damage / 10
      }
      -- <<<<<<<< elona122/shade2/calculation.hsp:328 		if ammoProc=encAmmoMagic : damage/=10 ..
   end
}

data:add {
   _type = "base.ammo_enchantment",
   _id = "vopal",

   ammo_amount = 15,
   ammo_factor = 30,
   stamina_cost = 2,

   on_calc_damage = function(ammo, params)
      -- >>>>>>>> elona122/shade2/calculation.hsp:325 		if ammoProc=encAmmoVopal : pierce=60 		:if sync( ..
      if params.chara:is_in_fov() then
         Gui.mes_c("damage.vorpal.ranged", "Yellow")
      end
      return {
         pierce = 60
      }
      -- <<<<<<<< elona122/shade2/calculation.hsp:325 		if ammoProc=encAmmoVopal : pierce=60 		:if sync( ..
   end
}

data:add {
   _type = "base.ammo_enchantment",
   _id = "time",

   ammo_amount = 2,
   ammo_factor = 5,
   stamina_cost = 25,

   on_attack_hit = function(chara, params)
      -- >>>>>>>> elona122/shade2/action.hsp:1471 	if ammoProc=encAmmoTime{ ..
      Gui.mes_c("action.time_stop.begins", "SkyBlue", chara)
      -- TODO time stop
      Gui.mes("TODO")
      -- <<<<<<<< elona122/shade2/action.hsp:1474 	} ..
   end
}

data:add {
   _type = "base.ammo_enchantment",
   _id = "burst",

   ammo_amount = 2,
   ammo_factor = 5,
   stamina_cost = 15,

   on_ranged_attack = function(chara, weapon, target, skill, ammo, ammo_enchantment_id)
      -- >>>>>>>> elona122/shade2/action.hsp:1171 		if ammoProc=encAmmoBurst{ ..
      local i = 1
      local max = 10
      while i < max do
         local consider = true
         local targets = Action.build_target_list(chara)
         if #targets == 0 then
            return
         end

         local target = Rand.choice(targets)
         if chara:is_player() or chara:reaction_towards(Chara.player()) >= 0 then
            if target:reaction_towards(Chara.player()) >= 0 and i > 1 then
               consider = false
               if Rand.one_in(5) then
                  max = max + 1
               end
            end
         else
            if target:reaction_towards(Chara.player()) < 0 then
               consider = false
               if Rand.one_in(5) then
                  max = max + 1
               end
            end
         end

         if consider then
            ElonaAction.physical_attack(chara, weapon, target, skill, 0, 0, true, ammo, ammo_enchantment_id)
         end

         i = i + 1
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1184 		}else{ ..
   end,

   on_calc_damage = function(ammo, params)
      -- >>>>>>>> elona122/shade2/calculation.hsp:327 		if ammoProc=encAmmoBurst : damage/=3 ..
      return {
         damage = params.damage / 3
      }
      -- <<<<<<<< elona122/shade2/calculation.hsp:327 		if ammoProc=encAmmoBurst : damage/=3 ..
   end
}
