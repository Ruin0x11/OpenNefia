local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Item = require("api.Item")
local Chara = require("api.Chara")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local Area = require("api.Area")

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
   local sandbag = assert(Item.create("elona.sand_bag", x, y, {}, map))
   local chara = assert(Chara.create(chara_id, x, y, {}, map))
   chara.is_hung_on_sandbag = true
   chara.faction = "base.enemy"
end

function utils.normalize_items(map)
   local normalize = function(i)
      Effect.identify_item(i, Enum.IdentifyState.Full)
      i.curse_state = Enum.CurseState.Normal
   end
   Item.iter(map):each(normalize)
end

return utils
