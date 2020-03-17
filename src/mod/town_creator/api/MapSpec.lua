local Chara = require("api.Chara")
local Feat = require("api.Feat")
local Item = require("api.Item")
local Map = require("api.Map")

local MapSpec = {}

function MapSpec.create(tiles, atlas)
end

--- @tparam string tiles
--- @tparam table atlas
--- @tparam uint x
--- @tparam uint y
--- @tparam[opt] boolean memorize
--- @tparam[opt] InstancedMap map
function MapSpec.place(tiles, atlas, x, y, memorize, map)
   assert(type(tiles) == "string")
   assert(type(atlas) == "table")
   tiles = string.strip_whitespace(tiles)
   map = map or Map.current()

   local place = {}
   local dy = 0

   local width
   for line in string.lines(tiles) do
      if width then
         if width ~= #line then
            error(("Expected row of width %s, got %s"):format(width, #line))
         end
      else
         width = #line
      end

      local dx = 0
      for c in string.chars(line) do
         local tile = {}
         local entry = atlas[c]
         if entry == nil then
            error(("Unknown tile '%s'"):format(c))
         end

         tile.map_tile = entry.map_tile

         if entry.objects then
            for _, obj in ipairs(entry.objects) do
               if obj.type == "chara" then
                  table.insert(tile, Chara.create(obj.id, nil, nil, {ownerless=true}))
               elseif obj.type == "item" then
                  table.insert(tile, Item.create(obj.id, nil, nil, {ownerless=true}))
               elseif obj.type == "feat" then
                  table.insert(tile, Feat.create(obj.id, nil, nil, {ownerless=true}))
               end
            end
         end

         if entry.on_create then
            tile.on_create = entry.on_create
         end

         place[dx+dy*width] = tile

         dx = dx + 1
      end
      dy = dy + 1
   end

   local height = dy

   for j=0,height-1 do
      for i=0,width-1 do
         local dx = i+x
         local dy = j+y

         local tile = place[j*width+i]
         map:set_tile(dx, dy, tile.map_tile)

         for _, obj in ipairs(tile) do
            assert(map:take_object(obj, dx, dy))
         end

         if tile.on_create then
            tile.on_create(dx, dy, map)
         end

         if memorize then
            map:memorize_tile(dx, dy)
         end
      end
   end
end

return MapSpec
