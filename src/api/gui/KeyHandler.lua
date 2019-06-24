local IKeyInput = require("api.gui.IKeyInput")

local internal = require("internal")

-- TODO: needs to handle direction keypress combinations
local repeats = table.set {
   "up",
   "down",
   "left",
   "right"
}

-- A key handler that will fire actions only on the same frame a
-- keypressed event is received. For use when key repeat is *on*.
local KeyHandler = class("KeyHandler", IKeyInput)

function KeyHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.pressed = {}
   self.repeat_delays = {}
   self.forwards = nil
   self.halted = false
   self.stop_halt = true
end

function KeyHandler:receive_key(key, pressed, is_text, is_repeat)
   if is_text then return end
   if self.halted and is_repeat then return end

   -- if pressed and not repeats[key] and not self.pressed[key] then
   --    self.this_frame[key] = true
   --    self.stop_halt = true
   -- end

   if pressed then
      self.pressed[key] = true
   else
      self.pressed[key] = nil
      self.repeat_delays[key] = nil
   end
end

function KeyHandler:forward_to(handler)
   assert_is_an(IKeyInput, handler)
   self.forwards = handler
end

function KeyHandler:focus()
   -- BUG: will not take into account forwards. If there is a child
   -- element with a TextHandler, then text input could get messed up.
   internal.input.set_key_repeat(true)
   internal.input.set_text_input(false)
   internal.input.set_key_handler(self)
end

function KeyHandler:bind_keys(bindings)
   for k, v in pairs(bindings) do
      self.bindings[k] = v
   end
end

function KeyHandler:unbind_keys(bindings)
   for _, k in ipairs(bindings) do
      self.bindings[k] = nil
   end
end

function KeyHandler:halt_input()
   print("halt")
   self.repeat_delays = {}
   self.pressed = {}
   self.this_frame = {}
   self.halted = true
   self.stop_halt = false
end

function KeyHandler:run_key_action(key, ...)
   local func = self.bindings[key]
   if func then
      return func(...)
   elseif self.forwards then
      return self.forwards:run_key_action(key, ...)
   end
end

function KeyHandler:handle_repeat(key, dt)
   local it = self.repeat_delays[key] or {}

   if it.wait_remain == nil then
      if repeats[key] then
         it.wait_remain = 2
         it.delay = 200
      else
         it.wait_remain = 0
         it.delay = 600
      end
      it.pressed = true
   else
      it.pressed = false
      it.delay = it.delay - dt * 1000
      if it.delay <= 0 then
         it.wait_remain = it.wait_remain - 1
         if it.wait_remain <= 0 then
            it.fast = true
         end
         if it.fast then
            it.delay = 36
         else
            it.delay = 200
         end
         it.pressed = true
      end
   end

   if self.pressed["shift"] then
      it.delay = 10
   end

   self.repeat_delays[key] = it
end

function KeyHandler:update_repeats(dt)
   for key, v in pairs(self.pressed) do
      -- if repeats[key] then
         self:handle_repeat(key, dt)
      -- end
   end
end

function KeyHandler:run_actions(dt, ...)
   local ran = false
   local result

   self:update_repeats(dt)

   for key, v in pairs(self.repeat_delays) do
      -- TODO determine what movement actions should be triggered. If
      -- two movement keys can form a diagonal, they should be fired
      -- instead of each one individually.
      if v.pressed then
         result = self:run_key_action(key, ...)
         ran = true
         -- only run the first action
         break
      end
   end
   if not ran then
      for key, _ in pairs(self.this_frame) do
         result = self:run_key_action(key, ...)
         ran = true

         -- only run the first action
         break
      end
   end

   self.halted = self.halted and not self.stop_halt
   self.this_frame = {}

   return ran, result
end

return KeyHandler
