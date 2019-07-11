local vips = require("vips")
assert(vips)

local layout = require("tools.layout.chip")
local map_tile = require("tools.layout.map_tile")
local portrait = require("tools.layout.portrait")
local asset = require("tools.layout.asset")

local fs = require("util.fs")

local atlas_cache = {}

local function remove_key_color(image, key_color)
   local alpha = image:equal(key_color):ifthenelse(0, 255):extract_band(1)
   return image:bandjoin(alpha)
end

local function crop(i)
   if not atlas_cache[i.source] then
      local atlas = vips.Image.new_from_file(i.source)
      if not i.no_alpha then
         atlas = remove_key_color(atlas, {0, 0, 0})
      end
      atlas_cache[i.source] = atlas
   end

   local width = i.width
   local height = i.height
   if i.combine_multiple then
      width = width * (i.count_x or 1)
      height = height * (i.count_y or 1)
   end

   local cropped = atlas_cache[i.source]:extract_area(i.x,
                                                      i.y,
                                                      width,
                                                      height)

   fs.create_directory(fs.parent(i.output))
   cropped:pngsave(i.output)
end

local function convert(i)
   local image = vips.Image.new_from_file(i.source)
   image = remove_key_color(image, {0, 0, 0})
   image:pngsave(i.output)
end

local function preprocess_one(i)
   if i.type == "crop" then
      crop(i)
   elseif i.type == "convert" then
      convert(i)
   else
      error("unknown type " .. tostring(i.type))
   end
end

local function preprocess(list)
   local count = #list
   io.write(string.format("\r%d/%d", 0, count))

   for i, v in ipairs(list) do
      preprocess_one(v)
      io.write(string.format("\r%d/%d", i, count))
   end
   io.write("\n")
end

preprocess(layout.chara)
preprocess(layout.item)
preprocess(layout.feat)
preprocess(layout.area)
preprocess(layout.misc)

preprocess(map_tile.map_tile)

preprocess(portrait.portrait)

preprocess(asset.crop)
preprocess(asset.convert)

print("Finished.")
