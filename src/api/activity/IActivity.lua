local Gui = require("api.Gui")
local Input = require("api.Input")
local Event = require("api.Event")
local IObject = require("api.IObject")
local IEventEmitter = require("api.IEventEmitter")
local I18N = require("api.I18N")

local IActivity = class.interface("IActivity", {}, { IObject, IEventEmitter })
IActivity._type = "base.activity"

function IActivity:build()
   IObject.init(self)
   IEventEmitter.init(self)
   self.turns = 0
   self.interrupted = false
end

function IActivity:start(doer)
   self.chara = doer
   return self:emit("base.on_activity_start", {chara=self.chara}, nil)
end

function IActivity:cleanup()
   self:emit("base.on_activity_cleanup", {chara=self.chara}, nil)
end

function IActivity:interrupt()
   self.interrupted = true
end

function IActivity:get_default_turns(params, chara)
   local turns
   local d = self.proto.default_turns
   if type(d) == "function" then
      turns = d(self, params, chara)
   elseif type(d) == "number" then
      turns = d
   else
      error("invalid activity default_turns")
   end
   return turns or 10
end

function IActivity:get_animation_wait()
   local animation_wait = self.proto.animation_wait
   if type(animation_wait) == "function" then
      animation_wait = animation_wait(self)
   elseif type(animation_wait) == "string" then
      animation_wait = animation_wait
   end
   return animation_wait or 0
end

function IActivity:get_auto_turn_anim()
   local auto_turn_anim = self.proto.auto_turn_anim
   if type(auto_turn_anim) == "function" then
      auto_turn_anim = auto_turn_anim(self)
   elseif type(auto_turn_anim) == "string" then
      auto_turn_anim = auto_turn_anim
   end
   return auto_turn_anim or nil
end

function IActivity:get_localized_name()
   local verb
   if type(self.proto.localize) == "function" then
      verb = I18N.get_optional(self.proto.localize(self))
   end
   if verb == nil then
      verb = I18N.get_optional("activity._." .. self._id .. ".verb")
   end
   if verb == nil then
      verb = "activity.default_verb"
   end

   return verb
end

local function interrupt_prompt(activity, _, should_stop)
   if activity.chara:is_player() then
      if activity.on_interrupt == "stop" then
         return true
      elseif activity.on_interrupt == "prompt" then
         -- >>>>>>>> shade2/command.hsp:4340 *com_rowActCancel ...
         Gui.update_screen()
         Gui.mes("activity.cancel.prompt", activity:get_localized_name())
         return Input.yes_no()
         -- <<<<<<<< shade2/command.hsp:4343 	return ..
      end
   else
      return true
   end

   return should_stop
end

Event.register("base.on_activity_interrupt", "Interrupt prompt", interrupt_prompt)

function IActivity:proc_interrupted()
   local should_stop = false

   if self.interrupted then
      self.interrupted = false
      should_stop = self:emit("base.on_activity_interrupt", {chara=self.chara}, false)
   end

   return should_stop
end

function IActivity:pass_turn()
   -- TODO pcall
   local result = self:emit("base.on_activity_pass_turns", {chara=self.chara}, "turn_end")
   self.turns = self.turns - 1
   return result
end

function IActivity:finish(doer)
   -- support skipping the start/pass turns lifecycle
   if doer and not self.chara then
      self.chara = doer
   end

   self:emit("base.on_activity_finish", {chara=self.chara})
end

return IActivity
