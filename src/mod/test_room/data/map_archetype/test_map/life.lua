-- We salute you, Sir Conway.
-- https://rosettacode.org/wiki/Conway%27s_Game_of_Life#Lua

local Rand = require("api.Rand")
local InstancedMap = require("api.InstancedMap")
local Pos = require("api.Pos")
local utils = require("mod.test_room.data.map_archetype.utils")

local life = {
   _id = "life"
}

function life.on_generate_map(area, floor)
   local map = InstancedMap:new(50, 50)
   map:clear("elona.cyber_4")
   map.is_indoor = true
   map.reveals_fog = true
   for _, x, y in Pos.iter_border(0, 0, map:width() - 1, map:height() - 1) do
      map:set_tile(x, y, "elona.wall_stone_3_top")
   end

   local sx, sy, ex, ey = 1, 1, map:width() - 2, map:height() - 2

   for _, x, y in Pos.iter_rect(sx, sy, ex, ey) do
      if Rand.one_in(2) then
         map:set_tile(x, y, "elona.cyber_4")
      else
         map:set_tile(x, y, "elona.tile_1")
      end
   end

   utils.create_stairs(25, 25, area, map)

   return map
end

function life.on_map_pass_turn(map)
   local curr = {}
   local next = {}

   local sx, sy, ex, ey = 1, 1, map:width() - 2, map:height() - 2

   for _, x, y in Pos.iter_rect(sx, sy, ex, ey) do
      curr[y] = curr[y] or {}
      curr[y][x] = (map:tile(x, y)._id == "elona.cyber_4" and 0) or 1
      next[y] = next[y] or {}
   end

   local ym1 = ey - 1
   local y = ey
   local yp1 = sy
   for _ = sy, ey do
      local xm1 = ex - 1
      local x = ex
      local xp1 = sy
      for _ = sx, ex do
         local sum = curr[ym1][xm1] + curr[ym1][x] + curr[ym1][xp1] +
            curr[y][xm1] + curr[y][xp1] +
            curr[yp1][xm1] + curr[yp1][x] + curr[yp1][xp1]

         if sum == 2 then
            next[y][x] = curr[y][x]
         elseif sum == 3 then
            next[y][x] = 1
         else
            next[y][x] = 0
         end
         xm1, x, xp1 = x, xp1, xp1+1
      end
      ym1, y, yp1 = y, yp1, yp1+1
   end

   for _, x, y in Pos.iter_rect(sx, sy, ex, ey) do
      if next[y][x] == 1 then
         map:set_tile(x, y, "elona.tile_1")
      else
         map:set_tile(x, y, "elona.cyber_4")
      end
      map:memorize_tile(x, y)
   end
end

return life
