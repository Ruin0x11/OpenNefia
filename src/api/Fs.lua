local fs = require("util.fs")
local paths = require("internal.paths")

local Fs = {}

Fs.exists = fs.exists
Fs.join = fs.join
Fs.basename = fs.basename
Fs.filename_part = fs.filename_part
Fs.extension_part = fs.extension_part
Fs.convert_to_require_path = paths.convert_to_require_path
Fs.get_working_directory = fs.get_working_directory

function Fs.open(filepath, mode)
   assert(mode, "mode is required")

   -- love.File:open() does not support "rb"
   mode = mode:gsub("b$", "")

   if fs.get_global_working_directory() and not fs.is_absolute(filepath) then
      filepath = fs.join(Fs.get_working_directory(), filepath)
   end

   local file = love.filesystem.newFile(filepath)
   local ok, err = file:open(mode)
   if not ok and err then
      return nil, err
   end
   return file, nil
end

function Fs.read_all(filepath)
   local f, err = Fs.open(filepath, "r")
   if f == nil then
      return nil, err
   end
   local content, err = f:read()
   if content == nil then
      return nil, err
   end
   f:close()
   return content
end

function Fs.iter_directory_items(dir, mode)
   local iter = fun.wrap(fs.iter_directory_items(dir))
   if mode == "full_path" then
      iter = iter:map(function(f) return Fs.join(dir, f) end)
   end
   return iter
end

return Fs
