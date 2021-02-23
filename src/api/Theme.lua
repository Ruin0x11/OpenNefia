local data = require("internal.data")
local fs = require("util.fs")
local theme = require("internal.theme")

local Theme = {}

local source_extractors = {}

source_extractors["base.asset"] = function(entry)
   if type(entry.image) == "string" then
      return entry.image
   end
   if type(entry.source) == "string" then
      return entry.source
   end

   return nil
end

source_extractors["base.sound"] = function(entry)
   return entry.file
end

-- Extracts the source from an asset intended to be used with `internal.draw.atlas`.
local function extract_atlas_source(entry)
   if type(entry.image) == "string" then
      return entry.image
   end
   if type(entry.image) == "table" then
      if type(entry.image.source) == "string" then
         return entry.image.source
      end
   end

   return nil
end

source_extractors["base.chip"] = extract_atlas_source
source_extractors["base.map_tile"] = extract_atlas_source
source_extractors["base.portrait"] = extract_atlas_source
source_extractors["base.pcc_part"] = extract_atlas_source

local source_setters = {}

source_setters["base.asset"] = function(entry, source)
   if type(entry.image) == "string" then
      entry.image = source
      return
   end
   if type(entry.source) == "string" then
      entry.source = source
      return
   end
end

source_setters["base.sound"] = function(entry, source)
   entry.file = source
end

-- Sets the source for an asset intended to be used with `internal.draw.atlas`.
local function set_atlas_source(entry, source)
   if type(entry.image) == "string" then
      entry.image = source
      return
   end
   if type(entry.image) == "table" then
      if type(entry.image.source) == "string" then
         entry.image.source = source
         return
      end
   end

   return nil
end

source_setters["base.chip"] = set_atlas_source
source_setters["base.map_tile"] = set_atlas_source
source_setters["base.portrait"] = set_atlas_source
source_setters["base.pcc_part"] = set_atlas_source

local function to_filename(path)
   local base = fs.basename(path)
   local parent = fs.basename(fs.parent(path))
   return ("%s/%s"):format(parent, base), parent
end

local function is_in_base(entry)
   local result = string.match(entry._id, "^base%.") or string.match(entry._id, "^elona%.")
   return result
end

local NOT_FOUND = {}

local function find_override_path(source, mod_root_path, cache)
   cache[source] = cache[source] or {}
   if cache[source][mod_root_path] then
      if cache[source][mod_root_path] ~= NOT_FOUND then
         return cache[source][mod_root_path]
      end
      return nil
   end

   local filename, parent = to_filename(source)
   local path = fs.join(mod_root_path, filename)

   if fs.exists(path) then
      cache[source][mod_root_path] = path
      return cache[source][mod_root_path]
   end

   -- Try to find an appropriate subsitute by looking for a file in the
   -- directory with the same basename as the source file, e.g. matching
   -- "^character%." for "character.bmp".
   --
   -- I think this is safe since there's no file that shares its basename with a
   -- different file in the same directory, in the original game files.
   --
   -- TODO: Cache this to speed it up.
   local dir = fs.join(mod_root_path, parent)
   local filename_part = "^" .. fs.filename_part(source) .. "%."

   if not fs.is_directory(dir) then
      cache[source][mod_root_path] = NOT_FOUND
      return nil
   end

   for _, item in fs.iter_directory_items(dir) do
      if item:match(filename_part) then
         cache[source][mod_root_path] = fs.join(dir, item)
         return cache[source][mod_root_path]
      end
   end

   cache[source][mod_root_path] = NOT_FOUND
   return nil
end

-- Generates a table of overrides to be used with a `base.theme`. Intended for
-- use with existing Elona installs that have files like `graphic/character.bmp`
-- or similar in a standard layout.
--
-- You can also substitute in images in PNG or other formats instead and these
-- will be picked up. For example, `graphic/character.png` is accepted as an
-- override for `graphic/character.bmp`.
function Theme.generate_asset_overrides(mod_root_path)
   local supported_types = table.keys(source_extractors)
   local overrides = {}
   local path_cache = {}

   for _, _type in ipairs(supported_types) do
      local extract_source = source_extractors[_type]
      local set_source = source_setters[_type]
      for _, entry in data[_type]:iter():filter(is_in_base) do
         local source = extract_source(entry)
         if source then
            local path = find_override_path(source, mod_root_path, path_cache)
            if path then
               local t = table.deepcopy(entry)
               set_source(t, path)
               overrides[#overrides+1] = t
            end
         end
      end
   end

   return overrides
end

-- Generates all asset overrides from an Elona install. Assumes all files needed
-- for Elona to run (graphic/, sound/, etc.) are present in the mod's directory.
function Theme.generate_all_asset_overrides(mod_root_path)
   return Theme.generate_asset_overrides(mod_root_path)
end

function Theme.is_active(theme_id)
   return theme.is_active(theme_id)
end

return Theme
