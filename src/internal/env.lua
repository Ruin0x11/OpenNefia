local fs = require("internal.fs")

local env = {}

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
         -- BUG won't work. needs to call loadfile/setfenv directly
         return require(path)
      end
   end

   return nil
end

function env.generate_sandbox(mod_name)
   local sandbox = {}

   for _, k in ipairs(SANDBOX_GLOBALS) do
      sandbox[k] = _G[k]
   end

   print(mod_name)
   sandbox["MOD_NAME"] = mod_name

   sandbox["require"] = safe_require
   sandbox["data"] = require("internal.data")
   sandbox["schema"] = require("thirdparty.schema")

   return sandbox
end

function env.require_all_apis()
   local api_env = {}

   for _, api in fs.iter_directory_items("api/") do
      local file = fs.join("api", api)
      if fs.is_file(file) then
         local require_path = string.strip_suffix(file, ".lua")
         local name = fs.filename_part(file)
         api_env[name] = require(require_path)
      end
   end

   return api_env
end

return env
