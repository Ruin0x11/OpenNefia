local InstancedMap = require("api.InstancedMap")
local Draw = require("api.Draw")

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

local function img_to_map(self, params, opts)
   local chip = data["base.chip"]:ensure(params.chip_id)

   local img_data = Draw.load_image_data(chip.image)

   floors = floors or data["base.map_tile"]:iter()
      :filter(function(t) return not t.is_solid end)
      :map(function(t)
            local image = t.image
            if type(image) == "table" then
               image = image[1]
            end
            local image_data = Draw.load_image_data(image)
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

   return map, params.chip_id
end


data:add {
   _type = "base.map_generator",
   _id = "img_to_map",

   generate = img_to_map
}
