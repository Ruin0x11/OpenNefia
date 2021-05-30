local Prompt = require("api.gui.Prompt")
local Gui = require("api.Gui")
local Env = require("api.Env")
local DebugStatsHook = require("mod.tools.api.debug.DebugStatsHook")
local FuzzyFinderPrompt = require("mod.tools.api.FuzzyFinderPrompt")
local MapEditor = require("mod.tools.api.MapEditor")

local Debug = {}

function Debug.toggle_stats_widget(show)
   local holder = Gui.hud_widget("tools.debug_stats")

   if show == nil then
      show = not holder:enabled()
   end
   holder:set_enabled(show)

   if show then
      Gui.mes("debug.mes.stats_widget.showing")
   else
      Gui.mes("debug.mes.stats_widget.hiding")
   end
end

local function is_hookable_path(api_path)
   return (api_path:match("^api%.") or api_path:match("^mod%."))
      and not api_path:match("%.test%.")
end

local function api_candidates()
   local paths = fun.iter(Env.get_loaded_module_paths()):filter(is_hookable_path):to_list()
   local candidates = table.set(paths)
   local results = DebugStatsHook.get_results()
   for api, _ in pairs(results) do
      candidates[api] = nil
   end
   candidates = table.keys(candidates)

   return candidates
end

local function fn_candidates(api_path)
   local tbl = require(api_path)
   local function is_fn(k) return type(tbl[k]) == "function" end

   local candidates = fun.iter(table.keys(tbl)):filter(is_fn):to_set()
   local results = DebugStatsHook.get_results()
   for fn_name, _ in pairs(results[api_path] or {}) do
      candidates[fn_name] = nil
   end
   candidates = table.keys(candidates)

   return candidates
end

function Debug.query_watch_fn()
   local api_path, fn_name, canceled

   while not canceled do
      local candidates = api_candidates()
      api_path, canceled = FuzzyFinderPrompt:new(candidates):query()

      if api_path and not canceled then
         candidates = fn_candidates(api_path)
         fn_name, canceled = FuzzyFinderPrompt:new(candidates):query()

         if fn_name and not canceled then
            DebugStatsHook.hook_fn(api_path, fn_name)
         end
      end
   end
end

function Debug.query_watch_api()
   local api_path, canceled

   while not canceled do
      local candidates = api_candidates()
      api_path, canceled = FuzzyFinderPrompt:new(candidates):query()

      if api_path and not canceled then
         DebugStatsHook.hook(api_path)
      end
   end
end

function Debug.query_unwatch_api()
   local canceled = nil

   while not canceled do
      local candidates = table.keys(DebugStatsHook.get_results())

      local api_path
      api_path, canceled = FuzzyFinderPrompt:new(candidates):query()

      if api_path and not canceled then
         DebugStatsHook.unhook(api_path)
      end
   end
end

function Debug.query_debug_menu()
   local canceled = nil

   while not canceled do
      local options = {
         { text = "debug.prompt.toggle_stats_widget", index = 1 },
         { text = "debug.prompt.watch_api", index = 2 },
         { text = "debug.prompt.watch_fn", index = 3 },
         { text = "debug.prompt.unwatch_api", index = 4 },
         { text = "debug.prompt.unwatch_all", index = 5 },
         { text = "debug.prompt.clear_stats", index = 6 },
         { text = "debug.prompt.map_editor", index = 7 },
      }
      local result
      result, canceled = Prompt:new(options):query()

      if canceled then
         break
      end

      local index = result.index

      if index == 1 then
         Debug.toggle_stats_widget()
      elseif index == 2 then
         Debug.query_watch_api()
      elseif index == 3 then
         Debug.query_watch_fn()
      elseif index == 4 then
         Debug.query_unwatch_api()
      elseif index == 5 then
         DebugStatsHook.unhook_all()
         Gui.mes("debug.mes.unwatched_all")
      elseif index == 6 then
         DebugStatsHook.clear_results()
      elseif index == 7 then
         MapEditor:new():query()
      end
   end
end

return Debug
