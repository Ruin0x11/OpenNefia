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
   self.halted = false
end

function HeldKeyHandler:receive_key(key, pressed, text)
   if text then return end

   if self.this_frame[key] == true then
      self.once[key] = true
   end
   if pressed then
      self.this_frame[key] = true
   end

   if pressed == false then
      -- This is so table.count(self.pressed) can return 0 to
      -- determine when key halt should stop.
      self.pressed[key] = nil
   else
      self.pressed[key] = true
   end

   table.insert(self.queue, { key = key, pressed = pressed })
end

function HeldKeyHandler:forward_to()
end

function HeldKeyHandler:halt_input()
   self.halted = true
   self.pressed = {}
end

function HeldKeyHandler:update_repeats()
end

function HeldKeyHandler:bind_keys(bindings)
   for k, v in pairs(bindings) do
      self.bindings[k] = v
   end
end

function HeldKeyHandler:unbind_keys(bindings)
   for _, k in ipairs(bindings) do
      self.bindings[k] = nil
   end
end

function HeldKeyHandler:focus()
   internal.input.set_key_repeat(false)
   internal.input.set_text_input(false)
   internal.input.set_key_handler(self)
end

function HeldKeyHandler:run_key_action(key)
   if self.halted then return end
   local func = self.bindings[key]
   if func then func() end
end

function HeldKeyHandler:run_actions()
   local ran = {}
   for _, k in ipairs(self.queue) do
      if self.once[k.key] then
         self:run_key_action(k.key)
         ran[k.key] = true
         self.once[k.key] = false
      end
   end

   for key, p in pairs(self.pressed) do
      if p and not ran[key] then
         self:run_key_action(key)
      end
   end

   self.halted = self.halted and (table.count(self.pressed) ~= 0)
   self.queue = {}
   self.this_frame = {}
   self.once = {}
end

return HeldKeyHandler
