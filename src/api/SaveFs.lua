local binser = require("thirdparty.binser")
local fs = require("internal.fs")

local SaveFile = class.class("SaveFile")

function SaveFile:init()
   self.name = "test"
   self.dir = fs.join(fs.get_save_directory(), self.name)
end

function SaveFile:save()
end

function SaveFile:load()
end

local SaveFs = {}

function SaveFs.current()
   return SaveFile:new()
end

local function compress(str)
   return love.data.compress("string", "gzip", str, -1)
end

local function decompress(dat)
   return love.data.decompress("string", "gzip", dat)
end

local function serialize(obj)
   return compress(binser.serialize(obj))
end

local function deserialize(str)
   return binser.deserialize(decompress(str))[1]
end

function SaveFs.write(path, obj)
   local str = serialize(obj)
   local dirs = fs.parent(path)
   if dirs then
      fs.create_directory(dirs)
   end
   return fs.write(path, str)
end

function SaveFs.read(path)
   if not fs.exists(path) then
      return false, "file does not exist"
   end
   local content, err = fs.read(path)
   if not content then
      return false, err
   end
   return true, deserialize(content)
end

return SaveFs
