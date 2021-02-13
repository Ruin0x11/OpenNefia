local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Item = require("api.Item")
local Chara = require("api.Chara")
local utils = require("mod.test_room.data.map_archetype.utils")

local magic_items = {
   _id = "magic_items"
}

local function roundup(tbl, x, y, width)
   width = width or 20
   x = x or Chara.player().x - math.floor(width / 2)
   y = y or Chara.player().y
   local i = 1
   for _, obj in ipairs(tbl) do
      local tx = (i-1) % width
      local ty = math.floor((i-1) / width)
      obj:set_pos(x + tx, y + ty)
       i = i + 1
   end
end

local function create_magic_items(x, y, width, map)
   local categories = table.set {
      "elona.spellbook",
      "elona.rod",
      "elona.potion",
      "elona.scroll",
   }
   local filter = function(i)
      for _, cat in ipairs(i.categories or {}) do
         if categories[cat] then
            return true
         end
      end
      return false
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

   roundup(items, x, y, width)
end

function magic_items.on_generate_map(area, floor)
   local map = utils.create_map(20, 20)
   utils.create_stairs(2, 2, area, map)
   utils.create_sandbag(4, 2, map)

   create_magic_items(2, 4, 16, map)

   return map
end

return magic_items
