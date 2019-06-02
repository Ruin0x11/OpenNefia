local fs = require("internal.fs")

local mod = {}

local chunks = {}

--- Globals for use inside mods. All of these should be loaded by the
--- time this file is loaded.
local SANDBOX_GLOBALS = {
   -- Lua basic functions
   "assert",
   "error",
   "ipairs",
   "next",
   "pairs",
   "pcall",
   "print",
   "tonumber",
   "tostring",
   "type",
   "xpcall",

   -- Lua stdlib
   "table",
   "string",
   "utf8",
   "math",

   -- OOP generators
   "interface",
   "class",

   -- misc. globals
   "inspect",
}

local SAFE_REQUIRE_PREFIXES = {
   "^api%.",
   "^mod%.",
   -- "^game%."
}

local function safe_require(path)
   for _, v in ipairs(SAFE_REQUIRE_PREFIXES) do
      if string.match(path, v) then
         return require(path)
      end
   end

   return nil
end

local function generate_sandbox()
   local sandbox = {}

   for _, k in ipairs(SANDBOX_GLOBALS) do
      sandbox[k] = _G[k]
   end

   sandbox["require"] = safe_require

   return sandbox
end

local sandbox = generate_sandbox()

local function load_mod(init_lua_path)
   local chunk = loadfile(init_lua_path)
   local env = generate_sandbox()
   setfenv(chunk, env)
   local success, err = pcall(chunk)
   if not success then
      return success, err
   end

   return true, chunk
end

function mod.load_mods()
   for _, mod in ipairs(fs.get_directory_items("mod/")) do
      local init = fs.join("mod", mod, "init.lua")
      if fs.exists(init) then
         local success, chunk = load_mod(init)
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
