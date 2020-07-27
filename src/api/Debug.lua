local Event = require("api.Event")
local Log = require("api.Log")

local enabled = false

local Debug = {}

function Debug.print(...)
   if not enabled then
      return
   end
   print(...)
end

function Debug.print_end(e)
   enabled = e or false
end

Event.register("base.on_hotload_end",
               "enable Debug.print",
               function()
                  enabled = true
               end)

function Debug.hook(tbl, fn_name, depth, level)
   local log_cb = Log[level or "warn"]
   depth = depth or 1
   local p
   if depth <= 0 then
      p = tostring
   else
      local inspect_opts = {override_mt = true, depth = depth or 1}
      p = function(arg) return inspect(arg, inspect_opts) end
   end

   local fn = tbl[fn_name]
   assert(type(fn) == "function", ("'%s' must be a function"):format(fn_name))
   tbl[fn_name] = function(...)
      local s
      local a = {...}
      local max = 0
      for k, _ in pairs(a) do
         max = math.max(max, k)
      end
      for i = 1, max do
         local arg = a[i]
         if i == 1 then
            s = p(arg)
         else
            s = s .. ", " .. p(arg)
         end
      end
      log_cb(s)
      return fn(...)
   end
end

return Debug
