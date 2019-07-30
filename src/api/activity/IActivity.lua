local IObject = require("api.IObject")
local IEventEmitter = require("api.IEventEmitter")

local IActivity = class.interface("IActivity", {}, { IObject, IEventEmitter })
IActivity._type = "base.activity"

function IActivity:build()
   print("initact")
   IObject.init(self)
   IEventEmitter.init(self)
   self.turns = 0
end

function IActivity:start()
   return self:emit("base.on_activity_start", {}, nil)
end

function IActivity:pass_turns(turns)
   local result = self:emit("base.on_activity_pass_turns", {turns=turns or 1}, nil)
   self.turns = self.turns - turns
   return result
end

function IActivity:finish()
   self:emit("base.on_activity_finish")
end

return IActivity
