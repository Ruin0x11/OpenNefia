local data = require("internal.data")
local Object = require("api.Object")

local ICharaActivity = class.interface("ICharaActivity")

function ICharaActivity:init()
   self.activity = nil
end

function ICharaActivity:interrupt_activity()
   self.activity = nil
end

function ICharaActivity:finish_activity()
   self.activity:finish()
   self:interrupt_activity()
end

function ICharaActivity:pass_activity_turn(turns)
   local result = self.activity:pass_turns(turns)
   if result == "interrupt" then
      self:interrupt_activity()
      return
   end

   self.activity.turns = self.activity.turns - 1

   if result or self.activity.turns <= 0 then
      self:finish_activity()
   end
end

function ICharaActivity:start_activity(id, turns, params)
   assert(type(turns) == "number")
   self.activity = Object.generate_from("base.activity", id)
   local activity = data["base.activity"]:ensure(id)
   self.activity.turns = turns or activity.turns or 10
   for k, v in pairs(params) do
      local ty = activity.params[k]
      if ty and type(v) == ty then
         self.activity[k] = v
      end
   end

   if self.activity:start() == "interrupt" then
      self:interrupt_activity()
   end
end

return ICharaActivity
