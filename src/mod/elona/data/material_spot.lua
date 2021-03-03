local CodeGenerator = require("api.CodeGenerator")
local Material = require("mod.elona.api.Material")

data:add_type {
   name = "material_spot",
   fields = {
      {
         name = "on_search",
         type = "function",
         default = CodeGenerator.gen_literal [[
function(self, params)
  local chara = params.chara
  local feat = params.feat
  local mat_level = params.material_level
  local mat_choices = params.material_choices

  return Material.random_material_id(mat_level, 0, mat_choices), "dig"
end
]],
         template = true
      },
      {
         name = "on_finish",
         type = "locale_key",
         default = nil,
      },
      {
         name = "materials",
         type = "table",
         default = {},
         template = true
      }
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "global",

   materials = {
      "elona.kuzu",
      "elona.casino_chip",
      "elona.coin_1",
      "elona.coin_2",
      "elona.paper",
      "elona.sumi",
      "elona.driftwood",
      "elona.stone",
      "elona.staff",
      "elona.cloth",
      "elona.yellmadman",
      "elona.magic_mass",
      "elona.elec",
      "elona.generate",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "dungeon",

   materials = {
      "elona.magic_frag"
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "forest",

   materials = {
      "elona.stick",
      "elona.leather",
      "elona.string",
      "elona.tight_wood",
      "elona.crooked_staff"
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "field",

   materials = {
      "elona.adhesive",
      "elona.memory_frag",
      "elona.magic_paper",
      "elona.magic_ink"
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "building",

   materials = {
      "elona.adhesive",
      "elona.memory_frag",
      "elona.magic_paper",
      "elona.magic_ink",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "water",
   on_search = function(self, params)
      local chara = params.chara
      local feat = params.feat
      local mat_level = params.material_level
      local mat_choices = params.material_choices

      return Material.random_material_id(mat_level, 0, mat_choices), "activity.dig"
   end,
   on_finish = "activity.dig",

   materials = {
      "elona.sea_water",
      "elona.waterdrop",
      "elona.tear_angel",
      "elona.hot_water",
      "elona.tear_witch",
      "elona.snow",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "mine",
   on_search = function(self, params)
      local chara = params.chara
      local feat = params.feat
      local mat_level = params.material_level
      local mat_choices = params.material_choices

      return Material.random_material_id(mat_level, 0, mat_choices), "activity.dig"
   end,
   on_finish = "activity.dig",

   materials = {
      "elona.mithril_frag",
      "elona.steel_frag",
      "elona.fire_stone",
      "elona.ice_stone",
      "elona.elec_stone",
      "elona.good_stone",
      "elona.ether_frag",
      "elona.elem_frag",
      "elona.chaos_stone",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "bush",
   on_search = function(self, params)
      local chara = params.chara
      local feat = params.feat
      local mat_level = params.material_level
      local mat_choices = params.material_choices

      return Material.random_material_id(mat_level, 0, mat_choices), "activity.dig"
   end,
   on_finish = "activity.dig",

   materials = {
      "elona.plant_1",
      "elona.plant_2",
      "elona.plant_3",
      "elona.plant_4",
      "elona.plant_heal",
      "elona.flying_grass",
      "elona.plant_5",
      "elona.black_myst",
      "elona.sap",
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "remains",

   materials = {
      "elona.feather",
      "elona.tail_rabbit",
      "elona.gen_human",
      "elona.tail_bear",
      "elona.gen_troll",
      "elona.eye_witch",
      "elona.fairy_dust",
   }
}
