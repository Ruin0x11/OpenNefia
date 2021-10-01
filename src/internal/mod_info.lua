local fs = require("util.fs")
local tsort = require("thirdparty.resty.tsort")

local mod_info = {}

local MOD_DIR = "mod"

function mod_info.load_manifest(manifest_path)
   if not fs.is_file(manifest_path) then
      return nil, "Cannot find mod manifest at " .. manifest_path
   end

   local chunk, err = love.filesystem.load(manifest_path)
   if chunk == nil then
      return nil, err
   end
   setfenv(chunk, {})
   local ok, manifest = xpcall(chunk, function(err) return debug.traceback(err, 2) end)
   if not ok then
      local err = manifest
      return nil, err
   end
   if type(manifest) ~= "table" then
      return nil, (("Manifest must be table (got %s): %s"):format(type(manifest), manifest_path))
   end

   local valid_keys = {
      id = { required = true },
      description = { required = false }, -- TODO make required?
      dependencies = { required = true },
      version = { required = true }
   }
   for k, _ in pairs(manifest) do
      if not valid_keys[k] then
         return nil, ("Invalid manifest key '%s': %s"):format(k, manifest_path)
      else
         valid_keys[k].seen = true
      end
   end
   for k, v in pairs(valid_keys) do
      if v.required and not v.seen then
         return nil, ("Missing required manifest key '%s': %s"):format(k, manifest_path)
      end
   end
   if type(manifest.dependencies) ~= "table" then
      error("Manifest must specify dependencies. " .. manifest.id)
   end

   return manifest, nil
end

function mod_info.read_mod_info(manifest_file)
   local manifest, err = mod_info.load_manifest(manifest_file)
   if not manifest then
      error(string.format("Error initializing %s:\n\t%s", manifest_file, err))
   end

   local mod_id = manifest.id
   if type(mod_id) ~= "string" then
      error(string.format("Manifest must contain 'id' field. (%s)", manifest_file))
   end

   return { manifest_path = manifest_file, root_path = fs.parent(manifest_file), id = mod_id, manifest = manifest }
end

function mod_info.calculate_load_order(mods)
   local graph = tsort.new()

   -- topsort sorts by mod ID (a string), but we also need to preserve
   -- the file location of each manifest, so reassociate them after
   -- sorting.
   local paths = {}
   local seen = {}

   for _, mod_info in ipairs(mods) do
      local mod_id = mod_info.id

      if seen[mod_id] then
         error(("Mod %s was registered twice."):format(mod_id))
      end
      seen[mod_id] = true

      graph:add(0, mod_id) -- root
      for dep_id, version in pairs(mod_info.manifest.dependencies) do
         graph:add(dep_id, mod_id)
      end

      paths[mod_id] = mod_info
   end

   local order, cycle = graph:sort()
   if order == nil then
      error(("Circular dependency: %s"):format(inspect(cycle)))
   end

   table.remove(order, 1)

   -- Associate mod IDs with the root path containing mod_info.lua/init.lua
   -- while preserving load order
   local final = {}
   for _, mod_id in ipairs(order) do
      final[#final+1] = paths[mod_id]
   end

   return final
end

-- We will not expect that mod folders will be moved after the game has been
-- booted.
local manifest_cache = {}

function mod_info.get_mod_info(mod_id)
   if manifest_cache[mod_id] then
      return manifest_cache[mod_id]
   end

   local manifest_file = fs.find_loadable(MOD_DIR, mod_id, "mod")
   if not manifest_file then
      error(("Could not find mod manifest for " .. mod_id .. " in folder %s."):format(fs.join(MOD_DIR, mod_id)))
   end
   local info = mod_info.read_mod_info(manifest_file)
   manifest_cache[mod_id] = info

   return info
end

--- @tparam table mod_ids list of mod_ids to scan for
function mod_info.scan_mod_dir(mod_ids)
   if mod_ids == nil then
      -- Loop through src/mods/ and assume the directory names correspond to mod
      -- IDs.
      mod_ids = {}
      for _, mod_id in fs.iter_directory_items(MOD_DIR .. "/") do
         mod_ids[#mod_ids+1] = mod_id
      end
   else
      mod_ids = table.shallow_copy(mod_ids)
   end

   local mods = {}

   while #mod_ids > 0 do
      local mod_id = mod_ids[#mod_ids]
      mod_ids[#mod_ids] = nil

      if mods[mod_id] == nil then
         local mod_info = mod_info.get_mod_info(mod_id)
         mods[mod_id] = mod_info

         for dep_id, version in pairs(mod_info.manifest.dependencies) do
            mod_ids[#mod_ids+1] = dep_id
         end
      end
   end

   return table.values(mods)
end

local MOD_ID_REGEX = "^[a-z][_a-z0-9]*$"
function mod_info.is_valid_mod_identifier(mod_id)
   return mod_id:match(MOD_ID_REGEX) ~= nil
end

return mod_info
