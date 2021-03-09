local advice_state = require("internal.global.advice_state")
local Env = require("api.Env")
local Event = require("api.Event")
local env = require("internal.env")

--- Advice system.
---
--- This allows you to add new code to existing functions that don't have event
--- hooks defined. You can modify any function in the public API or defined on
--- classes this way.
---
--- Some caveats:
---   - It only works on publicly exported functions in modules or classes,
---     since it hooks into the module loading system. You can't use it on
---     things like callbacks inside data definitions (though it might be
---     possible to implement this at some point).
---   - You have to be sure the function's return values and arguments match
---     those of the advised functions you add. This could change because of
---     updates to the engine or mods.
---   - You can break all sorts of things by adding buggy code to heavily-used
---     API functions. However, it's possible to disable all advice on a
---     function by calling `Advice.remove_all(Module.some_function)` on it.
---
--- Example:
---
--- ```lua
--- local map = Map.current()
--- Calc.calc_object_level(10, map) -- 10
---
--- function double_map_level(orig_fn, base, map)
---    return orig_fn(base, map) * 2
--- end
--- Advice.add("around", Calc.calc_object_level, "Double the level of map enemies/items", double_map_level)
--- Calc.calc_object_level(10, map) -- 20
---
--- Advice.remove(Calc.calc_object_level, "Double the level of map enemies/items")
--- Calc.calc_object_level(10, map) -- 10
--- ```
---
--- See also:
---   - https://en.wikipedia.org/wiki/Advice_(programming)
---   - https://www.gnu.org/software/emacs/manual/html_node/elisp/Advising-Functions.html
local Advice = {}

local MAX_IDENTIFIER_LEN = 128

-- Possible ways of calling the new/old function. Taken directly from Emacs'
-- `nadvice` module.
local locations = {}

function locations.before(fn, old_fn, ...)
   fn(...)
   return old_fn(...)
end

function locations.after(fn, old_fn, ...)
   local results = {old_fn(...)}
   fn(...)
   return unpack(results, 1, table.maxn(results))
end

function locations.around(fn, old_fn, ...)
   return fn(old_fn, ...)
end

function locations.override(fn, old_fn, ...)
   return fn(...)
end

function locations.before_while(fn, old_fn, ...)
   if fn(...) then
      return old_fn(...)
   end
end

function locations.before_until(fn, old_fn, ...)
   local results = {fn(...)}
   if results[1] then
      return unpack(results, 1, table.maxn(results))
   end
   return old_fn(...)
end

function locations.after_while(fn, old_fn, ...)
   if old_fn(...) then
      return fn(...)
   end
end

function locations.after_until(fn, old_fn, ...)
   local results = {old_fn(...)}
   if results[1] then
      return unpack(results, 1, table.maxn(results))
   end
   return fn(...)
end

function locations.filter_args(fn, old_fn, ...)
   return old_fn(fn(...))
end

function locations.filter_return(fn, old_fn, ...)
   return fn(old_fn(...))
end


local function get_module_and_fn(require_path, fn_name)
   local ok, module_ = pcall(require, require_path)
   if not ok or module_ == nil then
      error("This module was not defined publicly.")
   end

   local original_fn = module_[fn_name]
   if not type(original_fn) == "function" then
      error(("The thing at '%s:%s' was not a function."):format(require_path, fn_name))
   end

   local fns = advice_state.for_module[require_path]

   if fns then
      local advice = fns[fn_name]
      if advice then
         -- This function was previously advised, and `place` refers to
         -- `advice.merged_fn`, a function object.
         original_fn = advice.original_fn
      end
   end

   return module_, original_fn
end

function Advice.is_advised(require_path, fn_name, mod, identifier)
   assert(require_path and fn_name, "At least 'require_path' and 'fn_name' must be specified")

   if mod then
      assert(mod and identifier, "If 'mod' is specified, then 'mod' and 'identifier' must both be specified")
   end

   local fns = advice_state.for_module[require_path]
   if not fns then
      return false
   end

   local advice = fns[fn_name]
   if mod == nil then
      return advice ~= nil
   end

   for _, advice_fn in ipairs(advice.advice_fns) do
      if advice_fn.originating_mod == mod and advice_fn.identifier == identifier then
         return true
      end
   end

   return false
end

