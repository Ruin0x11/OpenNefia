local data = require("internal.data")
local fs = require("internal.fs")
local env = require("internal.env")
local tsort = require("thirdparty.resty.tsort")

local mod = {}

local chunks = {}

local function load_mod(mod_name, init_lua_path)
   -- Convert the filename to the dot syntax expected by
   -- package.searchpath.
   init_lua_path = string.gsub(init_lua_path, "/", ".")
   init_lua_path = string.strip_suffix(init_lua_path, ".lua")

   local success, chunk = xpcall(
      function() return env.load_sandboxed_chunk(init_lua_path, mod_name) end,
      function(err) return debug.traceback(err, 2) end
   )
   return success, chunk
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

function mod.calculate_load_order()
   local graph = tsort.new()

   for _, mod_id in fs.iter_directory_items("mod/") do
      local manifest_file = fs.join("mod", mod_id, "mod.lua")
      if fs.is_file(manifest_file) then
         local success, manifest = load_manifest(manifest_file)
         if not success then
            local err = manifest
            error(string.format("Error initializing %s:\n\t%s", mod_id, err))
         end

         if type(manifest.dependencies) == "table" then
            for dep_id, version in pairs(manifest.dependencies) do
               graph:add(dep_id, mod_id)
            end
         else
            error("Manifest must specify dependencies. " .. mod_id)
         end
      end
   end

   return graph:sort()
end

function mod.load_mods()
   local load_order = mod.calculate_load_order()

   _p(load_order)

   for _, mod_id in ipairs(load_order) do
      local init = fs.join("mod", mod_id, "init.lua")
      if fs.is_file(init) then
         local success, chunk = load_mod(mod_id, init)
         if not success then
            local err = chunk
            error(string.format("Error initializing %s:\n\t%s", mod_id, err))
         end

         print(string.format("Loaded mod %s.", mod_id))
         chunks[mod_id] = chunk
      end
   end
end

return mod
