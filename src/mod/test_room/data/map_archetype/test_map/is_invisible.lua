local Chara = require("api.Chara")
local utils = require("mod.test_room.data.map_archetype.utils")

local is_invisible = {
   _id = "is_invisible"
}

function is_invisible.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local ids = data["base.chara"]:iter():filter(function(c) return c.is_invisible end):to_list()

   for _, _id in ids:unwrap() do
      Chara.create(_id, nil, nil, {}, map)
   end

   return map
end

return is_invisible
