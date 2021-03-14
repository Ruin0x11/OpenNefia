local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")

local throw = {
   _id = "throw"
}

local function create_throw(x, y, width, map)
   local filter = function(i)
      return i.on_throw or table.set(i.categories)["elona.drink"]
   end

   local create = function(i)
      local item = Item.create(i._id, nil, nil, {}, map)
      Effect.identify_item(item, Enum.IdentifyState.Full)
      return item
   end
   local sort = function(a, b)
      return (a.proto.elona_id or 0) < (b.proto.elona_id or 0)
   end

   local items = data["base.item"]:iter():filter(filter):map(create):to_list()
   table.sort(items, sort)

   utils.roundup(items, x, y, width)
end

function throw.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)
   utils.create_sandbag(4, 2, map)

   create_throw(2, 4, 16, map)

   return map
end

return throw
