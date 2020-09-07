local Event = require("api.Event")

local function activity_on_start(act, params, result)
   if act.proto.on_start then
      return act.proto.on_start(act, params, result)
   end
end

Event.register("base.on_activity_start", "Prototype callback (on_start)", activity_on_start)

local function activity_on_pass_turns(act, params, result)
   if act.proto.on_pass_turns then
      return act.proto.on_pass_turns(act, params, result)
   end
end

Event.register("base.on_activity_pass_turns", "Prototype callback (on_pass_turns)", activity_on_pass_turns)

local function activity_on_finish(act, params, result)
   if act.proto.on_finish then
      return act.proto.on_finish(act, params, result)
   end
end

Event.register("base.on_activity_finish", "Prototype callback (on_finish)", activity_on_finish)
