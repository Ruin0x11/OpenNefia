local utils = require("mod.test_room.data.map_archetype.utils")
local Chara = require("api.Chara")
local Enum = require("api.Enum")

local initial_equipment = {
   _id = "initial_equipment"
}

function initial_equipment.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)

   local filter = function(c)
      return c.initial_equipment or c.on_initialize_equipment
   end

   for _, proto in data["base.chara"]:iter():filter(filter) do
      local chara = Chara.create(proto._id, nil, nil, nil, map)
      if chara then
         chara.relation = Enum.Relation.Dislike
      end
   end

   local ids = data["base.class"]:iter():extract("_id")
      :map(function(_id)
            return data["base.chara"]:iter():filter(function(i) return i.class == _id end):nth(1)
          end)

   local i = 0
   for _, proto in ids:unwrap() do
      local chara = Chara.create(proto._id, 2 + i, 4, nil, map)
      if chara then
         chara.relation = Enum.Relation.Dislike
      end
      i = i + 1
   end

   return map
end

return initial_equipment
