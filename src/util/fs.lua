local fs = {}

local dir_sep = package.config:sub(1,1)
local is_windows = dir_sep == "\\"

-- LOVE always expects the directory separator to be forward slash ('/').
dir_sep = "/"

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
   assert(lfs, "luafilesystem not installed")
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
      local other_path = path
      if love then
         other_path = fs.join(fs.get_save_directory(), path)
      end
      local attrs = lfs.attributes(other_path)
      if attrs == nil then
         attrs = lfs.attributes(path)
         if attrs == nil then
            return nil
         end
      end

      return {
         type = attrs.mode,
         size = attrs.size,
         modtime = attrs.modification
      }
   end
   fs.get_save_directory = function()
      return fs.join(fs.get_temporary_directory(), ".local", "share", "love", "Elona_next")
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
         -- avoid appending the root directory ("C:") on windows; it results in "C:\C:\the\path"
         local do_create = not is_windows or (is_windows and not string.match(dir, "^[a-zA-Z]:$"))

         if do_create then
            path = path .. dir .. dir_sep
            lfs.mkdir(path)
         end
      end
      return path
   end
   fs.read = function(name, size)
      if love then
         name = fs.join(fs.get_save_directory(), name)
      end
      assert(fs.exists(name), ("file does not exist: %s"):format(name))
      local f = io.open(name, "rb")
      local data = f:read(size or "*all")
      f:close()
      return data, nil
   end
   fs.write = function(name, data, size)
      if love then
         name = fs.join(fs.get_save_directory(), name)
      end
      local f = io.open(name, "wb")
      assert(f, ("could not open %s"):format(name))
      f:write(data)
      f:close()
      return true, nil
   end
   fs.remove = function(name)
      if love then
         name = fs.join(fs.get_save_directory(), name)
      end

      return os.remove(name)
   end
   fs.get_working_directory = lfs.currentdir

   fs.attributes = lfs.attributes
else
   fs.get_directory_items = love.filesystem.getDirectoryItems
   fs.get_info = love.filesystem.getInfo
   fs.get_save_directory = love.filesystem.getSaveDirectory
   fs.create_directory = love.filesystem.createDirectory
   fs.write = love.filesystem.write
   fs.read = love.filesystem.read
   fs.remove = love.filesystem.remove
   fs.get_working_directory = love.filesystem.getWorkingDirectory

   fs.attributes = function(filepath, aname, atable)
      filepath = string.gsub(filepath, "^%.[/\\]", "")
      filepath = string.gsub(filepath, "\\", "/")
      filepath = string.strip_prefix(filepath, fs.get_working_directory() .. "/")
      local info = love.filesystem.getInfo(filepath)
      if info == nil then
         return nil, "file does not exist"
      end

      if info.type == "symlink" then
         info.type = "link"
      end

      info.mode = info.type
      info.type = nil

      if aname then
         info = info[aname]
      end

      return info
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
   return string.gsub(path, "(.*" .. dir_sep .. ")(.*)", "%2")
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

function fs.copy_directory(from, to)
   if not fs.is_directory(from) then
      return false, string.format("file not found or is not directory: %s", from)
   end

   local last_dir = fs.basename(from)
   local to = fs.join(to, last_dir)
   fs.create_directory(to)

   for _, entry in fs.iter_directory_items(from) do
      local from_item = fs.join(from, entry)
      local to_item = fs.join(to, entry)

      if fs.is_file(from_item) then
         local success, err = fs.copy(from_item, to_item)
         if not success then
            return success, err
         end
      elseif fs.is_directory(from_item) then
         fs.create_directory(to_item)
         local success, err = fs.copy_directory(from_item, to_item)
         if not success then
            return success, err
         end
      end
   end

   return true, nil
end

function fs.get_temporary_directory()
   if is_windows then
      -- os.tmpname() doesn't include %TEMP% on Windows
      return os.getenv("TEMP")
   else
      return fs.parent(os.tmpname())
   end
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
         if string.match(path, "^//") then
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

function fs.normalize(path)
   -- if is_windows then
   --    path = path:lower()
   -- end
   path = path:gsub("[/\\]", dir_sep)
   local base, rest = fs.split_base(path)

   local parts = {}

   for part in rest:gmatch("[^"..dir_sep.."]+") do
      if part ~= "." then
         if part == ".." and #parts > 0 and parts[#parts] ~= ".." then
            parts[#parts] = nil
         else
            parts[#parts + 1] = part
         end
      end
   end

   if base == "" and #parts == 0 then
      return "."
   else
      return base..table.concat(parts, dir_sep)
   end
end

function fs.join(base, ...)
   local res = base

   for i = 1, select("#", ...) do
      res = join_two_paths(res, select(i, ...))
   end

   res = fs.normalize(res)

   return res
end

return fs
