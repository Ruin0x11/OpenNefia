local Chara = require("api.Chara")
local utils = require("mod.test_room.data.map_archetype.utils")

local is_invisible = {
   _id = "is_invisible"
}

function is_invisible.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   Chara.create("elona.greater_pumpkin", 10, 10, {}, map)

   return map
end

return is_invisible
