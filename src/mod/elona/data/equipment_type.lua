local LootDrops = require("mod.elona.api.LootDrops")
local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Enum = require("api.Enum")

local function loot(chara, drops, chance, category)
   local map = chara:current_map()
   local filter = LootDrops.make_loot(chance, category, chara, map)
   if filter then
      drops[#drops+1] = { filter = filter }
   end
end

local function random_light_weapon()
   -- >>>>>>>> shade2/chara.hsp:24 #defcfunc eqWeaponLight ...
   if Rand.one_in(2) then
      return "elona.equip_melee_short_sword"
   end
   if Rand.one_in(2) then
      return "elona.equip_melee_hand_axe"
   end
   return "elona.equip_melee_club"
   -- <<<<<<<< shade2/chara.hsp:27 	return fltClub ..
end

local function random_heavy_weapon()
   -- >>>>>>>> shade2/chara.hsp:29 #defcfunc eqWeaponHeavy ...
   if Rand.one_in(3) then
      return "elona.equip_melee_broadsword"
   end
   if Rand.one_in(3) then
      return "elona.equip_melee_axe"
   end
   if Rand.one_in(3) then
      return "elona.equip_melee_halberd"
   end
   return "elona.equip_melee_hammer"
   -- <<<<<<<< shade2/chara.hsp:33 	return fltHammer ..
end

local function random_mage_weapon()
   -- >>>>>>>> shade2/chara.hsp:35 #module ...
   if Rand.one_in(2) then
      return "elona.equip_melee_short_sword"
   end
   return "elona.equip_melee_staff"
   -- <<<<<<<< shade2/chara.hsp:41 #global ..
end

local function add_equip(equip_spec, kind, category, quality)
   data["base.item_type"]:ensure(category)
   local spec = { category = category, quality = quality }
   equip_spec[kind] = spec
   return spec
end

data:add {
   _type = "base.equipment_type",
   _id = "warrior",
   elona_id = 1,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:64 	if cEquipment=eqWarrior{ ...
      Effect.generate_money(chara)

      add_equip(equip_spec, "elona.primary_weapon", random_heavy_weapon(), Enum.Quality.Normal)
      add_equip(equip_spec, "elona.shield", "elona.equip_shield_shield", Enum.Quality.Bad)
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.armor", "elona.equip_body_mail", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.helmet", "elona.equip_head", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.boots", "elona.equip_leg_heavy_boots", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.girdle", "elona.equip_back_girdle", Enum.Quality.Bad)
      end
      add_equip(equip_spec, "elona.ranged_weapon", "elona.equip_ranged_thrown", Enum.Quality.Bad)
      -- <<<<<<<< shade2/chara.hsp:73 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:208 	case eqWarrior ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:210 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "mage",
   elona_id = 2,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:121 	if cEquipment=eqMage{ ...
      Effect.generate_money(chara)

      add_equip(equip_spec, "elona.primary_weapon", random_mage_weapon(), Enum.Quality.Normal)
      add_equip(equip_spec, "elona.amulet_1", "elona.equip_neck_armor", Enum.Quality.Bad)
      add_equip(equip_spec, "elona.ring_1", "elona.equip_ring_ring", Enum.Quality.Normal)
      add_equip(equip_spec, "elona.ring_2", "elona.equip_ring_ring", Enum.Quality.Bad)
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.armor", "elona.equip_body_robe", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.cloak", "elona.equip_back_cloak", Enum.Quality.Bad)
      end
      -- <<<<<<<< shade2/chara.hsp:130 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:220 	case eqMage ...
      loot(chara, drops, 20, "elona.scroll")
      loot(chara, drops, 40, "elona.spellbook")
      -- <<<<<<<< shade2/item.hsp:223 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "archer",
   elona_id = 3,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:109 	if cEquipment=eqArcher{ ...
      Effect.generate_money(chara)

      add_equip(equip_spec, "elona.primary_weapon", "elona.equip_melee_long_sword", Enum.Quality.Bad)
      add_equip(equip_spec, "elona.ranged_weapon", "elona.equip_ranged_bow", Enum.Quality.Bad)
      add_equip(equip_spec, "elona.ammo", "elona.equip_ammo_arrow", Enum.Quality.Bad)
      add_equip(equip_spec, "elona.cloak", "elona.equip_back_cloak", Enum.Quality.Bad)
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.armor", "elona.equip_body_mail", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.gloves", "elona.equip_wrist_gauntlet", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.boots", "elona.equip_leg_heavy_boots", Enum.Quality.Bad)
      end
      -- <<<<<<<< shade2/chara.hsp:119 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:216 	case eqArcher ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:218 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "gunner",
   elona_id = 4,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:133 	if cEquipment=eqGunner{ ...
      Effect.generate_money(chara)

      add_equip(equip_spec, "elona.primary_weapon", "elona.equip_melee_long_sword", Enum.Quality.Bad)
      if not Rand.one_in(4) then
         add_equip(equip_spec, "elona.ranged_weapon", "elona.equip_ranged_gun", Enum.Quality.Normal)
         add_equip(equip_spec, "elona.ammo", "elona.equip_ammo_bullet", Enum.Quality.Bad)
      else
         add_equip(equip_spec, "elona.ranged_weapon", "elona.equip_ranged_laser_gun", Enum.Quality.Normal)
         add_equip(equip_spec, "elona.ammo", "elona.equip_ammo_energy_cell", Enum.Quality.Bad)
      end
      add_equip(equip_spec, "elona.cloak", "elona.equip_back_cloak", Enum.Quality.Bad)
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.armor", "elona.equip_body_mail", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.gloves", "elona.equip_wrist_gauntlet", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.boots", "elona.equip_leg_heavy_boots", Enum.Quality.Bad)
      end
      -- <<<<<<<< shade2/chara.hsp:149 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:225 	case eqGunner ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:227 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "war_mage",
   elona_id = 5,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:151 	if cEquipment=eqWarMage{ ...
      Effect.generate_money(chara)

      add_equip(equip_spec, "elona.primary_weapon", random_mage_weapon(), Enum.Quality.Normal)
      add_equip(equip_spec, "elona.amulet_1", "elona.equip_neck_armor", Enum.Quality.Bad)
      add_equip(equip_spec, "elona.ring_1", "elona.equip_ring_ring", Enum.Quality.Normal)
      add_equip(equip_spec, "elona.ring_2", "elona.equip_ring_ring", Enum.Quality.Bad)
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.armor", "elona.equip_body_mail", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.cloak", "elona.equip_back_cloak", Enum.Quality.Bad)
      end
      -- <<<<<<<< shade2/chara.hsp:160 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:229 	case eqWarMage ...
      loot(chara, drops, 50, "elona.spellbook")
      -- <<<<<<<< shade2/item.hsp:231 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "priest",
   elona_id = 6,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:100 	if cEquipment=eqPriest{ ...
      Effect.generate_money(chara)

      add_equip(equip_spec, "elona.primary_weapon", "elona.equip_melee_club", Enum.Quality.Bad)
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.shield", "elona.equip_shield_shield", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.armor", "elona.equip_body_mail", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.helmet", "elona.equip_head_helm", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.boots", "elona.equip_leg_heavy_boots", Enum.Quality.Bad)
      end
      -- <<<<<<<< shade2/chara.hsp:107 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "thief",
   elona_id = 7,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:85 	if cEquipment=eqThief{ ...
      Effect.generate_money(chara)

      add_equip(equip_spec, "elona.primary_weapon", random_light_weapon(), Enum.Quality.Normal)
      local spec = add_equip(equip_spec, "elona.secondary_weapon", random_light_weapon(), Enum.Quality.Normal)
      spec.is_dual_wield = true
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.armor", "elona.equip_body_mail", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.helmet", "elona.equip_head_helm", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.boots", "elona.equip_leg_heavy_boots", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.girdle", "elona.equip_back_girdle", Enum.Quality.Bad)
      end
      add_equip(equip_spec, "elona.ranged_weapon", "elona.equip_ranged_thrown", Enum.Quality.Bad)
      -- <<<<<<<< shade2/chara.hsp:99 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
      -- >>>>>>>> shade2/item.hsp:212 	case eqThief ...
      loot(chara, drops, 20, "elona.drink")
      -- <<<<<<<< shade2/item.hsp:214 	swbreak ..
   end
}

data:add {
   _type = "base.equipment_type",
   _id = "claymore",
   elona_id = 8,

   on_initialize_equipment = function(chara, equip_spec, gen_chance)
      -- >>>>>>>> shade2/chara.hsp:75 	if cEquipment=eqClaymore{ ...
      Effect.generate_money(chara)

      equip_spec["elona.primary_weapon"] = {
         _id = "elona.claymore",
         quality = Enum.Quality.Good,
         is_two_handed = true
      }
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.boots", "elona.equip_leg_heavy_boots", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.girdle", "elona.equip_back_girdle", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.girdle", "elona.equip_back_girdle", Enum.Quality.Bad)
      end
      if Rand.one_in(gen_chance) then
         add_equip(equip_spec, "elona.cloak", "elona.equip_back_cloak", Enum.Quality.Normal)
      end
      add_equip(equip_spec, "elona.ranged_weapon", "elona.equip_ranged_thrown", Enum.Quality.Bad)
      -- <<<<<<<< shade2/chara.hsp:83 		} ..
   end,

   on_drop_loot = function(chara, _, drops)
   end
}
