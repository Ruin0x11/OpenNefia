local fs = require("util.fs")

local Fs = {}

Fs.exists = fs.exists
Fs.join = fs.join

function Fs.open(filepath, mode)
   assert(mode, "mode is required")

   -- love.File:open() does not support "rb"
   mode = mode:gsub("b$", "")

   local file = love.filesystem.newFile(filepath)
   file:open(mode)
   return file
end

function Fs.read_all(filepath)
   local f, err = Fs.open(filepath, "r")
   if f == nil then
      return nil, err
   end
   local content = f:read()
   f:close()
   return content
end

return Fs
