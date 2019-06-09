local data = require("internal.data")
local fs = require("internal.fs")
local env = require("internal.env")

local mod = {}

local chunks = {}

local function load_mod(mod_name, init_lua_path)
   local chunk, err = loadfile(init_lua_path)
   if chunk == nil then
      error(err)
   end
   local mod_env = env.generate_sandbox(mod_name)
   setfenv(chunk, mod_env)
   local success, err = pcall(chunk)
   if not success then
      return success, err
   end

   return true, chunk
end

function mod.load_mods()
   print("LOAD MODS")
   for _, mod in fs.iter_directory_items("mod/") do
      local init = fs.join("mod", mod, "init.lua")
      if fs.is_file(init) then
         local success, chunk = load_mod(mod, init)
         if not success then
            local err = chunk
            error(string.format("Error initializing %s:\n\t%s", mod, err))
         end

         print(string.format("Loaded mod %s.", mod))
         chunks[mod] = chunk
      end
   end
end

return mod
