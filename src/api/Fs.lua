local fs = require("util.fs")

local Fs = {}

Fs.exists = fs.exists
Fs.join = fs.join

function Fs.open(file, mode)
   -- TODO: needs to use physfs
   assert(mode, "mode is required")
   return io.open(file, mode)
end

function Fs.read_all(file)
   local f, err = Fs.open(file, "rb")
   if f == nil then
      return nil, err
   end
   local content = f:read("*all")
   f:close()
   return content
end

return Fs
