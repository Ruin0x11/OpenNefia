local fs = require("internal.fs")
local internal = require("internal")
local stopwatch = require("util.stopwatch")

local startup = {}

local sw

local tile_size = 48

function startup.run()
   math.randomseed(internal.get_timestamp())
   sw = stopwatch:new()
end

local tile_batch = require("internal.draw.tile_batch")
local sparse_batch = require("internal.draw.sparse_batch")
local atlas = require("internal.draw.atlas")
local batches = {}

local function get_map_tiles()
   local files = {}
   local dir = "graphic/temp/map_tile"
   if not fs.exists(dir) then
      error("not exist " .. dir)
   end
   for _, f in ipairs(fs.get_directory_items(dir)) do
      local file = fs.join(dir, f)
      local tile = love.image.newImageData(file)
      local r, g, b = tile:getPixel(0, 0)
      if r ~= 0 or g ~= 0 or b ~= 0 then
         files[#files+1] = file
      end
      tile:release()
   end
   return files
end

local function get_chara_tiles()
   local files = {}
   local dir = "graphic/temp/chara"
   if not fs.exists(dir) then
      error("not exist " .. dir)
   end
   for _, f in ipairs(fs.get_directory_items(dir)) do
      local file = fs.join(dir, f)
      local tile = love.image.newImageData(file)
      if tile:getHeight() == tile_size then
         files[#files+1] = file
      end
      tile:release()
   end
   return files
end

function startup.load_batches(coords)
   sw:measure()

   local atlas = atlas:new(tile_size, tile_size, 48, 48)
   atlas:load(get_map_tiles(), coords)

   sw:p("load_batches.map")

   local chara_atlas = atlas:new(tile_size, tile_size, 48, 48)
   chara_atlas:load(get_chara_tiles())

   sw:p("load_batches.chara")

   local map_size = 40
   local tiles = table.of(451, map_size * map_size)
   local map_batch = tile_batch:new(map_size, map_size, atlas, coords)
   map_batch:set_tiles(tiles)
   for x=0,map_size-1 do
      for y=0,map_size-1 do
         if x == 0 or y == 0 or x == map_size-1 or y == map_size - 1 then
            map_batch:update_tile(x, y, 300)
         end
      end
   end

   local chara_batch = sparse_batch:new(map_size, map_size, chara_atlas, coords)
   -- for i=1,5000 do
   --    chara_batch:add_tile {
   --       tile = math.random(1, #chara_atlas.tiles),
   --       x = math.random(0, map_size - 1),
   --       y = math.random(0, map_size - 1),
   --       x_offset = math.random(-24,24),
   --       y_offset = math.random(-24,24),
   --    }
   -- end

   sw:p("load_batches.update")

   return {
      map = map_batch,
      chara = chara_batch,
   }
end

return startup
