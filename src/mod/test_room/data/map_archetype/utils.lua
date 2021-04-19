local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Item = require("api.Item")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Area = require("api.Area")
local ICharaSandBag = require("mod.elona.api.aspect.ICharaSandBag")

local utils = {}

function utils.create_map(width, height)
   width = width or 50
   height = height or 50
   local map = InstancedMap:new(width, height)
   map:clear("elona.cobble")
   map.is_indoor = true
   for _, x, y in Pos.iter_border(0, 0, width - 1, height - 1) do
      map:set_tile(x, y, "elona.wall_dirt_dark_top")
   end

   for _, x, y in map:iter_tiles() do
      map:memorize_tile(x, y)
   end

   return map
end

function utils.create_stairs(x, y, area, map)
   assert(Area.create_stairs_up(area, 1, x, y, {}, map))
end

function utils.create_sandbag(x, y, map, chara_id)
   chara_id = chara_id or "elona.lomias"
   local chara = assert(Chara.create(chara_id, x, y, {}, map))
   chara:get_aspect_or_default(ICharaSandBag, true):hang_on_sand_bag(chara)
   chara.relation = Enum.Relation.Enemy
end

function utils.normalize_items(map)
   local normalize = function(i)
      Effect.identify_item(i, Enum.IdentifyState.Full)
      i.curse_state = Enum.CurseState.Normal
   end
   Item.iter(map):each(normalize)
end

function utils.roundup(tbl, x, y, width)
   width = width or 20
   x = x or Chara.player().x - math.floor(width / 2)
   y = y or Chara.player().y
   local max_y = y
   local i = 1
   for _, obj in ipairs(tbl) do
      local tx = (i-1) % width
      local ty = math.floor((i-1) / width)
      obj:set_pos(x + tx, y + ty)
      i = i + 1
      max_y = math.max(max_y, y + ty)
   end
   return x, max_y
end

return utils
