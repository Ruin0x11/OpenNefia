local Log = require("api.Log")

--- Module and mod environment functions. This module implements
--- seamless hotloading by replacing the global `require` with one
--- that can update the result of `require` in-place if a hotload is
--- requested. This is not without some caveats though:
---
--- 1. The results of `require` should be a table to enable hotloading.
--- 2. All local upvalues inside the chunk will be lost on hotloading.
---    To support hotloading, code should minimize the usage of
---    top-level locals or otherwise provide support for hotloading by
---    calling env.is_hotloading() in the appropriate places.
--- 4. For now it is assumed that any require path starting with `mod`
---    will be a part of a mod's code, so a mod sandbox should be
---    applied to it. Any other path will use the global environment.
---
--- The goal is to be able to completely reload a mod's code at
--- runtime without any significant side effects warranting a full
--- restart (save for user code).
---
--- If a hotloaded chunk returns "no_hotload" instead of a table, the
--- existing table will be preserved. This is so those chunks can
--- custom implement hotloading support. See `internal.data` for an
--- example.
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

   -- OOP library
   "class",

   -- misc. globals
   "inspect",
   "fun",
}

if _DEBUG then
   SANDBOX_GLOBALS[#SANDBOX_GLOBALS+1] = "_p"
end

local UNSAFE_HOTLOAD_PATHS = {
   "internal.env",
   "util.class",
}

-- To determine the require path of a chunk, it is necessary to keep a
-- cache. If a chunk is hotloaded, the table it returns will be merged
-- into the one already existing in any upvalues, but the table
-- upvalue that was created inside the chunk itself will still
-- reference a completely different table (the one that was merged
-- into the existing one). Since this upvalue can be local there may
-- be no way to access it, so in the end there can be more than one
-- table at the same require path. This cache table is a mapping from
-- a table to its require path.
--
-- TODO: actually you can use a function called debug.setupvalue to
-- modify upvalues. it should be used instead.
local require_path_cache = setmetatable({}, { __mode = "k" })


-- This flag is used for e.g. relayouting all UI layers on hotload so
-- the changes are visible immediately and on_hotload() can be called.
local hotloaded_this_frame = false
function env.set_hotloaded_this_frame(val)
   hotloaded_this_frame = val
end

function env.hotloaded_this_frame()
   return hotloaded_this_frame
end

local function path_is_in_mod(path)
   return string.match(path, "^mod%.([^.]+)")
end

-- Tries to find the mod that is calling the current function by
-- looking up the stack for an environment with the _MOD_NAME global
-- variable. If not found, returns "base".
--
-- When hotloading, this uses the currently hotloading require path to
-- see if a mod is being hotloaded at the top level instead, since the
-- caller of this function will be the debug server or REPL.
function env.find_calling_mod()
   local hotload_path = env.is_hotloading()
   if hotload_path then
      return path_is_in_mod(hotload_path) or "base"
   end

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

local global_require = require

--- Loads a chunk from a package search path ignoring
--- `package.loaded`. If no environment is passed, the returned chunk
--- will have access to the global environment.
-- @tparam string path
-- @tparam[opt] table mod_env
local function env_loadfile(path, mod_env)
   local resolved = package.searchpath(path, package.path)

   if resolved == nil and not mod_env and _DEBUG then
      -- Also try cpath, but only when not using the love runtime
      -- (tests). Mods shouldn't be able to load arbitrary native
      -- libraries.
      resolved = package.searchpath(path, package.cpath)
      if resolved then
         return global_require(path)
      end
   end

   if resolved == nil then
      local paths = ""
      for _, s in ipairs(string.split(package.path, ";")) do
         paths = paths .. "\n" .. s
      end
      return nil, "Cannot find path " .. path .. paths
   end

   local chunk, err = loadfile(resolved)
   if chunk == nil then
      return nil, err
   end

   mod_env = mod_env or _G
   setfenv(chunk, mod_env)

   local success, err = xpcall(chunk, debug.traceback)
   if not success then
      return nil, err
   end

   local result = err
   return result
end

function env.load_sandboxed_chunk(path, mod_name)
   mod_name = mod_name or env.find_calling_mod()

   -- TODO: cache this somewhere.
   local mod_env = env.generate_sandbox(mod_name, true)

   return env_loadfile(path, mod_env)
end

local function get_load_type(path)
   if string.match(path, "^api%.") then
      return "api"
   elseif path_is_in_mod(path) then
      return "mod"
   end

   return nil
end

local function can_hotload(path)
   for _, patt in ipairs(UNSAFE_HOTLOAD_PATHS) do
      if string.match(path, patt) then
         return false
      end
   end

   return true
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
   local load_type = get_load_type(path)

   if load_type == "api" then
      Log.debug("Loading chunk %s with global env.", path)
      return env_loadfile(path)
   elseif load_type == "mod" then
      local mod_name = extract_mod_name(path)

      --
      -- TODO: prevent require if mod is not loaded, or is loading but
      --       is not the calling mod.
      --

      Log.debug("Loading chunk %s with mod sandbox for %s.", path, mod_name)
      return env.load_sandboxed_chunk(path, mod_name)
   end

   return nil
end

--- Requires a path with either the mod environment or the global
--- environment depending on its prefix.
local function env_loadfile_or_safe_load(path)
   if path_is_in_mod(path) then
      return safe_load_chunk(path)
   end

   return env_loadfile(path)
end

local IS_HOTLOADING = false
local HOTLOAD_DEPS = false
local HOTLOADED = {}
local LOADING = {}

-- Converts a filepath to a uniquely identifying Lua require path.
-- Examples:
-- api/chara/IChara.lua -> api.chara.IChara
-- mod/elona/init.lua   -> mod.elona
function env.convert_to_require_path(path)
   local path = path

   -- HACK: needs better normalization to prevent duplicate chunks. If
   -- this is not completely unique then two require paths could end
   -- up referring to the same file, breaking hotloading. The
   -- intention is any require path uniquely identifies a return value
   -- from `require`.
   path = string.strip_suffix(path, ".lua")
   path = string.gsub(path, "/", ".")
   path = string.gsub(path, "\\", ".")
   path = string.strip_suffix(path, ".init")

   return path
end

local function gen_require(chunk_loader, can_load_path)
   return function(path, hotload)
      local req_path = env.convert_to_require_path(path)

      if can_load_path and not can_load_path(req_path) then
         return nil
      end

      if LOADING[req_path] then
         error("Loop while loading " .. req_path)
      end

      hotload = hotload or HOTLOAD_DEPS

      if hotload and not can_hotload(req_path) then
         hotload = false
      end

      -- Don't hotload again if the req_path was already hotloaded
      -- earlier.
      if hotload and HOTLOADED[req_path] then
         hotload = false
      end

      if not hotload and package.loaded[req_path] then
         return package.loaded[req_path]
      end

      Log.debug("HOTLOAD %s", req_path)
      LOADING[req_path] = true
      local result, err = chunk_loader(req_path)
      LOADING[req_path] = false
      Log.debug("HOTLOAD RESULT %s", tostring(result))

      if err then
         IS_HOTLOADING = false
         error("\n\t" .. err, 0)
      end

      if IS_HOTLOADING and result == "no_hotload" then
         Log.info("Not hotloading: %s", req_path)
         return package.loaded[req_path]
      end

      if type(package.loaded[req_path]) == "table"
         and type(result) == "table"
      then
         Log.info("Hotload: %s %s <- %s", req_path, string.tostring_raw(package.loaded[req_path]), string.tostring_raw(result))
         if class.is_class_or_interface(result) then
            class.hotload(package.loaded[req_path], result)
         else
            if result.on_hotload then
               result.on_hotload(package.loaded[req_path], result)
            else
               table.replace_with(package.loaded[req_path], result)
            end
         end
         Log.info("Hotload result: %s", string.tostring_raw(package.loaded[req_path]))
      elseif result == nil then
         package.loaded[req_path] = true
      else
         package.loaded[req_path] = result
      end

      if hotload then
         HOTLOADED[req_path] = true
      end

      if type(result) == "table" then
         require_path_cache[result] = req_path
      end

      return package.loaded[req_path]
   end
end

--- Version of `require` that will load sandboxed mod environments if
--- the path is prefixed with "mod", and will update the table in
--- place if hotloading, but disallow loading non-public files.
-- @function env.safe_require
env.safe_require = gen_require(safe_load_chunk, get_load_type)

--- Version of `require` for the global environment that will respect
--- hotloading and mod environments, and also allow requiring
--- non-public files.
-- @function env.require
env.require = gen_require(env_loadfile_or_safe_load)

--- Reloads a path or a class required from a path that has been
--- required already by updating its table in-place. If either the
--- result of `require` or the existing item in package.loaded are not
--- tables, the existing item is overwritten instead.
-- @tparam string|table path
-- @tparam bool also_deps If true, also hotload any nested
-- dependencies loaded with `require` that any hotloaded chunk tries
-- to load.
-- @treturn table
function env.hotload(path_or_class, also_deps)
   if type(path_or_class) == "table" then
      local path = env.get_require_path(path_or_class)
      if path == nil then
         error("Unknown require path for " .. tostring(path_or_class))
      end

      path_or_class = path
   end

   return env.hotload_path(path_or_class, also_deps)
end

--- Reloads a path that has been required already by updating its
--- table in-place. If either the result of `require` or the existing
--- item in package.loaded are not tables, the existing item is
--- overwritten instead.
-- @tparam string path
-- @tparam bool also_deps If true, also hotload any nested
-- dependencies loaded with `require` that any hotloaded chunk tries
-- to load.
-- @treturn table
function env.hotload_path(path, also_deps)
   -- The require path can come from an editor that preserves an
   -- "init.lua" at the end. We still need to strip "init.lua" from
   -- the end if that's the case, in order to make the paths
   -- "api/Api.lua" and "api/Api/init.lua" resolve to the same thing.
   path = env.convert_to_require_path(path)

   HOTLOADED = {}

   if not can_hotload(path) then
      error("Can't hotload the path " .. path)
   end

   local loaded = package.loaded[path]
   if not loaded then
      Log.warn("Tried to hotload '%s', but path was not yet loaded. Requiring normally.", path)
      return env.safe_require(path, false)
   end

   if also_deps then
      -- Enable hotloading for any call to a hooked `require` until
      -- the top-level `hotload` call finishes.
      HOTLOAD_DEPS = true
   end

   Log.info("Begin hotload: %s", path)
   IS_HOTLOADING = path
   local result = env.require(path, true)
   IS_HOTLOADING = false

   if also_deps then
      HOTLOAD_DEPS = false
   end

   hotloaded_this_frame = true

   return result
end

-- Redefines a single function on an API table by loading its chunk
-- and copying only it to the currently loaded table.
-- NOTE: The function cannot reference any chunk-local upvalues, or
-- the behavior will not work as expected if used along with the other
-- values in the table, since they may reference the same-named
-- upvalue but in the original chunk.
function env.redefine(path, name)
   -- TODO
end

--- Returns the currently hotloading path if hotloading is ongoing.
--- Used to implement specific support for hotloading in global
--- variables besides the entries in package.loaded.
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

   local save_store = require("internal.save_store")
   sandbox["save"] = save_store.for_mod(mod_name)

   if is_strict then
      -- copy the strict metatable from the global environment
      -- (thirdparty/strict.lua)
      local strict = getmetatable(_G)
      setmetatable(sandbox, strict)
   end

   return sandbox
end

-- Given a table loaded with require, a class/interface table or a
-- class instance, returns its require path.
function env.get_require_path(tbl)
   assert(type(tbl) == "table")

   if tbl.__class then
      tbl = tbl.__class
   end

   local path = require_path_cache[tbl]

   if path == nil then
      Log.warn("Cannot find require path for %s (%s)", tostring(tbl), string.tostring_raw(tbl))
   end

   return path
end

function env.is_loaded(path)
   return package.loaded[path] ~= nil
end

function env.require_all_apis(dir, recurse)
   local fs = require("util.fs")

   dir = dir or "api"

   local api_env = {}

   for _, api in fs.iter_directory_items(dir .. "/") do
      local path = fs.join(dir, api)
      if fs.is_file(path) then
         local name = fs.filename_part(path)
         if api_env[name] then
            Log.warn("Duplicate API required in environment: %s", name)
         end
         api_env[name] = env.require(path)
      elseif fs.is_directory(path) and recurse then
         table.merge(api_env, env.require_all_apis(path))
      end
   end

   return api_env
end

return env
