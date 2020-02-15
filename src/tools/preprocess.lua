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

local no_alpha = {
}

for _, v in ipairs(no_alpha) do
   no_alpha[v] = true
end

local function preprocess_all(elona_root, mod_root)
   elona_root = fs.normalize(fs.join(elona_root, "graphic"))
   mod_root = fs.normalize(mod_root)

   print(string.format("Converting image files from %s -> %s", elona_root, mod_root))

   for _, item in fs.iter_directory_items(elona_root) do
      local path = fs.join(elona_root, item)
      if fs.is_file(path) then
         local image = vips.Image.new_from_file(path)
         if not no_alpha[item] then
            image = remove_key_color(image, {0, 0, 0})
         end
         local filename = fs.filename_part(item) .. ".png"
         local output = fs.join(mod_root, filename)
         fs.create_directory(fs.parent(output))
         image:pngsave(output)
      end
   end

   print("Finished.")
end

return preprocess_all
