local Log = require("api.Log")
local fs = require("util.fs")
local env = require("internal.env")
local tsort = require("thirdparty.resty.tsort")

if env.is_hotloading() then
   return "no_hotload"
end

local mod = {}

local loaded = {}

local function load_mod(mod_name, init_lua_path)
   local req_path = env.convert_to_require_path(init_lua_path)

   local chunk, err = env.load_sandboxed_chunk(req_path, mod_name)

   if err then
      error(err, 0)
   end

   Log.info("Loaded mod %s to %s.", mod_name, req_path)

   -- Mods are not expected to return anything in init.lua.
   package.loaded[req_path] = true

   return chunk
end

local function load_manifest(manifest_path)
   local chunk, err = loadfile(manifest_path)
   if chunk == nil then
      error(err)
   end
   setfenv(chunk, {})
   local success, manifest = xpcall(chunk, function(err) return debug.traceback(err, 2) end)
   if success == false then
      local err = manifest
      return success, err
   end
   if type(manifest) ~= "table" then
      error("Manifest must be table (" .. manifest_path .. ")")
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

   for _, manifest_file in ipairs(mods) do
      local success, manifest = load_manifest(manifest_file)
      if not success then
         local err = manifest
         error(string.format("Error initializing %s:\n\t%s", mod_id, err))
      end

      local mod_id = manifest.id
      if type(mod_id) ~= "string" then
         error(string.format("Manifest must contain 'id' field. (%s)", manifest_file))
      end

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

   local order = graph:sort()
   if order == nil then
      error("Circular dependency")
   end

   table.remove(order, 1)

   -- Associate mod IDs with the root path containing mod.lua/init.lua
   -- while preserving load order
   local final = {}
   for i, mod_id in ipairs(order) do
      final[#final+1] = paths[mod_id]
   end

   return final
end

function mod.scan_mod_dir()
   local mods = {}

   for _, mod_id in fs.iter_directory_items("mod/") do
      local manifest_file = fs.join("mod", mod_id, "mod.lua")
      if fs.is_file(manifest_file) then
         mods[#mods+1] = manifest_file
      end
   end

   return mods
end

function mod.load_mods(mods)
   local load_order = mod.calculate_load_order(mods)

   Log.info("Loading mods: %s", inspect(load_order))

   for _, mod in ipairs(load_order) do
      local manifest = fs.join(mod.root_path, "mod.lua")
      if not fs.is_file(manifest) then
         error("Cannot find mod dependency " .. mod.id)
      end

      local init = fs.join(mod.root_path, "init.lua")
      if fs.is_file(init) then
         if loaded[mod.id] then
            error("Mod '" .. mod.id .. "' is already loaded.")
         end

         load_mod(mod.id, init)

         loaded[mod.id] = true
      else
         Log.info("No init.lua for mod %s.", mod.id)
      end
   end
end

function mod.iter_loaded()
   local all = mod.scan_mod_dir()
   local load_order = mod.calculate_load_order(all)
   local mods_loaded = fun.iter(load_order):filter(function(mod) return loaded[mod.id] end):to_list()
   return fun.iter(mods_loaded)
end

return mod
