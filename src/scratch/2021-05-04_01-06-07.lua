local bmp_convert = require("internal.bmp_convert")
local Compat = require("mod.elona_sys.api.Compat")

local extract = function(image, atlas)
   local overrides = {}

   local image_data = bmp_convert.load_image_data(image, {0, 255, 0})
   local cb = function(x, y, r, g, b, a)
      if x % 48 == 0 and y % 48 == 0 then
         if a ~= 0 and r ~= 182 and g ~= 178 and b ~= 163 then
            local idx = math.floor(x / 48) + math.floor(y / 48) * 33
            local _id = Compat.convert_122_map_chip(atlas, idx)
            if _id then
               overrides[#overrides+1] = _id
            end
         end
      end
      return r, g, b, a
   end
   image_data:mapPixel(cb)

   return overrides
end

map0 = extract("mod/tender_garden/graphic/map0_add.bmp", 0)
map1 = extract("mod/tender_garden/graphic/map1_add.bmp", 1)
