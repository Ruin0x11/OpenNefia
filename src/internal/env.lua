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
   "select",
   "tonumber",
   "tostring",
   "type",
   "unpack",
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

function env.load_sandboxed_chunk(path, mod_name)
   if package.loaded[path] then
      return package.loaded[path]
   end

   local resolved = package.searchpath(path, package.path)
   if resolved == nil then
      error("Cannot find path " .. path)
   end

   local chunk, err = loadfile(resolved)
   if chunk == nil then
      error(err)
   end
   local mod_env = env.generate_sandbox(mod_name)
   setfenv(chunk, mod_env)

   local success, err = pcall(chunk)

   if success == false then
      error("\n\t" .. err)
   end

   local result = err
   package.loaded[path] = result

   return result
end

local global_require = require

function env.safe_require(path)
   local load_type

   if string.match(path, "^api%.") then
      load_type = "api"
   elseif string.match(path, "^mod%.") then
      load_type = "mod"
   end

   if load_type == "api" then
      return global_require(path)
   elseif load_type == "mod" then
      return package.loaded[path] or env.load_sandboxed_chunk(path, "base")
   end

   return nil
end

function env.generate_sandbox(mod_name)
   local sandbox = {}

   for _, k in ipairs(SANDBOX_GLOBALS) do
      sandbox[k] = _G[k]
   end

   sandbox["_MOD_NAME"] = mod_name

   sandbox["require"] = env.safe_require
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
