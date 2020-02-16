local vips = require("vips")
assert(vips)

local fs = require("util.fs")

local function remove_key_color(image, key_color)
   if image:bands() == 4 then
      key_color[4] = 0
   end
   local alpha = image:equal(key_color):ifthenelse(0, 255):bandor()
   return image:bandjoin(alpha)
end

local key_colors = {
   ["title.bmp"] = "none",
   ["void.bmp"] = "none",
}

local function preprocess_all(elona_root, mod_root)
   elona_root = fs.normalize(fs.join(elona_root, "graphic"))
   mod_root = fs.normalize(mod_root)

   print(string.format("Converting image files from %s -> %s", elona_root, mod_root))

   for _, item in fs.iter_directory_items(elona_root) do
      local path = fs.join(elona_root, item)
      if fs.is_file(path) then
         local image = vips.Image.new_from_file(path)

         local key_color = key_colors[item] or {0, 0, 0}
         if key_color ~= "none" then
            image = remove_key_color(image, key_color)
         end
         local filename = fs.filename_part(item) .. ".png"
         local output = fs.join(mod_root, filename)
         print(("%s -> %s"):format(path, output))
         fs.create_directory(fs.parent(output))
         image:pngsave(output)
      end
   end

   print("Finished.")
end

return preprocess_all
