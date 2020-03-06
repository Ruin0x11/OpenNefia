local binser = require("thirdparty.binser")
local fs = require("util.fs")
local Log = require("api.Log")

--- @module SaveFs
local SaveFs = {}

local function compress(str)
   if love.data == nil then
      return str
   end
   return love.data.compress("string", "gzip", str, -1)
end

local function decompress(dat)
   if love.data == nil then
      return dat
   end
   return love.data.decompress("string", "gzip", dat)
end

function SaveFs.serialize(obj)
   return compress(binser.serialize(obj))
end

function SaveFs.deserialize(str)
   return binser.deserialize(decompress(str))[1]
end

local touched_paths = {}
local current_save

function SaveFs.save_path(child_path, save_name)
   -- when using love.filesystem.write, all paths are already relative to the save directory.
   -- passing absolute paths will result in errors.
   local dir = ""

   if save_name == nil then
      return fs.join(dir, "temp", child_path)
   end

   return fs.join(dir, "save", save_name, child_path)
end

local function load_path(child_path, save_name)
   if save_name == nil then
      if current_save and not touched_paths[child_path] then
         local path = SaveFs.save_path(child_path, current_save)
         if fs.exists(path) then
            Log.debug("Save cache hit: %s/%s", current_save, child_path)
            return path
         end
      end
   end

   return SaveFs.save_path(child_path, save_name)
end

function SaveFs.write(path, obj, save)
   local full_path = SaveFs.save_path(path, save)

   local str = SaveFs.serialize(obj)
   local dirs = fs.parent(full_path)
   if dirs then
      fs.create_directory(dirs)
   end
   Log.trace("savefs write: %s", full_path)

   local ok, err = fs.write(full_path, str)

   touched_paths[path] = true

   return ok, err
end

function SaveFs.read(path, save)
   local full_path = load_path(path, save)

   if not fs.exists(full_path) then
      return false, ("file does not exist: %s"):format(full_path)
   end
   Log.trace("savefs read: %s", full_path)
   local content, err = fs.read(full_path)
   if not content then
      return false, err
   end

   local result = SaveFs.deserialize(content)

   return true, result
end

function SaveFs.exists(path, save)
   local full_path = load_path(path, save)
   return fs.exists(full_path)
end

-- Saves are handled the same as in vanilla. When a map is exited, it
-- is saved in the temporary working save location. When the player
-- wants to save the game, the profile folder to save to is replaced
-- with the contents of the working save exactly.

-- The temporary save is needed since if a map is saved on exit, the
-- player still needs to be able to restore the save from a previous
-- snapshot undoing the map saves that have happened since the last
-- snapshot.

-- This is enhanced to support smart loading without copying all the
-- files touched on every save.
--
-- 1. Keep track of everything saved so far.
-- 2. When a load is requested, wipe the list of known save items.
-- 3. The next time a save is loaded, check if it has not been loaded
--    again since the last full load. If so, load the file from the
--    profile instead of the temporary directory.

--- Saves the working save data to a saved profile.
function SaveFs.save_game(save)
   assert(save)

   Log.info("Copying save to %s", save)

   for path, _ in pairs(touched_paths) do
      local temp_path = SaveFs.save_path(path, nil)
      local full_path = SaveFs.save_path(path, save)
      assert(fs.copy(temp_path, full_path))
   end
end

--- Invalidates the temporary save cache. The next time a file is read
--- for the first time, it will be read from the profile instead.
function SaveFs.load_game(save)
   assert(type(save) == "string")

   Log.info("Setting save cache to %s", save)

   current_save = save
   touched_paths = {}
end

function SaveFs.clear()
   Log.info("Clearing save cache")

   current_save = nil
   touched_paths = {}
end

return SaveFs
