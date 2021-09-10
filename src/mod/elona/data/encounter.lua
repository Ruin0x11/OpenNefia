local InstancedMap = require("api.InstancedMap")

data:add_type {
   name = "encounter",
   fields = {
      {
         name = "encounter_level",
         type = types.callback({"outer_map", types.class(InstancedMap), "outer_x", types.uint, "outer_y", types.uint}, types.number),
         template = true,
         doc = [[
Controls the level of the encounter.
]]
      },
      {
         name = "before_encounter_start",
         type = types.callback({"level", types.uint, "outer_map", types.class(InstancedMap), "outer_x", types.uint, "outer_y", types.uint}, types.number),
         template = true,
         doc = [[
This is run before the player is transported to the encounter map.
]]
      },
      {
         name = "on_map_entered",
         type = types.callback({"map", types.class(InstancedMap), "level", types.uint, "outer_map", types.class(InstancedMap), "outer_x", types.uint, "outer_y", types.uint}, types.number),
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
