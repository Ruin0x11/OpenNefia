local IKeyInput = require("api.gui.IKeyInput")

local internal = require("internal")

-- A key handler that will fire actions for any keys that were held in
-- previous frames, or keys that were pressed and released in the same
-- frame. For use when key repeat is *off*.
local HeldKeyHandler = class("HeldKeyHandler", IKeyInput)

function HeldKeyHandler:init()
   self.queue = {}
   self.bindings = {}
   self.pressed = {}
   self.this_frame = {}
   self.once = {}
end

function HeldKeyHandler:receive_key(key, pressed)
   if self.this_frame[key] == true then
      self.once[key] = true
   end
   if pressed then
      self.this_frame[key] = true
   end

   self.pressed[key] = pressed
   table.insert(self.queue, { key = key, pressed = pressed })
end

function HeldKeyHandler:bind_keys(bindings)
   self.bindings = bindings
end

function HeldKeyHandler:focus()
   internal.input.set_keyrepeat(false)
   internal.input.set_key_handler(self)
end

function HeldKeyHandler:run_action(key)
   local func = self.bindings[k.key]
   if func then func() end
end

function HeldKeyHandler:run_actions()
   local ran = {}
   for _, k in ipairs(self.queue) do
      if self.once[k.key] then
         self:run_action(k.key)
         ran[k.key] = true
         self.once[k.key] = false
      end
   end

   for key, p in pairs(self.pressed) do
      if p and not ran[key] then
         self:run_action(key)
      end
   end

   self.queue = {}
   self.this_frame = {}
   self.once = {}
end

return HeldKeyHandler
