data:add_type {
   name = "production_recipe",
   fields = {
      {
         name = "item_id",
         type = "id:base.item",
         template = true,
      },
      {
         name = "skill_used",
         type = "id:base.skill",
         template = true,
      },
      {
         name = "required_skill_level",
         type = "integer",
         default = 1,
         template = true,
      },
      {
         name = "materials",
         type = "table",
         template = true,
      },
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_superior_material",

   item_id = "elona.scroll_of_superior_material",
   skill_used = "elona.jeweler",
   required_skill_level = 40,

   materials = {
      { _id = "elona.magic_paper", amount = 2 },
      { _id = "elona.generate", amount = 2 },
      { _id = "elona.chaos_stone", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_change_material",

   item_id = "elona.scroll_of_change_material",
   skill_used = "elona.jeweler",
   required_skill_level = 13,

   materials = {
      { _id = "elona.paper", amount = 2 },
      { _id = "elona.generate", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_inferior_material",

   item_id = "elona.scroll_of_inferior_material",
   skill_used = "elona.jeweler",
   required_skill_level = 1,

   materials = {
      { _id = "elona.paper", amount = 2 },
      { _id = "elona.yellmadman", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "shoes",

   item_id = "elona.shoes",
   skill_used = "elona.tailoring",
   required_skill_level = 1,

   materials = {
      { _id = "elona.cloth", amount = 4 },
      { _id = "elona.string", amount = 2 },
      { _id = "elona.mithril_frag", amount = 3 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_detect_objects",

   item_id = "elona.scroll_of_detect_objects",
   skill_used = "elona.jeweler",
   required_skill_level = 5,

   materials = {
      { _id = "elona.paper", amount = 4 },
      { _id = "elona.magic_ink", amount = 1 },
      { _id = "elona.elec", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_noble_toy",

   item_id = "elona.cargo_noble_toy",
   skill_used = "elona.carpentry",
   required_skill_level = 11,

   materials = {
      { _id = "elona.tight_wood", amount = 3 },
      { _id = "elona.good_stone", amount = 2 },
      { _id = "elona.fairy_dust", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_whisky",

   item_id = "elona.cargo_whisky",
   skill_used = "elona.alchemy",
   required_skill_level = 14,

   materials = {
      { _id = "elona.hot_water", amount = 4 },
      { _id = "elona.snow", amount = 3 },
      { _id = "elona.plant_heal", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_grave",

   item_id = "elona.cargo_grave",
   skill_used = "elona.carpentry",
   required_skill_level = 15,

   materials = {
      { _id = "elona.stone", amount = 8 },
      { _id = "elona.steel_frag", amount = 5 },
      { _id = "elona.good_stone", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_coffin",

   item_id = "elona.cargo_coffin",
   skill_used = "elona.carpentry",
   required_skill_level = 12,

   materials = {
      { _id = "elona.tight_wood", amount = 5 },
      { _id = "elona.plant_4", amount = 2 },
      { _id = "elona.tear_angel", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_rope",

   item_id = "elona.cargo_rope",
   skill_used = "elona.tailoring",
   required_skill_level = 5,

   materials = {
      { _id = "elona.string", amount = 7 },
      { _id = "elona.cloth", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_piano",

   item_id = "elona.cargo_piano",
   skill_used = "elona.jeweler",
   required_skill_level = 14,

   materials = {
      { _id = "elona.driftwood", amount = 8 },
      { _id = "elona.string", amount = 4 },
      { _id = "elona.fairy_dust", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_barrel",

   item_id = "elona.cargo_barrel",
   skill_used = "elona.carpentry",
   required_skill_level = 8,

   materials = {
      { _id = "elona.driftwood", amount = 6 },
      { _id = "elona.stick", amount = 4 },
      { _id = "elona.sumi", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "cargo_rag_doll",

   item_id = "elona.cargo_rag_doll",
   skill_used = "elona.tailoring",
   required_skill_level = 8,

   materials = {
      { _id = "elona.cloth", amount = 5 },
      { _id = "elona.leather", amount = 2 },
      { _id = "elona.snow", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_gain_material",

   item_id = "elona.scroll_of_gain_material",
   skill_used = "elona.jeweler",
   required_skill_level = 30,

   materials = {
      { _id = "elona.paper", amount = 5 },
      { _id = "elona.magic_mass", amount = 1 },
      { _id = "elona.generate", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_mana",

   item_id = "elona.scroll_of_mana",
   skill_used = "elona.jeweler",
   required_skill_level = 25,

   materials = {
      { _id = "elona.magic_paper", amount = 1 },
      { _id = "elona.magic_ink", amount = 2 },
      { _id = "elona.magic_mass", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_holy_rain",

   item_id = "elona.scroll_of_holy_rain",
   skill_used = "elona.jeweler",
   required_skill_level = 25,

   materials = {
      { _id = "elona.magic_paper", amount = 2 },
      { _id = "elona.magic_ink", amount = 2 },
      { _id = "elona.plant_5", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_holy_light",

   item_id = "elona.scroll_of_holy_light",
   skill_used = "elona.jeweler",
   required_skill_level = 15,

   materials = {
      { _id = "elona.magic_paper", amount = 1 },
      { _id = "elona.plant_5", amount = 2 },
      { _id = "elona.elec", amount = 3 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_holy_veil",

   item_id = "elona.scroll_of_holy_veil",
   skill_used = "elona.jeweler",
   required_skill_level = 15,

   materials = {
      { _id = "elona.magic_paper", amount = 2 },
      { _id = "elona.plant_5", amount = 4 },
      { _id = "elona.plant_4", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_greater_identify",

   item_id = "elona.scroll_of_greater_identify",
   skill_used = "elona.jeweler",
   required_skill_level = 18,

   materials = {
      { _id = "elona.magic_paper", amount = 1 },
      { _id = "elona.memory_frag", amount = 2 },
      { _id = "elona.magic_mass", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_potential",

   item_id = "elona.potion_of_potential",
   skill_used = "elona.alchemy",
   required_skill_level = 45,

   materials = {
      { _id = "elona.sap", amount = 2 },
      { _id = "elona.tear_angel", amount = 5 },
      { _id = "elona.hot_water", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_restore_spirit",

   item_id = "elona.potion_of_restore_spirit",
   skill_used = "elona.alchemy",
   required_skill_level = 8,

   materials = {
      { _id = "elona.hot_water", amount = 4 },
      { _id = "elona.plant_2", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_restore_body",

   item_id = "elona.potion_of_restore_body",
   skill_used = "elona.alchemy",
   required_skill_level = 8,

   materials = {
      { _id = "elona.hot_water", amount = 4 },
      { _id = "elona.plant_3", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "bottle_of_beer",

   item_id = "elona.bottle_of_beer",
   skill_used = "elona.alchemy",
   required_skill_level = 1,

   materials = {
      { _id = "elona.waterdrop", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_minor_teleportation",

   item_id = "elona.scroll_of_minor_teleportation",
   skill_used = "elona.jeweler",
   required_skill_level = 1,

   materials = {
      { _id = "elona.paper", amount = 2 },
      { _id = "elona.sumi", amount = 2 },
      { _id = "elona.feather", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_magical_map",

   item_id = "elona.scroll_of_magical_map",
   skill_used = "elona.jeweler",
   required_skill_level = 10,

   materials = {
      { _id = "elona.magic_paper", amount = 1 },
      { _id = "elona.magic_ink", amount = 1 },
      { _id = "elona.elec", amount = 3 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_return",

   item_id = "elona.scroll_of_return",
   skill_used = "elona.jeweler",
   required_skill_level = 4,

   materials = {
      { _id = "elona.paper", amount = 3 },
      { _id = "elona.plant_1", amount = 2 },
      { _id = "elona.sumi", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_uncurse",

   item_id = "elona.scroll_of_uncurse",
   skill_used = "elona.jeweler",
   required_skill_level = 8,

   materials = {
      { _id = "elona.paper", amount = 4 },
      { _id = "elona.plant_5", amount = 2 },
      { _id = "elona.plant_4", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "rod_of_lightning_bolt",

   item_id = "elona.rod_of_lightning_bolt",
   skill_used = "elona.carpentry",
   required_skill_level = 17,

   materials = {
      { _id = "elona.crooked_staff", amount = 1 },
      { _id = "elona.elec_stone", amount = 5 },
      { _id = "elona.adhesive", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "rod_of_fire_bolt",

   item_id = "elona.rod_of_fire_bolt",
   skill_used = "elona.carpentry",
   required_skill_level = 14,

   materials = {
      { _id = "elona.crooked_staff", amount = 1 },
      { _id = "elona.fire_stone", amount = 5 },
      { _id = "elona.magic_frag", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "rod_of_ice_bolt",

   item_id = "elona.rod_of_ice_bolt",
   skill_used = "elona.carpentry",
   required_skill_level = 14,

   materials = {
      { _id = "elona.crooked_staff", amount = 1 },
      { _id = "elona.ice_stone", amount = 5 },
      { _id = "elona.snow", amount = 5 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "rod_of_magic_missile",

   item_id = "elona.rod_of_magic_missile",
   skill_used = "elona.carpentry",
   required_skill_level = 1,

   materials = {
      { _id = "elona.staff", amount = 1 },
      { _id = "elona.steel_frag", amount = 4 },
      { _id = "elona.magic_frag", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "rod_of_cure_minor_wound",

   item_id = "elona.rod_of_cure_minor_wound",
   skill_used = "elona.carpentry",
   required_skill_level = 1,

   materials = {
      { _id = "elona.staff", amount = 1 },
      { _id = "elona.plant_2", amount = 4 },
      { _id = "elona.adhesive", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_healer_jure",

   item_id = "elona.potion_of_healer_jure",
   skill_used = "elona.alchemy",
   required_skill_level = 40,

   materials = {
      { _id = "elona.sap", amount = 2 },
      { _id = "elona.waterdrop", amount = 5 },
      { _id = "elona.plant_heal", amount = 4 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_healer_eris",

   item_id = "elona.potion_of_healer_eris",
   skill_used = "elona.alchemy",
   required_skill_level = 30,

   materials = {
      { _id = "elona.sap", amount = 1 },
      { _id = "elona.hot_water", amount = 4 },
      { _id = "elona.plant_2", amount = 5 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_healer_odina",

   item_id = "elona.potion_of_healer_odina",
   skill_used = "elona.alchemy",
   required_skill_level = 25,

   materials = {
      { _id = "elona.plant_3", amount = 3 },
      { _id = "elona.hot_water", amount = 4 },
      { _id = "elona.plant_heal", amount = 3 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_healer",

   item_id = "elona.potion_of_healer",
   skill_used = "elona.alchemy",
   required_skill_level = 20,

   materials = {
      { _id = "elona.tear_angel", amount = 1 },
      { _id = "elona.waterdrop", amount = 4 },
      { _id = "elona.plant_heal", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_healing",

   item_id = "elona.potion_of_healing",
   skill_used = "elona.alchemy",
   required_skill_level = 15,

   materials = {
      { _id = "elona.hot_water", amount = 3 },
      { _id = "elona.plant_heal", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_cure_critical_wound",

   item_id = "elona.potion_of_cure_critical_wound",
   skill_used = "elona.alchemy",
   required_skill_level = 10,

   materials = {
      { _id = "elona.hot_water", amount = 3 },
      { _id = "elona.plant_2", amount = 1 },
      { _id = "elona.plant_3", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_cure_major_wound",

   item_id = "elona.potion_of_cure_major_wound",
   skill_used = "elona.alchemy",
   required_skill_level = 5,

   materials = {
      { _id = "elona.waterdrop", amount = 3 },
      { _id = "elona.plant_3", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "potion_of_cure_minor_wound",

   item_id = "elona.potion_of_cure_minor_wound",
   skill_used = "elona.alchemy",
   required_skill_level = 1,

   materials = {
      { _id = "elona.waterdrop", amount = 3 },
      { _id = "elona.plant_2", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "girdle",

   item_id = "elona.girdle",
   skill_used = "elona.tailoring",
   required_skill_level = 8,

   materials = {
      { _id = "elona.leather", amount = 4 },
      { _id = "elona.tail_bear", amount = 5 },
      { _id = "elona.tail_rabbit", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "light_cloak",

   item_id = "elona.light_cloak",
   skill_used = "elona.tailoring",
   required_skill_level = 10,

   materials = {
      { _id = "elona.leather", amount = 5 },
      { _id = "elona.adhesive", amount = 3 },
      { _id = "elona.gen_human", amount = 6 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "rod_of_teleportation",

   item_id = "elona.rod_of_teleportation",
   skill_used = "elona.carpentry",
   required_skill_level = 5,

   materials = {
      { _id = "elona.staff", amount = 1 },
      { _id = "elona.feather", amount = 4 },
      { _id = "elona.flying_grass", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "rod_of_identify",

   item_id = "elona.rod_of_identify",
   skill_used = "elona.carpentry",
   required_skill_level = 8,

   materials = {
      { _id = "elona.staff", amount = 1 },
      { _id = "elona.eye_witch", amount = 2 },
      { _id = "elona.memory_frag", amount = 2 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_teleportation",

   item_id = "elona.scroll_of_teleportation",
   skill_used = "elona.jeweler",
   required_skill_level = 7,

   materials = {
      { _id = "elona.paper", amount = 3 },
      { _id = "elona.sumi", amount = 2 },
      { _id = "elona.feather", amount = 3 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "scroll_of_identify",

   item_id = "elona.scroll_of_identify",
   skill_used = "elona.jeweler",
   required_skill_level = 1,

   materials = {
      { _id = "elona.paper", amount = 2 },
      { _id = "elona.memory_frag", amount = 1 }
   }
}

data:add {
   _type = "elona.production_recipe",
   _id = "robe",

   item_id = "elona.robe",
   skill_used = "elona.tailoring",
   required_skill_level = 4,

   materials = {
      { _id = "elona.cloth", amount = 6 },
      { _id = "elona.string", amount = 3 },
      { _id = "elona.magic_frag", amount = 2 }
   }
}
