local t = require("mod.elona122_maps.tiles")
local tiles = t[1]
local same = t[2]

local InstancedMap = require("api.InstancedMap")
local Map = require("api.Map")
local Fs = require("api.Fs")
local struct = require("mod.elona122_maps.thirdparty.struct")

-- NOTE: eventually takes a dependency on map_feats
function convert_122(gen, params)
   if not params.name then
      error("Map name must be provided.")
   end

   local base = Fs.join("mod/elona122_maps/map", params.name)

   if not Fs.exists(base .. ".map") then
      error("Map doesn't exist.")
   end

   local idx = Fs.open(base .. ".idx")
   local width, height, atlas_no, regen, stair_up = struct.unpack("iiiii", idx:read(4 * 5))

   local result = InstancedMap:new(width, height)

   idx:close()

   local map = Fs.open(base .. ".map")

   local function unp(cnt, i)
      return { struct.unpack(string.rep("i", cnt), i:read(4 * cnt)) }
   end

   local size = width * height
   local tile_ids = unp(size, map)

   local i = 1
   for y=0,height-1 do
      for x=0,width-1 do
         local tile_id = tile_ids[i]

         local new_tile = tiles[string.format("%s_%s", atlas_no, tile_id)]

         if new_tile == nil then
            assert(atlas_no == 2)
            assert(same[tile_id])

            -- Find the corresponding tile in atlas 1, since this one
            -- is a duplicate in atlas 2.
            new_tile = tiles[string.format("%s_%s", 1, tile_id)]
            assert(new_tile ~= nil)
         end

         result:set_tile(x, y, new_tile)

         i = i + 1
      end
   end

   map:close()

   local obj = Fs.open(base .. ".obj")

   for j=1,300 do
      local data = { struct.unpack("iiiii", obj:read(4 * 5)) }

      if data[1] ~= 0 then
         if data[5] == 0 then
            -- cmap.items[#cmap.items+1] = {
            --    id = v[1],
            --    x = v[2],
            --    y = v[3],
            --    own_state = v[4]
            -- }
         elseif data[5] == 1 then
            -- cmap.charas[#cmap.charas+1] = {
            --    id = v[1],
            --    x = v[2],
            --    y = v[3]
            -- }
         elseif data[5] == 2 then
            -- cmap.objects[#cmap.objects+1] = {
            --    id = v[1],
            --    x = v[2],
            --    y = v[3],
            --    feat_param_a = v[4] % 1000,
            --    feat_param_b = math.floor(v[4] / 1000)
            -- }
         end
      end
   end

   result.player_start_pos = { x = 20, y = 20 }

   return result
end

data:add {
   _type = "base.map_generator",
   _id = "elona122",

   generate = convert_122,
}

for _, t in pairs(tiles) do
   t._type = "base.map_tile"
   t.id = nil
   if t.effect == 5 then
      t.is_solid = true
      t.is_opaque = true
   elseif t.effect == 4 then
      t.is_solid = true
      t.is_opaque = false
   end
   t.effect = nil
   data:add(t)
end
