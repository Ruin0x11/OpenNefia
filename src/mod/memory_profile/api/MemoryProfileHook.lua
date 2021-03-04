local Advice = require("api.Advice")
local MemoryProfiler = require("api.MemoryProfiler")
local Log = require("api.Log")
local Stopwatch = require("api.Stopwatch")
local global = require("mod.memory_profile.internal.global")
local Tools = require("mod.tools.api.Tools")

local MemoryProfileHook = {}

local function advise(api)
   local hooked = 0

   global.recordings[api] = global.recordings[api] or {}

   local tbl = require(api)
   for k, v in pairs(tbl) do
      if type(v) == "function" and not Advice.is_advised(v) then
         local hook = function(orig_fn, ...)
            global.recordings[api][k] = global.recordings[api][k] or { mem = {}, time = {} }
            local time = Stopwatch:new()
            local mem = MemoryProfiler:new()

            local results = {orig_fn(...)}

            table.insert(global.recordings[api][k].time, time:measure())

            local mem_meas = mem:measure()
            if mem_meas > 0 then
               table.insert(global.recordings[api][k].mem, mem_meas)
            end

            return table.unpack(results, 1, table.maxn(results))
         end
         Advice.add("around", v, "Hook " .. api .. "." .. k, hook)
         hooked = hooked + 1
      end
   end

   if hooked > 0 then
      Log.info("%s: hooked %d functions.", api, hooked)
   end
end

local function unadvise(api)
   local unhooked = 0

   local tbl = require(api)
   for k, v in pairs(tbl) do
      if type(v) == "function" and Advice.is_advised(v) then
         Advice.remove_all(v)
         unhooked = unhooked + 1
      end
   end

   if unhooked > 0 then
      Log.info("%s: unhooked %d functions.", api, unhooked)
   end
end

local APIS = {
"mod.elona.api.Filters",
"api.Chara",
"api.Map",
"api.Event",
"api.Pos",
"mod.elona_sys.api.Anim",
"api.World",
"api.Item",
"mod.elona_sys.api.Skill",
"api.Feat",
"mod.elona.api.Calc",
"mod.elona.api.ElonaCommand",
"api.Gui",
"api.Rand",
"mod.elona_sys.map_tileset.api.MapTileset",
"mod.tools.api.Itemgen",
"mod.elona.api.Effect",
"api.Enum",
"mod.elona.api.Material",
"mod.elona.api.Magic",
"mod.elona_sys.api.Quest",
"mod.elona.api.Quest",
"api.I18N",
"api.Action",
"api.Ui",
"api.Const",
"mod.elona.api.Weather",
"mod.elona.api.Hunger",
"api.chara.IChara"

}

function MemoryProfileHook.hook()
   MemoryProfileHook.clear()
   for _, api in ipairs(APIS) do
      advise(api)
   end
end

function MemoryProfileHook.unhook()
   for _, api in ipairs(APIS) do
      unadvise(api)
   end
end

function MemoryProfileHook.report(sort_kind)
   local t = {}
   for api, funcs in pairs(global.recordings) do
      for name, stats in pairs(funcs) do
         local mem_total = fun.iter(stats.mem):sum()
         local time_total = fun.iter(stats.time):sum()
         local stat = {
            api = api,
            name = name,
            calls = #stats.time,
            mem_total = mem_total,
            time_total = time_total,
            mem_avg = mem_total / #stats.mem,
            time_avg = time_total / #stats.time,
         }
         t[#t+1] = stat
      end
   end

   local get_pair = function(_, v)
      local k = ("%s.%s"):format(v.api, v.name)

      if sort_kind == "mem" then
         return k, v.mem_total
      elseif sort_kind == "calls" then
         return k, v.calls
      end

      return k, v.time_total
   end

   return Tools.print_plot(t, true, get_pair)
end

function MemoryProfileHook.clear()
   table.replace_with(global, { recordings = {} })
end

return MemoryProfileHook
