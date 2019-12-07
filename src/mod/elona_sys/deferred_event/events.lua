local Event = require("api.Event")
local Gui = require("api.Gui")
local skip_list = require("mod.elona_sys.thirdparty.skip_list")

local function run_events(_, _, result)
   local to_remove = 0

   for _, _, event in save.elona_sys.deferred_events:iterate() do
      to_remove = to_remove + 1
      local ok, err = xpcall(event, debug.traceback)
      if not ok then
         Gui.report_error(err, "Error running deferred event")
      elseif err ~= nil then
         result = err
         break
      end
   end

   for _ = 1, to_remove do
      save.elona_sys.deferred_events:pop()
   end

   return result
end

Event.register("base.on_turn_begin", "Run deferred events", run_events)

local function clear_events()
   save.elona_sys.deferred_events = skip_list:new()
end

Event.register("base.on_init_save", "Init save (deferred events)", clear_events)
Event.register("base.on_map_enter", "Clear deferred events", clear_events)
