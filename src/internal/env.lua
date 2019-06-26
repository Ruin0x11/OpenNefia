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
   "is_an",
   "assert_is_an",

   -- misc. globals
   "inspect",
   "fun",
}

if _DEBUG then
   SANDBOX_GLOBALS[#SANDBOX_GLOBALS+1] = "_p"
end

local SAFE_REQUIRE_PREFIXES = {
   "^api%.",
   "^mod%.",
   -- "^game%."
}


local function extract_mod_name(path)
   local r, count = string.gsub(path, "^mod%.([^.]+)%..+$", "%1")
   if count == 0 then
      return nil
   end

   return r
end

function env.find_calling_mod()
   local stack = 1
   local info = debug.getinfo(stack, "S")

   while info do
      local env = getfenv(stack)
      local success, mod_name = pcall(function()
            return env._MOD_NAME
      end)

      if success then
         return mod_name
      end

      -- local file = info.source:sub(2)
      -- local mod_name = extract_mod_name(file)
      -- if mod_name then
      --    return mod_name
      -- end

      stack = stack + 1
      info = debug.getinfo(stack, "S")
   end

   return "base"
end

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

   mod_name = mod_name or env.find_calling_mod()
   local mod_env = env.generate_sandbox(mod_name, true)
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
      local mod_name = extract_mod_name(path)

      --
      -- TODO: prevent require if mod is not loaded, or is loading but
      --       is not the calling mod.
      --

      return env.load_sandboxed_chunk(path, mod_name)
   end

   return nil
end

function env.generate_sandbox(mod_name, is_strict)
   assert(type(mod_name) == "string")

   local sandbox = {}

   for _, k in ipairs(SANDBOX_GLOBALS) do
      sandbox[k] = _G[k]
   end

   sandbox["_MOD_NAME"] = mod_name

   sandbox["require"] = env.safe_require
   sandbox["data"] = require("internal.data")
   sandbox["schema"] = require("thirdparty.schema")

   if is_strict then
      -- copy the strict metatable from the global environment
      local strict = getmetatable(_G)
      setmetatable(sandbox, strict)
   end

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
