local Event = require("api.Event")
local CodeGenerator = require("api.CodeGenerator")

data:add_type {
   name = "bindable_event",
   fields = {
      {
         name = "event_id",
         default = "",
         template = true
      },
      {
         name = "description",
         default = "",
         template = true
      },
      {
         name = "callback",
         default = CodeGenerator.gen_literal [[
            function(receiver, params, result)
            end
         ]],
         template = true
      },
   }
}

Event.register("base.on_object_instantiated", "Bind events in bindable_events table",
                function(receiver, params, result)
                  if receiver.bindable_events then
                     for _, bindable_event in ipairs(receiver.bindable_events) do
                        local entry = data["elona_sys.bindable_event"]:ensure(bindable_event)
                        receiver:connect_self(entry.event_id,
                                              entry.description,
                                              entry.callback,
                                              { priority = entry.priority or 200000})
                     end
                  end
                end)