local Rand = require("api.Rand")
local Log = require("api.Log")
local paths = require("internal.paths")
local fs = require("util.fs")
local env = require("internal.env")
local main_state = require("internal.global.main_state")
local mod_info = require("internal.mod_info")

if env.is_hotloading() then
   return "no_hotload"
end

local mod = {}

local function load_mod(mod_name, root_path)
   local init_lua_path = fs.find_loadable(root_path, "init")
   local chunk, err

   if init_lua_path then
      local Stopwatch = require("api.Stopwatch")
      local sw = Stopwatch:new()
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

      Log.debug("Loaded mod %s to %s in %02.02f ms.", mod_name, req_path, sw:measure())
   else
      Log.debug("Loaded mod %s without init.lua.", mod_name)
   end

   main_state.loaded_mods[mod_name] = true

   return chunk
end

function mod.is_loaded(mod_name)
   return not not main_state.loaded_mods[mod_name]
end


-- Called when hotloading code from a mod that has not been loaded
-- yet. Checks the manifest to ensure all the mod's dependencies are
-- loaded first.
function mod.hotload_mod(mod_id, manifest_path)
   local manifest, err = mod_info.load_manifest(manifest_path)
   if not manifest then
      return nil, err
   end

   assert(manifest.id == mod_id, "Mod ID must match manifest ID")
   assert(mod_info.is_valid_mod_identifier(mod_id), "Mod ID must start with a letter and consist of letters, numbers or underscores only")

   for dep_id, version in pairs(manifest.dependencies) do
      -- TODO check version
      if not mod.is_loaded(dep_id) then
         return false, ("Mod dependency '%s' of mod '%s' is not loaded."):format(dep_id, mod_id)
      end
   end

   local root_path = fs.parent(manifest_path)
   Log.debug("Hotloading mod %s at %s", mod_id, root_path)
   return load_mod(mod_id, root_path)
end

function mod.load_mods(mods)
   local Stopwatch = require("api.Stopwatch")
   local sw = Stopwatch:new()

   local load_order = mod_info.calculate_load_order(mods)
   local mod_names = table.concat(fun.iter(load_order):extract("id"):to_list(), " ")
   Log.info("Loading mods: %s", mod_names)

   for _, m in ipairs(load_order) do
      local mod_sw = Stopwatch:new()
      local chunk, err = mod.hotload_mod(m.id, m.manifest_path)
      if err then
         error(err)
      end
      Log.debug("   %s: %02.02fms", m.id, mod_sw:measure())
   end

   Log.info("Loaded mods in %02.02fms.", sw:measure())

   Rand.set_seed()
end

function mod.iter_loaded()
   local all = mod_info.scan_mod_dir()
   local load_order = mod_info.calculate_load_order(all)
   local mods_loaded = fun.iter(load_order):filter(function(mod) return main_state.loaded_mods[mod.id] end):to_list()
   return fun.iter(mods_loaded)
end

return mod
