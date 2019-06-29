local Chara = require("api.Chara")
local Fs = require("api.Fs")
local InstancedMap = require("api.InstancedMap")
local Item = require("api.Item")
local Map = require("api.Map")
local Compat = require("mod.elona_sys.api.Compat")

local struct = require("mod.elona_sys.map_loader.thirdparty.struct")
local t = require("mod.elona_sys.map_loader.tiles")
local tiles = t[1]
local same = t[2]

local own_states = {
   [-2] = "inherited",
   [0]  = "none",
   [1]  = "not_owned",
   [3]  = "shelter",
   [4]  = "harvested",
}

function convert_122(gen, params)
   if not params.name then
      error("Map name must be provided.")
   end

   -- HACK
   local base = Fs.join("mod/elona/data/map", params.name)

   if not Fs.exists(base .. ".map") then
      error(string.format("Map doesn't exist: %s", base .. ".map"))
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
            local id = Compat.convert_122_id("base.item", data[1])
            assert(id, "unknown 1.22 item ID " .. data[1])

            local x = data[2]
            local y = data[3]
            local own_state = own_states[data[4]]
            assert(own_state == "none" or own_state == "not_owned")

            local item = Item.create(id, x, y, {}, result)
            item.ownership = own_state
         elseif data[5] == 1 then
            local id = Compat.convert_122_id("base.chara", data[1])
            assert(id, "unknown 1.22 character ID " .. data[1])

            local x = data[2]
            local y = data[3]

            Chara.create(id, x, y, {}, result)
         elseif data[5] == 2 then
            -- cmap.objects[#cmap.objects+1] = {
            --    id = data[1],
            --    x = data[2],
            --    y = data[3],
            --    feat_param_a = v[4] % 1000,
            --    feat_param_b = math.floor(v[4] / 1000)
            -- }
         end
      end
   end

   result.player_start_pos = { x = math.floor(width / 2), y = math.floor(height / 2) }

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
