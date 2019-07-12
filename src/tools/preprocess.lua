local vips = require("vips")
assert(vips)

local layout = require("tools.layout.chip")
local map_tile = require("tools.layout.map_tile")
local portrait = require("tools.layout.portrait")
local asset = require("tools.layout.asset")

local fs = require("util.fs")

local atlas_cache = {}

local elona_root = arg[1]
local mod_root = arg[2]
assert(elona_root, "Provide the root of an elona install.")
assert(mod_root, "Provide the root of a mod to output to.")

local function remove_key_color(image, key_color)
   if image:bands() == 4 then
      key_color[4] = 0
   end
   local alpha = image:equal(key_color):ifthenelse(0, 255):extract_band(1)
   return image:bandjoin(alpha)
end

local function crop(i)
   local source = fs.join(elona_root, i.source)
   if not atlas_cache[source] then
      local atlas = vips.Image.new_from_file(source)
      if not i.no_alpha then
         atlas = remove_key_color(atlas, {0, 0, 0})
      end
      atlas_cache[source] = atlas
   end

   local width = i.width
   local height = i.height
   if i.combine_multiple then
      width = width * (i.count_x or 1)
      height = height * (i.count_y or 1)
   end

   local cropped = atlas_cache[source]:extract_area(i.x,
                                                      i.y,
                                                      width,
                                                      height)

   local output = fs.join(mod_root, i.output)
   fs.create_directory(fs.parent(output))
   cropped:pngsave(output)
end

local function convert(i)
   local source = fs.join(elona_root, i.source)
   local image = vips.Image.new_from_file(source)
   if not i.no_alpha then
      image = remove_key_color(image, {0, 0, 0})
   end
   local output = fs.join(mod_root, i.output)
   fs.create_directory(fs.parent(output))
   image:pngsave(output)
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
