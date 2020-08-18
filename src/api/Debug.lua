local Log = require("api.Log")
local env = require("internal.env")
local repl = require("internal.repl")

local debug_state = require("internal.global.debug_state")

local Debug = {}

local function quote_tostring(obj)
   if type(obj) == "string" then
      return ("\"%s\""):format(obj)
   end
   return tostring(obj)
end

function Debug.hook(tbl, fn_name, depth, level)
   level = level or "warn"
   depth = depth or 1

   debug_state.hooked_fns[tbl] = debug_state.hooked_fns[tbl] or {}
   if debug_state.hooked_fns[tbl][fn_name] then
      return
   end

   local require_path = env.get_require_path(tbl) or "<?>"
   local ident = require_path .. "." .. fn_name
   local log_cb = Log[level or "warn"]
   local p
   if depth <= 0 then
      p = quote_tostring
   else
      local inspect_opts = {override_mt = true, depth = depth or 1}
      p = function(arg)
         if type(arg) == "table" then
            if arg._id then
               return quote_tostring(arg)
            else
               return inspect(arg, inspect_opts)
            end
         end
         return quote_tostring(arg)
      end
   end

   local fn = tbl[fn_name]
   assert(type(fn) == "function", ("'%s' must be a function"):format(fn_name))

   debug_state.hooked_fns[tbl][fn_name] = fn

   tbl[fn_name] = function(...)
      local s = ident
      local a = {...}

      local max = 0
      for k, _ in pairs(a) do
         max = math.max(max, k)
      end

      if max == 0 then
         s = s .. "()"
      else
         for i = 1, max do
            local arg = a[i]
            if i == 1 then
               s = s .. "(" .. p(arg)
            else
               s = s .. ", " .. p(arg)
            end
            if i == max then
               s = s .. ")"
            end
         end
      end

      local results = { fn(...) }

      s = s .. " -> "

      if #results == 0 then
         s = s .. "()"
      else
         for i, result in ipairs(results) do
            if i == 1 then
               s = s .. p(result)
            else
               s = s .. ", " .. p(result)
            end
         end
      end

      local tb_line = string.split(debug.traceback())[3] or ""
      s = s .. "  " .. tb_line

      log_cb(s)

      return unpack(results)
   end
end

function Debug.unhook(tbl, fn_name)
   if not (debug_state.hooked_fns[tbl] and debug_state.hooked_fns[tbl][fn_name]) then
      return
   end

   tbl[fn_name] = debug_state.hooked_fns[tbl][fn_name]
   debug_state.hooked_fns[tbl][fn_name] = nil
end

function Debug.unhook_all()
   for tbl, fns in pairs(debug_state.hooked_fns) do
      for fn_name, fn in pairs(fns) do
         tbl[fn_name] = fn
      end
   end
   debug_state.hooked_fns = {}
end

function Debug.print(local_names, level)
   level = level or "warn"
   local s = ""
   local locals = repl.capture_locals(1)
   for i, local_name in ipairs(local_names) do
      local val = locals[local_name] or "?"
      s = s .. local_name .. ": " .. quote_tostring(val)
      if i < #local_names then
         s = s .. "\t"
      end
   end
   Log[level](s)
end

return Debug
