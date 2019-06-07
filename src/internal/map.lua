local instanced_map = require("internal.instanced_map")

local map = {}

local this_map = nil

--
-- Singleton
--

function map.get()
   return this_map
end

function map.create(width, height)
   local uids = require("internal.global.uids")
   this_map = instanced_map:new(width, height, uids)

   local data = require("internal.data")
   local tiles = data["base.map_tile"]

   for y=0,width-1 do
      for x=0,height-1 do
         if x == 0 or y == 0 or x == width-1 or y == height-1 then
            this_map:set_tile(x, y, tiles["base.wall"])
         else
            this_map:set_tile(x, y, tiles["base.floor"])
         end
      end
   end

   return this_map
end


return map
