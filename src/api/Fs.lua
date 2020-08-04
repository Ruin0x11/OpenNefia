local fs = require("util.fs")

local Fs = {}

Fs.exists = fs.exists
Fs.join = fs.join
Fs.basename = fs.basename

function Fs.open(filepath, mode)
   assert(mode, "mode is required")

   -- love.File:open() does not support "rb"
   mode = mode:gsub("b$", "")

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

return Fs
