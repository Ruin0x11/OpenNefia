local Event = require("api.Event")
local Gui = require("api.Gui")

local function run_events(_, _, result)
   local to_remove = 0

   -- Make sure to run events that are added by other deferred events
   -- themselves.
   while save.elona_sys.deferred_events:length() > 0 do
      for _, _, event in save.elona_sys.deferred_events:iterate() do
         to_remove = to_remove + 1

         -- the event can be nil if a save was loaded, since functions aren't
         -- serialized
         if event then
            local ok, err = xpcall(event, debug.traceback)
            if not ok then
               Gui.report_error(err, "Error running deferred event")
            elseif err ~= nil then
               -- TODO better control of turn results returned
               result = err
               break
            end
         end
      end

      for _ = 1, to_remove do
         save.elona_sys.deferred_events:pop()
      end
   end

   return result
end

Event.register("base.on_turn_begin", "Run deferred events", run_events)

local function clear_events()
   save.elona_sys.deferred_events:clear()
end

Event.register("base.on_map_leave", "Clear deferred events", clear_events)
