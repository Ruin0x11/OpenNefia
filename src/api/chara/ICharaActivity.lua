local data = require("internal.data")
local Gui = require("api.Gui")
local Object = require("api.Object")

local ICharaActivity = class.interface("ICharaActivity")

function ICharaActivity:init()
   self.activity = nil
end

function ICharaActivity:has_activity()
   return self.activity ~= nil
end

function ICharaActivity:interrupt_activity()
   if self.activity then
      self.activity:interrupt()
   end
end

function ICharaActivity:remove_activity()
   if self.activity then
      self.activity:cleanup()
   end
   self.activity = nil
end

function ICharaActivity:finish_activity()
   self.activity:finish()
   self:remove_activity()
end

function ICharaActivity:_proc_activity_interrupted()
   local should_stop = self.activity:proc_interrupted()

   if should_stop then
      Gui.mes_visible(self.uid .. " cancels the activity " .. self.activity._id, self.x, self.y)
      self:remove_activity()
   end

   return should_stop
end

function ICharaActivity:pass_activity_turn()
   Gui.wait(5 * self.activity.animation_wait)
   Gui.update_screen()

   local result = self.activity:pass_turn()
   if result and result.action == "stop" then
      self:remove_activity()
      return
   end

   if self.activity.turns <= 0 then
      self:finish_activity()
   end

   return (result and result.turn_result) or nil
end

local function make_activity(id, params)
   local obj = Object.generate_from("base.activity", id)
   local activity = data["base.activity"]:ensure(id)
   for k, v in pairs(params) do
      local ty = activity.params[k]
      if ty and type(v) == ty then
         obj[k] = v
      end
   end
   return obj
end

function ICharaActivity:start_activity(id, params, turns, force)
   if self.activity then
      if not force then
         error("activity already active")
      else
         self:remove_activity()
      end
   end

   params = params or {}
   self.activity = make_activity(id, params)
   self.activity.turns = turns or self.activity.default_turns or 10

   if self.activity:start(self) == "stop" then
      self:remove_activity()
   end
end

-- Creates and immediately finishes an activity without firing start
-- or pass turn events.
function ICharaActivity:create_and_finish_activity(id, params)
   self.activity = make_activity(id, params)
   self.activity.turns = 0
   self:finish_activity()
end

return ICharaActivity
