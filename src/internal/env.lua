local fs = require("internal.fs")
local Log = require("api.Log")

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


-- Tries to find the mod that is calling the current function by
-- looking up the stack for an environment with the _MOD_NAME global
-- variable. If not found, returns "base".
function env.find_calling_mod()
   local stack = 1
   local info = debug.getinfo(stack, "S")

   while info do
      local mod_env = getfenv(stack)
      local success, mod_name = pcall(function()
            return mod_env._MOD_NAME
      end)

      if success then
         return mod_name
      end

      stack = stack + 1
      info = debug.getinfo(stack, "S")
   end

   return "base"
end

--- Loads a chunk from a package search path ignoring
--- `package.loaded`. If no environment is passed, the returned chunk
--- will have access to the global environment.
-- @tparam string path
-- @tparam[opt] table mod_env
local function env_loadfile(path, mod_env)
   Log.debug("LOADFILE %s", path)
   local resolved = package.searchpath(path, package.path)
   if resolved == nil then
      return nil, "Cannot find path " .. path
   end

   local chunk, err = loadfile(resolved)
   if chunk == nil then
      return nil, err
   end

   mod_env = mod_env or _G
   setfenv(chunk, mod_env)

   local success, err = xpcall(chunk, function(err) return debug.traceback(err) end)
   if not success then
      return nil, err
   end

   local result = err
   return result
end

function env.load_sandboxed_chunk(path, mod_name)
   mod_name = mod_name or env.find_calling_mod()
   local mod_env = env.generate_sandbox(mod_name, true)

   return env_loadfile(path, mod_env)
end

local function get_load_type(path)
   if string.match(path, "^api%.") then
      return "api"
   elseif string.match(path, "^mod%.") then
      return "mod"
   end

   return nil
end

local function extract_mod_name(path)
   local r, count = string.gsub(path, "^mod%.([^.]+)%..+$", "%1")
   if count == 0 then
      return nil
   end

   return r
end

--- Loads a chunk without updating the global package.loaded table.
--- The load method chosen depends on the path prefix: "api" will load
--- with the global environment, "mod" will use a sandboxed
--- environment.
-- @tparam string path
local function safe_load_chunk(path)
   local load_type

   local load_type = get_load_type(path)

   if load_type == "api" then
      return env_loadfile(path)
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

local IS_HOTLOADING = false
local HOTLOADED = {}
local LOADING = {}

local function convert_to_require_path(path)
   local path = path

   -- HACK: needs better normalization to prevent duplicate chunks.
   path = string.strip_suffix(path, ".lua")
   path = string.gsub(path, "/", ".")
   path = string.gsub(path, "\\", ".")

   return path
end

local function gen_require(chunk_loader)
   return function(path, hotload)
      path = convert_to_require_path(path)

      if LOADING[path] then
         error("Loop while loading " .. path)
      end

      hotload = hotload or IS_HOTLOADING

      -- Only paths under "mod.*" and "api.*" should be hotloaded.
      -- (For example, hotloading "internal.data" would overwrite all
      -- data prototypes, which would break many things.)
      if hotload and not get_load_type(path) then
         hotload = false
      end

      -- Don't hotload again if the path was already hotloaded
      -- earlier.
      if hotload and HOTLOADED[path] then
         hotload = false
      end

      if not hotload and package.loaded[path] then
         return package.loaded[path]
      end

      Log.debug("HOTLOAD %s", path)
      LOADING[path] = true
      local chunk, err = chunk_loader(path)
      LOADING[path] = false

      if err then
         error("\n\t" .. err, 0)
      end

      if type(package.loaded[path]) == "table"
         and type(chunk) == "table"
      then
         table.replace_with(package.loaded[path], chunk)
      else
         package.loaded[path] = chunk
      end

      if hotload then
         HOTLOADED[path] = true
      end

      return chunk
   end
end

--- Version of `require` that will load sandboxed mod environments if
--- the path is prefixed with "mod", and will update the table in
--- place if hotloading.
-- @function env.safe_require
env.safe_require = gen_require(safe_load_chunk)

--- Version of `require` for the global environment that will respect
--- hotloading and also permit requiring non-public files.
-- @function env.require
env.require = gen_require(env_loadfile)

--- Reloads a path that has been required already by updating its
--- table in-place. If either the result of `require` or the existing
--- item in package.loaded are not tables, the existing item is
--- overwritten instead.
-- @tparam string path
-- @tparam bool also_deps If true, also hotload any nested
-- dependencies loaded with `require` that any hotloaded chunk tries
-- to load.
-- @treturn table
function env.hotload(path, also_deps)
   HOTLOADED = {}

   local loaded = package.loaded[path]
   if not loaded then
      return env.safe_require(path, false)
   end

   if also_deps then
      -- Enable hotloading for any call to a hooked `require` until
      -- the top-level `hotload` call finishes.
      IS_HOTLOADING = true
   end

   print("Begin hotload " .. path)
   local loaded = env.safe_require(path, true)

   if also_deps then
      IS_HOTLOADING = false
   end

   return loaded
end

--- Returns true if hotloading is ongoing. Used to implement specific
--- support for hotloading in global variables besides the entries in
--- package.loaded.
-- @treturn bool
function env.is_hotloading()
   return IS_HOTLOADING
end

--- Overwrites Lua's builtin `require` with a version compatible with
--- the hotloading system.
function env.hook_global_require()
   require = function(path)
      -- ignore second argument (`hotload`)
      return env.require(path)
   end
end

local mod_require = function(path)
   -- ignore second argument (`hotload`)
   return env.safe_require(path)
end

function env.generate_sandbox(mod_name, is_strict)
   assert(type(mod_name) == "string")

   local sandbox = {}

   for _, k in ipairs(SANDBOX_GLOBALS) do
      sandbox[k] = _G[k]
   end

   sandbox["_MOD_NAME"] = mod_name

   sandbox["require"] = mod_require
   sandbox["data"] = require("internal.data")
   sandbox["schema"] = require("thirdparty.schema")
   sandbox["_G"] = sandbox

   if is_strict then
      -- copy the strict metatable from the global environment
      -- (thirdparty/strict.lua)
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
         local name = fs.filename_part(file)
         api_env[name] = env.require(file)
      end
   end

   return api_env
end

return env
