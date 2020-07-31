local data = require("internal.data")
local Gui = require("api.Gui")
local Object = require("api.Object")

local ICharaActivity = class.interface("ICharaActivity")

function ICharaActivity:init()
   self.activity = nil
end

function ICharaActivity:has_activity(id)
   if id == nil then
      return self.activity ~= nil
   end

   return self.activity ~= nil and self.activity._id == id
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
   -- TODO the performance of Gui.update_screen() is terrible, so this causes a
   -- lot of lag. There has to be some amount of optimization we can do.
   Gui.wait(self.activity.animation_wait)

   if self.activity and (self.activity.turns or 0) <= 0 then
      self:finish_activity()
      return "turn_end"
   end

   local result = self.activity:pass_turn()

   return result
end

local function make_activity(id, params)
   local obj = Object.generate_from("base.activity", id)
   local activity = data["base.activity"]:ensure(id)
   for k, v in pairs(params) do
      local ty = activity.params[k]
      if ty and type(v) == ty then
         -- TODO obj.params[k] = v
         obj[k] = v
      end
   end
   return obj
end

function ICharaActivity:start_activity(id, params, turns)
   if self.activity then
      self:remove_activity()
   end

   params = params or {}
   self.activity = make_activity(id, params)

   if turns then
      self.activity.turns = math.floor(turns)
   elseif self.activity.default_turns then
      local d = self.activity.default_turns
      if type(d) == "function" then
         self.activity.turns = d(self.activity, params)
      elseif type(d) == "number" then
         self.activity.turns = d
      else
         error("invalid activity default_turns")
      end
   else
      self.activity.turns = 10
   end

   local ok, result = pcall(self.activity.start, self.activity, self)

   if not ok or result == "stop" then
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
