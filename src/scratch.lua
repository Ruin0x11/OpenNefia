local Event = require("api.Event")

local cb = function(_, params)
end

local event = "base.on_hotload_begin"
Event.unregister(event, "test event")
Event.register(event, "test event", cb)
