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
      }
   }
}

data:add {
   _type = "elona.material_spot",
   _id = "dungeon",
}

data:add {
   _type = "elona.material_spot",
   _id = "forest",
}

data:add {
   _type = "elona.material_spot",
   _id = "field",
}

data:add {
   _type = "elona.material_spot",
   _id = "building",
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
   on_finish = "activity.dig"
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
   on_finish = "activity.dig"
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
   on_finish = "activity.dig"
}

data:add {
   _type = "elona.material_spot",
   _id = "remains",
}

data:add {
   _type = "elona.material_spot",
   _id = "general",
}
