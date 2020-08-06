local Area = require("api.Area")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Input = require("api.Input")
local state = require("mod.test_room.internal.global.state")

function prompt_paged(cands)
end

data:add {
   _type = "base.feat",
   _id = "select_map",

   image = "elona.feat_quest_board",
   is_solid = true,
   is_opaque = false,

   on_bumped_into = function(self, params)
      local pred = function(arc) return state.is_test_map[arc._id] end
      local arcs = data["base.map_archetype"]:iter():filter(pred)

      local choices = arcs:map(function(arc) return arc._id:gsub("^.*%.", "") end):to_list()
      local choice, canceled = Input.prompt(choices)
      if canceled then
         return
      end
      local arc = arcs:nth(choice.index)

      local area = Area.for_map(self:current_map())
      local floor = area:deepest_floor() + 1
      local ok, map = area:load_or_generate_floor(floor, arc._id)
      if not ok then
         Gui.mes_c("Could not generate map: " .. map, "Red")
      end

      Map.travel_to(map)

      return "player_turn_query"
   end,
}
