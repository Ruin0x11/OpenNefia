local fs = {}

-- TODO: stub out with lfs if not running with love runtime

if IS_LOVE then
   fs.get_directory_items = love.filesystem.getDirectoryItems
   fs.get_info = love.filesystem.getInfo
else
   local lfs = require("lfs")
   fs.get_directory_items = function(dir)
      local items = {}
      for path in lfs.dir(dir) do
         items[#items+1] = path
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
   return string.gsub(fs.basename(path), "(.*)%.(.*)", "%1")
end

function fs.extension_part(path)
   return string.gsub(fs.basename(path), "(.*)%.(.*)", "%2")
end


--
-- These functions are from luacheck.
--

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

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
