local Rand = require("api.Rand")
local Log = require("api.Log")
local paths = require("internal.paths")
local fs = require("util.fs")
local env = require("internal.env")
local tsort = require("thirdparty.resty.tsort")
local main_state = require("internal.global.main_state")

if env.is_hotloading() then
   return "no_hotload"
end

local mod = {}

local MOD_DIR = "mod"

local function load_mod(mod_name, root_path)
   local init_lua_path = fs.find_loadable(root_path, "init")
   local chunk, err

   if init_lua_path then
      local req_path = paths.convert_to_require_path(init_lua_path)

      -- Reset the random seed before loading each mod loading can
      -- always be deterministic.
      Rand.set_seed(0)

      main_state.currently_loading_mod = mod_name
      chunk, err = env.safe_require(req_path)
      main_state.currently_loading_mod = nil

      if err then
         return nil, err
      end

      -- Mods are not expected to return anything in init.lua.
      package.loaded[req_path] = true

      Log.info("Loaded mod %s to %s.", mod_name, req_path)
   else
      Log.info("Loaded mod %s without init.lua.", mod_name)
   end

   main_state.loaded_mods[mod_name] = true

   return chunk
end

function mod.is_loaded(mod_name)
   return not not main_state.loaded_mods[mod_name]
end

local function load_manifest(manifest_path)
   if not fs.is_file(manifest_path) then
      return false, "Cannot find mod manifest at " .. manifest_path
   end

   local chunk, err = love.filesystem.load(manifest_path)
   if chunk == nil then
      return false, err
   end
   setfenv(chunk, {})
   local success, manifest = xpcall(chunk, function(err) return debug.traceback(err, 2) end)
   if success == false then
      local err = manifest
      return success, err
   end
   if type(manifest) ~= "table" then
      return false, (("Manifest must be table (got %s): %s"):format(type(manifest), manifest_path))
   end

   local valid_keys = {
      id = { required = true },
      dependencies = { required = true },
      version = { required = true }
   }
   for k, _ in pairs(manifest) do
      if not valid_keys[k] then
         return false, ("Invalid manifest key '%s': %s"):format(k, manifest_path)
      else
         valid_keys[k].seen = true
      end
   end
   for k, v in pairs(valid_keys) do
      if v.required and not v.seen then
         return false, ("Missing required manifest key '%s': %s"):format(k, manifest_path)
      end
   end

   return true, manifest
end

local function extract_mod_id(manifest_file)
   local r, count = string.gsub(manifest_file, ".+/([^/]+)/mod.%lua$", "%1")
   if count == 0 then
      return nil
   end

   return r
end

function mod.calculate_load_order(mods)
   local graph = tsort.new()

   -- topsort sorts by mod ID (a string), but we also need to preserve
   -- the file location of each manifest, so reassociate them after
   -- sorting.
   local paths = {}
   local seen = {}

   for _, manifest_file in ipairs(mods) do
      local success, manifest = load_manifest(manifest_file)
      if not success then
         local err = manifest
         error(string.format("Error initializing %s:\n\t%s", manifest.id, err))
      end

      local mod_id = manifest.id
      if type(mod_id) ~= "string" then
         error(string.format("Manifest must contain 'id' field. (%s)", manifest_file))
      end

      if seen[mod_id] then
         error(("Mod %s was registered twice."):format(mod_id))
      end
      seen[mod_id] = true

      if type(manifest.dependencies) == "table" then
         graph:add(0, mod_id) -- root
         for dep_id, version in pairs(manifest.dependencies) do
            graph:add(dep_id, mod_id)
         end
      else
         error("Manifest must specify dependencies. " .. mod_id)
      end

      paths[mod_id] = { root_path = fs.parent(manifest_file), id = mod_id }
   end

   local order, cycle = graph:sort()
   if order == nil then
      error(("Circular dependency: %s"):format(inspect(cycle)))
   end

   table.remove(order, 1)

   -- Associate mod IDs with the root path containing mod.lua/init.lua
   -- while preserving load order
   local final = {}
   for _, mod_id in ipairs(order) do
      final[#final+1] = paths[mod_id]
   end

   return final
end

function mod.scan_mod_dir()
   local mods = {}

   for _, mod_id in fs.iter_directory_items(MOD_DIR .. "/") do
      local manifest_file = fs.find_loadable(MOD_DIR, mod_id, "mod")
      if manifest_file then
         mods[#mods+1] = manifest_file
      end
   end

   return mods
end

-- Called when hotloading code from a mod that has not been loaded
-- yet. Checks the manifest to ensure all the mod's dependencies are
-- loaded first.
function mod.hotload_mod(mod_id, root_path)
   root_path = root_path or fs.join(MOD_DIR, mod_id)
   local manifest_file = fs.find_loadable(root_path, "mod")
   if not manifest_file then
      return false, "No mod manifest found."
   end
   local ok, manifest = load_manifest(manifest_file)
   if not ok then
      return ok, manifest
   end

   assert(manifest.id == mod_id, "Mod ID must match manifest ID")

   for dep_id, version in pairs(manifest.dependencies) do
      -- TODO check version
      if not mod.is_loaded(dep_id) then
         return false, ("Mod dependency '%s' of mod '%s' is not loaded."):format(dep_id, mod_id)
      end
   end

   Log.info("Hotloading mod %s at %s", mod_id, root_path)
   return load_mod(mod_id, root_path)
end

function mod.load_mods(mods)
   local load_order = mod.calculate_load_order(mods)

   local mod_names = table.concat(fun.iter(load_order):extract("id"):to_list(), " ")
   Log.info("Loading mods: %s", mod_names)

   for _, m in ipairs(load_order) do
      local chunk, err = mod.hotload_mod(m.id, m.root_path)
      if err then
         error(err)
      end
   end

   Rand.set_seed()
end

function mod.iter_loaded()
   local all = mod.scan_mod_dir()
   local load_order = mod.calculate_load_order(all)
   local mods_loaded = fun.iter(load_order):filter(function(mod) return main_state.loaded_mods[mod.id] end):to_list()
   return fun.iter(mods_loaded)
end

return mod
