local fs = {}

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

local function string_split(str,sep)
   sep = sep or "\n"
   local ret={}
   local n=1
   for w in str:gmatch("([^"..sep.."]*)") do
      ret[n] = ret[n] or w
      if w=="" then
         n = n + 1
      end
   end
   return ret
end

if not love or love.getVersion() == "lovemock" then
   local lfs = require("lfs")
   fs.get_directory_items = function(dir)
      local items = {}
      for path in lfs.dir(dir) do
         if path ~= "." and path ~= ".." then
            items[#items+1] = path
         end
      end
      return items
   end
   fs.get_info = function(path)
      local attrs = lfs.attributes(path)
      if attrs == nil then return nil end

      return {
         type = attrs.mode
      }
   end
   fs.get_save_directory = function()
      return "/tmp/save"
   end
   fs.create_directory = function(name)
      if love then
         name = fs.join(fs.get_save_directory(), name)
      end
      local path = string_split(name, dir_sep)[1] .. dir_sep
      if not fs.is_root(path) then
         path = ""
      end
      for dir in string.gmatch(name, "[^\"" .. dir_sep .. "\"]+") do
         path = path .. dir .. dir_sep
         lfs.mkdir(path)
      end
      return path
   end
   fs.read = function(name, size)
      if love then
         name = fs.join(fs.get_save_directory(), name)
      end
      local f = io.open(name, "r")
      local data = f:read(size or "*all")
      f:close()
      return data, nil
   end
   fs.write = function(name, data, size)
      if love then
         name = fs.join(fs.get_save_directory(), name)
      end
      local f = io.open(name, "w")
      f:write(data)
      f:close()
      return true, nil
   end
else
   fs.get_directory_items = love.filesystem.getDirectoryItems
   fs.get_info = love.filesystem.getInfo
   fs.get_save_directory = love.filesystem.getSaveDirectory
   fs.create_directory = love.filesystem.createDirectory
   fs.write = love.filesystem.write
   fs.read = love.filesystem.read
end

function fs.iter_directory_items(dir)
   return ipairs(fs.get_directory_items(dir))
end

function fs.exists(path)
   return fs.get_info(path) ~= nil
end

function fs.is_directory(path)
   local info = fs.get_info(path)
   return info ~= nil and info.type == "directory"
end

function fs.is_file(path)
   local info = fs.get_info(path)
   return info ~= nil and info.type == "file"
end

function fs.basename(path)
   return string.gsub(path, "(.*/)(.*)", "%2")
end

function fs.filename_part(path)
   return string.gsub(fs.basename(path), "(.*)%..*", "%1")
end

function fs.extension_part(path)
   return string.gsub(fs.basename(path), ".*%.(.*)", "%1")
end

function fs.parent(path)
   return string.match(path, "^(.+)" .. dir_sep)
end

function fs.is_root(path)
   if is_windows then
      return string.match(path, "^[a-zA-Z]:\\$")
   else
      return path == "/"
   end
end

function fs.copy(from, to)
   if not fs.is_file(from) then
      return false, string.format("file not found or is directory: %s", from)
   end

   local content, err = fs.read(from)
   if not content then
      return false, string.format("error reading file %s: %s", from, err)
   end

   fs.create_directory(fs.parent(to))

   return fs.write(to, content)
end


--
-- These functions are from luacheck.
--

local function ensure_dir_sep(path)
   if string.sub(path, -1) ~= dir_sep then
      return path .. dir_sep
   end

   return path
end

function fs.split_base(path)
   if is_windows then
      if string.match(path, "^%a:\\") then
         return string.sub(path, 1, 3), string.sub(path, 4)
      else
         -- Disregard UNC paths and relative paths with drive letter.
         return "", path
      end
   else
      if string.match(path, "^/") then
         if string:match(path, "^//") then
            return "//", string.sub(path, 3)
         else
            return "/", string.sub(path, 2)
         end
      else
         return "", path
      end
   end
end

function fs.is_absolute(path)
   return fs.split_base(path) ~= ""
end

local function join_two_paths(base, path)
   if base == "" or fs.is_absolute(path) then
      return path
   else
      return ensure_dir_sep(base) .. path
   end
end

function fs.join(base, ...)
   local res = base

   for i = 1, select("#", ...) do
      res = join_two_paths(res, select(i, ...))
   end

   return res
end

return fs
