local Gui = require("api.Gui")
local config = require("internal.config")
local Log = require("api.Log")
local I18N = require("api.I18N")
local Activity = require("api.Activity")

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
      Gui.mes_visible("activity.cancel.normal", self.x, self.y, self, I18N.get_optional("activity._." .. self.activity._id .. ".verb") or "activity.default_verb")
      self:remove_activity()
   end

   return should_stop
end

function ICharaActivity:pass_activity_turn()
   if self:is_player() then
      local anim_wait = self.activity:get_animation_wait()
      if self.activity and anim_wait > 0 then
         local auto_turn = config.base.auto_turn_speed
         local auto_turn_widget = Gui.hud_widget("hud_auto_turn"):widget()
         if auto_turn == "normal" then
            -- With screen update
            Gui.wait(anim_wait, true)
            auto_turn_widget:pass_turn()
         elseif auto_turn == "high" then
            -- No screen update
            Gui.wait(anim_wait)
            auto_turn_widget:pass_turn()
         elseif auto_turn == "highest" then
            -- Don't wait at all
         end
      end
   end

   if self.activity and (self.activity.turns or 0) <= 0 then
      self:finish_activity()
      return "turn_end"
   end

   local result = self.activity:pass_turn()

   return result
end

function ICharaActivity:start_activity(id, params, turns)
   if self.activity then
      self:remove_activity()
   end

   params = params or {}
   self.activity = Activity.create(id, params)

   if turns then
      self.activity.turns = turns
   else
      self.activity.turns = self.activity:get_default_turns()
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
      local anim_wait = self.activity:get_animation_wait()
      if anim_wait > 0 then
         local auto_turn_anim_id = self.activity:get_auto_turn_anim() or nil
         Gui.hud_widget("hud_auto_turn"):widget():set_shown(true, auto_turn_anim_id)
      end
   end
end

-- Creates and immediately finishes an activity without firing start
-- or pass turn events.
function ICharaActivity:create_and_finish_activity(id, params)
   self.activity = Activity.create(id, params)
   self.activity.turns = 0
   self:finish_activity()
end

return ICharaActivity
