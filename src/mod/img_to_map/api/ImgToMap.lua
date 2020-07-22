local InstancedMap = require("api.InstancedMap")
local Draw = require("api.Draw")

local ImgToMap = {}

local floors = nil

local function avg_color(image_data)
   local rt = 0
   local gt = 0
   local bt = 0
   local count = 0
   image_data:mapPixel(function(_,_,r,g,b,a)
         rt = rt + r
         gt = gt + g
         bt = bt + b
         count = count + 1
         return r,g,b,a
   end)
   image_data:release()
   return { r = rt / count, g = gt / count, b = bt / count }
end

local function nearest_tile(target, cands)
   local min_dist_sq = 999999999
   local best_tile = nil

   for tile, color in pairs(cands) do
      local dist_sq = math.pow(target.r - color.r, 2)
         + math.pow(target.g - color.g, 2)
         + math.pow(target.b - color.b, 2)

      if dist_sq < min_dist_sq then
         min_dist_sq = dist_sq
         best_tile = tile
      end
   end

   return best_tile
end

local function chip_to_image(chip_id, batch, canvas)
   batch:clear()
   batch:add(chip_id, 0, 0, 48, 48)
   Draw.with_canvas(canvas, function() batch:draw(0, 0) end)
   return canvas:newImageData()
end

function ImgToMap.img_to_map(chip_id)
   local canvas = Draw.create_canvas(48, 48)
   local batch = Draw.make_chip_batch("chip")
   local chip = data["base.chip"]:ensure(chip_id)

   local img_data = chip_to_image(chip._id, batch, canvas)

   local tile_batch = Draw.make_chip_batch("tile")
   floors = floors or data["base.map_tile"]:iter()
      :filter(function(t) return not t.is_solid and t.elona_atlas == 1 end)
      :map(function(t)
            local image_data = chip_to_image(t._id, tile_batch, canvas)
            return t._id, avg_color(image_data)
          end)
      :tomap()

   local map = InstancedMap:new(img_data:getWidth(), img_data:getHeight())
   img_data:mapPixel(
      function(x,y,r,g,b,a)
         local tile = nearest_tile({r=r,g=g,b=b}, floors)
         map:set_tile(x, y, tile)
         return r,g,b,a
      end)

   img_data:release()

   map.player_start_pos = { x = map:width() / 2, y = map:height() / 2 }

   return map, "img_to_map." .. chip_id
end

return ImgToMap