-- Rebuilds the final merged advice callback from a sequence of locations and
-- callbacks.
local function rebuild_merged_advice_fn(advice)
   -- The final function needs to be recursive, so here we build a single
   -- "merged" callback that calls each advice callback in order of priority
   -- in a recursive manner.
   local merged_fns = {advice.original_fn}
   for i, advice_fn in ipairs(advice.advice_fns) do
      local next_fn = advice_fn.fn
      local loc = locations[advice_fn.where]
      merged_fns[i+1] = function(...)
         return loc(next_fn, merged_fns[i], ...)
      end
   end

   return merged_fns[#merged_fns]
end

Advice.DEFAULT_PRIORITY = 100000

--- Adds new code to a publicly exported function in a module or class.
---
--- See the following for details on the possible values of `where` (with dashes
--- replaced by underscores):
---
--- https://www.gnu.org/software/emacs/manual/html_node/elisp/Advice-combinators.html
---
--- @tparam string where
--- @tparam function place
--- @tparam string identifier
--- @tparam function fn
--- @tparam[opt] {priority=uint} opts
--- @treturn boolean
function Advice.add(where, require_path, fn_name, identifier, fn, opts)
   opts = opts or {}

   -- TODO: Do not add advice for functions in a module that is currently being
   -- required/hotloaded.

   if identifier:len() > MAX_IDENTIFIER_LEN then
      error(("Identifier cannot exceed %d characters. This is to better allow for removing advice using an identifier, like Advice.remove(fn, 'some long identifier...')"):format(MAX_IDENTIFIER_LEN))
   end

   assert(locations[where] ~= nil, "Invalid advice location")
   assert(env.is_loaded(require_path), ("Path %s is not loaded"):format(require_path))
   assert(type(fn) == "function")

   local module_, original_fn = get_module_and_fn(require_path, fn_name)
   local calling_mod, calling_loc = env.find_calling_mod(1, true)

   -- TODO this only checks for the currently loading module, might want to
   -- check recursively if this is in a nested require
   if Env.is_hotloading() == Env.get_require_path(module_) then
      error("You can't add advice to a function defined in a module that's still being loaded.")
   end

   advice_state.for_module[require_path] = advice_state.for_module[require_path] or {}
   local advice = advice_state.for_module[require_path][fn_name]

   if advice == nil then
      -- This function has not been advised yet. Set up new advice metadata for
      -- it.
      advice = {
         original_fn = original_fn,
         module = module_,
         ident = fn_name,
         advice_fns = {},
         merged_fn = nil
      }
      advice_state.for_module[require_path][fn_name] = advice
   end

   local pred = function(advice_fn)
      return advice_fn.identifier == identifier and advice_fn.originating_mod == calling_mod
   end

   table.iremove_by(advice.advice_fns, pred)

   local priority = opts.priority or Advice.DEFAULT_PRIORITY
   advice.advice_fns[#advice.advice_fns+1] = {
      priority = priority,
      where = where,
      fn = fn,
      identifier = identifier,
      originating_mod = calling_mod,
      originating_location = calling_loc
   }

   table.sort(advice.advice_fns, function(a, b) return a.priority < b.priority end)

   advice.merged_fn = rebuild_merged_advice_fn(advice)

   -- It's important that the replacement is a function instead of a table,
   -- because it would cause code like `type(thing) == "function"` to break. We
   -- use this function itself as the key into the advice table to get the
   -- advice's metadata.
   module_[fn_name] = advice.merged_fn

   return true
end

--- Removes a piece of advice from a publicly exported function.
---
--- @tparam function place
--- @tparam function|string identifier
--- @treturn boolean
function Advice.remove(require_path, fn_name, mod, identifier)
   assert(require_path and fn_name and mod and identifier,
          "At least 'require_path', 'fn_name', `mod` and 'identifier' must be specified")

   local module_, original_fn = get_module_and_fn(require_path, fn_name)

   local fns = advice_state.for_module[require_path]
   if not fns then
      return false
   end
   local advice = fns[fn_name]
   if not advice then
      return false
   end

   local pred = function(advice_fn)
      return advice_fn.originating_mod == mod
         and advice_fn.identifier == identifier
   end

   local inds = table.iremove_by(advice.advice_fns, pred)

   if #inds > 0 then
      if #advice.advice_fns == 0 then
         Advice.remove_all(require_path, fn_name)
      end

      return true
   end

   return false
end

function Advice.remove_by_mod(mod)
   assert(mod, "At least 'mod' must be specified")

   local pred = function(advice_fn)
      return advice_fn.originating_mod == mod
   end

   local did_something = false
   for require_path, fns in pairs(advice_state.for_module) do
      for fn_name, advice in pairs(fns) do
         local inds = table.iremove_by(advice.advice_fns, pred)

         if #inds > 0 then
            if #advice.advice_fns == 0 then
               Advice.remove_all(require_path, fn_name)
            end

            did_something = true
         end
      end
   end

   return did_something
end

--- Removes all advice from a publicly exported function.
---
--- @tparam function place
--- @treturn boolean
function Advice.remove_all(require_path, fn_name)
   assert(require_path and fn_name, "At least 'require_path' and 'fn_name' must be specified")

   local fns = advice_state.for_module[require_path]
   if not fns then
      return false
   end
   local advice = fns[fn_name]
   if not advice then
      return false
   end

   -- Reset the API table's function to be the original.
   -- Equivalent to `Rand["rnd"] = function(n) ... end`.
   advice.module[advice.ident] = advice.original_fn

   fns[advice.ident] = nil
   if table.count(fns) == 0 then
      advice_state.for_module[require_path] = nil
   end

   return true
end

-- If a module is hotloaded, the `original_fn` part of each advice attached to
-- it will become outdated. This function updates `advice.original_fn` for the
-- old function's advice.
local function update_hotloaded_module_advice(_, params)
   if type(params.result) ~= "table" then
      return
   end
   local require_path = params.result.require_path
   local module_ = params.result.module

   local advice_for_mod = advice_state.for_module[require_path]
   if advice_for_mod == nil then
      return
   end

   for ident, field in pairs(module_) do
      local advice = advice_for_mod[ident]
      if advice and type(field) == "function" then
         advice.original_fn = field
         advice.merged_fn = rebuild_merged_advice_fn(advice)
         module_[ident] = advice.merged_fn
         advice_state.advice[advice.merged_fn] = advice
      end
   end
end

Event.register("base.on_hotload_end", "Update references to advice functions in hotloaded modules", update_hotloaded_module_advice)

return Advice
