local Advice = require("api.Advice")
local MemoryProfiler = require("api.MemoryProfiler")
local Log = require("api.Log")
local Stopwatch = require("api.Stopwatch")
local state = require("mod.tools.internal.global")

local DebugStatsHook = {}

local function make_advice_id(api, fn_name)
   return ("Hook %s.%s"):format(api, fn_name)
end

function DebugStatsHook.hook(api)
   if state.debug_stats[api] then
      return
   end

   local hooked = 0

   state.debug_stats[api] = state.debug_stats[api] or {}

   local tbl = require(api)
   for k, v in pairs(tbl) do
      local advice_id = make_advice_id(api, k)

      if type(v) == "function" and not Advice.is_advised(api, k, _MOD_NAME, advice_id) then
         local hook = function(orig_fn, ...)
            if state.debug_stats[api] == nil then
               return orig_fn(...)
            end
            state.debug_stats[api][k] = state.debug_stats[api][k] or { mem = 0, time = 0, hits = 0, mem_hits = 0 }
            local rec = state.debug_stats[api][k]

            local time = Stopwatch:new()
            local mem = MemoryProfiler:new()

            local results = {orig_fn(...)}

            rec.hits = rec.hits + 1
            rec.time = rec.time + time:measure()

            local mem_meas = mem:measure()
            if mem_meas > 0 then
               rec.mem_hits = rec.mem_hits + 1
               rec.mem = rec.mem + mem_meas
            end

            return table.unpack(results, 1, table.maxn(results))
         end
         Advice.add("around", api, k, advice_id, hook)
         hooked = hooked + 1
      end
   end

   if hooked > 0 then
      Log.info("%s: hooked %d functions.", api, hooked)
   end
end

function DebugStatsHook.unhook(api)
   if not state.debug_stats[api] then
      return
   end

   local unhooked = 0

   local tbl = require(api)
   for k, v in pairs(tbl) do
      local advice_id = make_advice_id(api, k)
      if type(v) == "function" and Advice.is_advised(api, k, _MOD_NAME, advice_id) then
         Advice.remove(api, k, _MOD_NAME, advice_id)
         unhooked = unhooked + 1
      end
   end

   state.debug_stats[api] = nil

   if unhooked > 0 then
      Log.info("%s: unhooked %d functions.", api, unhooked)
   end
end

function DebugStatsHook.unhook_all()
   for api, _ in pairs(state.debug_stats) do
      DebugStatsHook.unhook(api)
   end
end

function DebugStatsHook.get_results()
   return state.debug_stats
end

function DebugStatsHook.clear_results()
   for _, recordings in pairs(state.debug_stats) do
      table.clear(recordings)
   end
end

return DebugStatsHook
