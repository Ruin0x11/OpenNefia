local data = require("internal.data")
local Gui = require("api.Gui")
local Object = require("api.Object")
local config = require("internal.config")
local Log = require("api.Log")

local ICharaActivity = class.interface("ICharaActivity")

function ICharaActivity:init()
   self.activity = nil
end

function ICharaActivity:get_activity()
   return self.activity
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
   if self:is_player() then
      Gui.hud_widget("hud_auto_turn"):widget():set_shown(false)
   end
end

function ICharaActivity:finish_activity()
   self.activity:finish()
   self:remove_activity()
end

function ICharaActivity:_proc_activity_interrupted()
   local should_stop = self.activity:proc_interrupted()

   if should_stop then
      self:remove_activity()
   end

   return should_stop
end

function ICharaActivity:pass_activity_turn()
   if self:is_player() then
      -- TODO the performance of Gui.update_screen() is terrible, so this causes a
      -- lot of lag. There has to be some amount of optimization we can do.
      local auto_turn = config.base.auto_turn_speed

      local auto_turn_widget = Gui.hud_widget("hud_auto_turn"):widget()
      if auto_turn == "normal" then
         -- With screen update
         Gui.wait(self.activity.animation_wait)
         auto_turn_widget:pass_turn()
      elseif auto_turn == "high" then
         -- No screen update
         Gui.wait(self.activity.animation_wait, true)
         auto_turn_widget:pass_turn()
      elseif auto_turn == "highest" then
         -- Don't wait at all
      end
   end

   if self.activity and (self.activity.turns or 0) <= 0 then
      self:finish_activity()
      return "turn_end"
   end

   local result = self.activity:pass_turn()

   return result
end

local function make_activity(id, params)
   local obj = Object.generate_from("base.activity", id)
   Object.finalize(obj)
   local activity = data["base.activity"]:ensure(id)
   for property, ty in pairs(activity.params or {}) do
      local value = params[property]
      if type(value) ~= ty then
         error(("Activity %s requires parameter '%s' of type %s, got '%s'"):format(id, property, ty, tostring(value)))
      end
      obj[property] = value
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
         self.activity.turns = d(self.activity, params, self)
      elseif type(d) == "number" then
         self.activity.turns = d
      else
         error("invalid activity default_turns")
      end
   else
      self.activity.turns = 10
   end

   self.activity.turns = math.floor(self.activity.turns)

   local ok, result = xpcall(self.activity.start, debug.traceback, self.activity, self)

   if not ok or result == "stop" then
      self:remove_activity()
      if not ok then
         Log.error("Error starting activity: %s", result)
      end
   end

   if self:is_player() and not config.base.disable_auto_turn_anim then
      local auto_turn_anim_id = self.activity.proto.auto_turn_anim or nil
      Gui.hud_widget("hud_auto_turn"):widget():set_shown(true, auto_turn_anim_id)
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
