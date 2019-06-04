local IKeyInput = require("api.gui.IKeyInput")

local internal = require("internal")

local GameKeyHandler = class("GameKeyHandler", IKeyInput)

local repeats = table.set {
   "up",
   "down",
   "left",
   "right"
}

function GameKeyHandler:init()
   self.bindings = {}
   self.this_frame = nil
   self.forwards = nil
   self.no_repeat = false
   self.repeat_delays = {}
   self.pressed = {}
   self.this_frame = {}
   self.once = {}
end

function GameKeyHandler:receive_key(key, pressed, text)
   if text then return end

   if pressed and not repeats[key] then
      self.this_frame[key] = true
   end

   if pressed == false then
      -- This is so table.count(self.pressed) can return 0 to
      -- determine when key halt should stop.
      self.pressed[key] = nil
      self.repeat_delays[key] = nil
   else
      self.pressed[key] = true
   end
end

function GameKeyHandler:handle_repeat(key)
   local it = self.repeat_delays[key] or {}

   if it.wait_remain == nil then
      it.wait_remain = 2
      it.delay = 8
      it.pressed = true
   else
      it.pressed = false
      it.delay = it.delay - 1
      if it.delay <= 0 then
         it.wait_remain = it.wait_remain - 1
         if it.fast then
            it.delay = 2
         else
            it.delay = 8
         end
         it.pressed = true
         if it.wait_remain == 0 then
            it.fast = true
         end
      end
   end

   self.repeat_delays[key] = it
end

function GameKeyHandler:forward_to(handler)
end

function GameKeyHandler:focus()
   internal.input.set_key_repeat(true)
   internal.input.set_text_input(false)
   internal.input.set_key_handler(self)
end

function GameKeyHandler:bind_keys(bindings)
   for k, v in pairs(bindings) do
      self.bindings[k] = v
   end
end

function GameKeyHandler:unbind_keys(bindings)
   for _, k in ipairs(bindings) do
      self.bindings[k] = nil
   end
end

function GameKeyHandler:halt_input()
   self.repeat_delays = {}
end

function GameKeyHandler:run_key_action(key)
   local func = self.bindings[key]
   if func then func() end
end

function GameKeyHandler:run_actions()
   for key, v in pairs(self.pressed) do
      if repeats[key] then
         self:handle_repeat(key)
      end
   end
   for key, v in pairs(self.repeat_delays) do
      if v.pressed then
         self:run_key_action(key)
      end
   end
   for key, _ in pairs(self.this_frame) do
      self:run_key_action(key)
   end

   self.this_frame = {}
end

return GameKeyHandler
