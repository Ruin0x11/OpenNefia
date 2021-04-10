local fs = require("util.fs")

local function is_locale_path(path)
   return path:match("/locale$")
end

for _, path in fun.wrap(fs.iter_directory_items("mod", true)):filter(is_locale_path) do
   local full_path = fs.join("mod", path)
   for _, locale_dir in fun.wrap(fs.iter_directory_items(full_path)) do
      local root = fs.join(full_path, locale_dir)
      local base = fs.join(root, "base")
      fs.create_directory(base)
      for _, file in fun.wrap(fs.iter_directory_items(root)) do
         local full_file = fs.join(root, file)
         fs.move(full_file, fs.join(base, file))
      end
   end
end
