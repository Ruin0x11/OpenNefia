local CodeGenerator = require("api.CodeGenerator")

data:add_type {
   name = "encounter",
   fields = {
      {
         name = "encounter_level",
         default = CodeGenerator.gen_literal [[
function(outer_map, outer_x, outer_y)
   return 10
end]],
         template = true,
         doc = [[
Controls the level of the encounter.
]]
      },
      {
         name = "before_encounter_start",
         default = CodeGenerator.gen_literal [[
function(level, outer_map, outer_x, outer_y)
    Gui.mes("Ambush!")
    Input.query_more()
end]],
         template = true,
         doc = [[
This is run before the player is transported to the encounter map.
]]
      },
      {
         name = "on_map_entered",
         default = CodeGenerator.gen_literal [[
function(map, level, outer_map, outer_x, outer_y)
    for i = 1, 10 do
        Chara.create("elona.putit", nil, nil, nil, map)
    end
end]],
         template = true,
         doc = [[
Generates the encounter. This function receives map that the encounter will take
place in, like the open fields. Create any enemies you want here, and maybe add
a deferred event to trigger a scripted dialog.
]]
      }
   }
}

require("mod.elona.data.encounter.enemy")
require("mod.elona.data.encounter.assassin")
require("mod.elona.data.encounter.merchant")
require("mod.elona.data.encounter.rogue")
