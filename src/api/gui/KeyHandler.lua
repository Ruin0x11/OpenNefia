local IKeyInput = require("api.gui.IKeyInput")

local internal = require("internal")

-- A key handler that will fire actions only on the same frame a
-- keypressed event is received. For use when key repeat is *on*.
local KeyHandler = class("KeyHandler", IKeyInput)

function KeyHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.forwards = {}
end

function KeyHandler:receive_key(key, pressed)
   if pressed then
      self.this_frame[key] = true
   end
end

function KeyHandler:forward_to(handler, keys)
   assert_is_an(IKeyInput, handler)
   if type(keys) == "table" then
      local it = {}
      for _, v in ipairs(keys) do
         it[v] = true
      end
      table.insert(self.forwards, { handler = handler, keys = it })
   else
      table.insert(self.forwards, { handler = handler })
   end
end

function KeyHandler:focus()
   internal.input.set_keyrepeat(true)
   internal.input.set_key_handler(self)
end

function KeyHandler:bind_actions(bindings)
   self.bindings = bindings
end

function KeyHandler:run_action(key)
   local func = self.bindings[key]
   if func then
      func()
   else
      for _, f in ipairs(self.forwards) do
         if not f.keys or f.keys[key] then
            f.handler:run_action(key)
            break
         end
      end
   end
end

function KeyHandler:run_actions()
   local ran = {}
   for key, _ in pairs(self.this_frame) do
      self:run_action(key)
   end

   self.this_frame = {}
end

return KeyHandler
