local fs = require("util.fs")

local Fs = {}

Fs.exists = fs.exists
Fs.join = fs.join

function Fs.open(file, mode)
   -- TODO: needs to use physfs
   return io.open(file, mode)
end

return Fs
