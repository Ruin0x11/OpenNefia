local Gui = require("api.Gui")
local Input = require("api.Input")
local Event = require("api.Event")
local IObject = require("api.IObject")
local IEventEmitter = require("api.IEventEmitter")

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

local function interrupt_prompt(activity, _, should_stop)
   if activity.chara:is_player() then
      if activity.on_interrupt == "stop" then
         return true
      elseif activity.on_interrupt == "prompt" then
         Gui.update_screen()
         Gui.mes("Should we stop the activity? ")
         return Input.yes_no()
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
