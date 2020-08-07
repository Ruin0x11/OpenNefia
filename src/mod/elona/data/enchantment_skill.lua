-- see:
-- shade2/item_data.hsp:313 	encProcRef(0,0)	=spWeakEle,enemy		,1000	,fltWea ..

data:add {
   _type = "base.enchantment_skill",
   _id = "element_scar",
   elona_id = 0,

   skill_id = "elona.buff_element_scar",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 10
}

data:add {
   _type = "base.enchantment_skill",
   _id = "draw_charge",
   elona_id = 1,

   skill_id = "elona.action_draw_charge",
   target_type = "enemy",
   rarity = 6000,
   categories = { "elona.equip_ranged" },
   chance = 50
}

data:add {
   _type = "base.enchantment_skill",
   _id = "nightmare",
   elona_id = 2,

   skill_id = "elona.buff_nightmare",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 10
}

data:add {
   _type = "base.enchantment_skill",
   _id = "raging_roar",
   elona_id = 3,

   skill_id = "elona.spell_raging_roar",
   target_type = "enemy",
   rarity = 800,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 12
}

data:add {
   _type = "base.enchantment_skill",
   _id = "chaos_ball",
   elona_id = 4,

   skill_id = "elona.spell_chaos_ball",
   target_type = "enemy",
   rarity = 600,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 12
}

data:add {
   _type = "base.enchantment_skill",
   _id = "lulwys_trick",
   elona_id = 5,

   skill_id = "elona.buff_lulwys_trick",
   target_type = "self_or_nearby",
   rarity = 400,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 2
}

data:add {
   _type = "base.enchantment_skill",
   _id = "dimensional_move",
   elona_id = 6,

   skill_id = "elona.action_dimensional_move",
   target_type = "self_or_nearby",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 50
}

data:add {
   _type = "base.enchantment_skill",
   _id = "shadow_step",
   elona_id = 7,

   skill_id = "elona.action_shadow_step",
   target_type = "enemy",
   rarity = 4000,
   categories = { "elona.equip_ranged" },
   chance = 50
}

data:add {
   _type = "base.enchantment_skill",
   _id = "lightning_breath",
   elona_id = 8,

   skill_id = "elona.action_lightning_breath",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 15
}

data:add {
   _type = "base.enchantment_skill",
   _id = "nerve_breath",
   elona_id = 9,

   skill_id = "elona.action_nerve_breath",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 15
}

data:add {
   _type = "base.enchantment_skill",
   _id = "nether_breath",
   elona_id = 10,

   skill_id = "elona.action_nether_breath",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 15
}

data:add {
   _type = "base.enchantment_skill",
   _id = "divine_wisdom",
   elona_id = 11,

   skill_id = "elona.buff_divine_wisdom",
   target_type = "self_or_nearby",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 4
}

data:add {
   _type = "base.enchantment_skill",
   _id = "holy_veil",
   elona_id = 12,

   skill_id = "elona.buff_holy_veil",
   target_type = "self_or_nearby",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 4
}

data:add {
   _type = "base.enchantment_skill",
   _id = "hero",
   elona_id = 13,

   skill_id = "elona.buff_hero",
   target_type = "self_or_nearby",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 4
}

data:add {
   _type = "base.enchantment_skill",
   _id = "speed",
   elona_id = 14,

   skill_id = "elona.buff_speed",
   target_type = "self_or_nearby",
   rarity = 400,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 1
}

data:add {
   _type = "base.enchantment_skill",
   _id = "regeneration",
   elona_id = 15,

   skill_id = "elona.buff_regeneration",
   target_type = "self_or_nearby",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 3
}

data:add {
   _type = "base.enchantment_skill",
   _id = "holy_shield",
   elona_id = 16,

   skill_id = "elona.buff_holy_shield",
   target_type = "self_or_nearby",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 2
}

data:add {
   _type = "base.enchantment_skill",
   _id = "mist_of_silence",
   elona_id = 17,

   skill_id = "elona.buff_mist_of_silence",
   target_type = "enemy",
   rarity = 800,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 10
}

data:add {
   _type = "base.enchantment_skill",
   _id = "web",
   elona_id = 18,

   skill_id = "elona.spell_web",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 10
}

data:add {
   _type = "base.enchantment_skill",
   _id = "lightning_bolt",
   elona_id = 19,

   skill_id = "elona.spell_lightning_bolt",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 15
}

data:add {
   _type = "base.enchantment_skill",
   _id = "darkness_bolt",
   elona_id = 20,

   skill_id = "elona.spell_darkness_bolt",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 15
}

data:add {
   _type = "base.enchantment_skill",
   _id = "mind_bolt",
   elona_id = 21,

   skill_id = "elona.spell_mind_bolt",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 15
}

data:add {
   _type = "base.enchantment_skill",
   _id = "ice_bolt",
   elona_id = 22,

   skill_id = "elona.spell_ice_bolt",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 15
}

data:add {
   _type = "base.enchantment_skill",
   _id = "healing_rain",
   elona_id = 23,

   skill_id = "elona.spell_healing_rain",
   target_type = "self_or_nearby",
   rarity = 800,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 2
}

data:add {
   _type = "base.enchantment_skill",
   _id = "grenade",
   elona_id = 24,

   skill_id = "elona.action_grenade",
   target_type = "enemy",
   rarity = 200,
   categories = { "elona.equip_melee", "elona.equip_ranged" },
   chance = 90
}

data:add {
   _type = "base.enchantment_skill",
   _id = "decapitation",
   elona_id = 25,

   skill_id = "elona.action_decapitation",
   target_type = "enemy",
   rarity = 1000,
   categories = { "elona.equip_melee" },
   chance = 100
}
