local fs = require("internal.fs")
local internal = require("internal")
local stopwatch = require("util.stopwatch")

local startup = {}

local tile_size = 48

function startup.run()
   math.randomseed(internal.get_timestamp())

   require("internal.data.schemas")

   internal.mod.load_mods()
end

local tile_batch = require("internal.draw.tile_batch")
local sparse_batch = require("internal.draw.sparse_batch")
local atlas = require("internal.draw.atlas")
local batches = {}

local function get_map_tiles()
   local data = require("internal.data")
   local it = {}
   for _, v in data["base.map_tile"]:iter() do
      it[#it+1] = v
   end
   return it
end

local function get_tiles(dir)
   local files = {}
   if not fs.exists(dir) then
      error("not exist " .. dir)
   end
   for _, f in fs.iter_directory_items(dir) do
      local file = fs.join(dir, f)
      local tile = love.image.newImageData(file)
      if tile:getHeight() == tile_size then
         files[#files+1] = file
      end
      tile:release()
   end
   return files
end

local function get_chara_tiles()
   return get_tiles("graphic/temp/chara")
end

local function get_item_tiles()
   return get_tiles("graphic/temp/item")
end

function startup.load_batches()
   local coords = require("internal.draw.coords.tiled_coords"):new()
   internal.draw.set_coords(coords)

   local sw = stopwatch:new()
   sw:measure()

   local atlas = atlas:new(tile_size, tile_size, 48, 48)
   atlas:load(get_map_tiles(), coords)

   sw:p("load_batches.map")

   local chara_atlas = atlas:new(tile_size, tile_size, 48, 48)
   chara_atlas:load(get_chara_tiles())

   sw:p("load_batches.chara")

   local item_atlas = atlas:new(tile_size, tile_size, 48, 48)
   item_atlas:load(get_item_tiles())

   sw:p("load_batches.item")

   local atlases = require("internal.global.atlases")
   atlases.set(atlas, chara_atlas, item_atlas)
end

return startup
