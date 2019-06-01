local IKeyInput = require("api.gui.IKeyInput")

local internal = require("internal")

-- A key handler that will fire actions only on the same frame a
-- keypressed event is received. For use when key repeat is *on*.
local KeyHandler = class("KeyHandler", IKeyInput)

function KeyHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.forwards = nil
end

function KeyHandler:receive_key(key, pressed, text)
   if pressed and not text then
      self.this_frame[key] = true
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
end

function KeyHandler:run_key_action(key)
   local func = self.bindings[key]
   if func then
      func()
   elseif self.forwards then
      self.forwards:run_key_action(key)
   end
end

function KeyHandler:run_actions()
   local ran = {}
   for key, _ in pairs(self.this_frame) do
      self:run_key_action(key)
   end

   self.this_frame = {}
end

return KeyHandler
