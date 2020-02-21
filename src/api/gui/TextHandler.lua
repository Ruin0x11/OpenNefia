local IKeyInput = require("api.gui.IKeyInput")
local KeybindTranslator = require("api.gui.KeybindTranslator")

local input = require("internal.input")

local TextHandler = class.class("TextHandler", IKeyInput)

local MODIFIERS = table.set {
   "ctrl",
   "alt",
   "shift",
   "gui"
}

function TextHandler:init()
   self.bindings = {}
   self.forwards = nil
   self.chars = {}
   self.this_frame = {}
   self.modifiers = {}
   self.finished = false
   self.canceled = false
   self.halted = false
   self.keybinds = KeybindTranslator:new()
end

local function translate(char, text)
   if text then
      return char
   end

   return nil
end

function TextHandler:receive_key(char, pressed, text, is_repeat)
   if self.forwards then
      self.forwards:receive_key(char, pressed, text, is_repeat)
   end

   if pressed and not is_repeat then self.halted = false end

   if MODIFIERS[char] then
      self.modifiers[char] = pressed
   end

   if not pressed then return end

   -- When IME input is sent, love first sends the keypress event of
   -- the user pressing "return" to confirm the IME submission, then
   -- it sends a text event with the text the IME entered in the same
   -- frame. Therefore, text shouldn't be submitted if a "return"
   -- keypress event is not the very last event received in this
   -- frame.
   if not text and char == "return" and pressed and not self.halted then
      self.finished = true
      return
   else
      -- If "return" was received earlier this frame, this prevents
      -- text submission.
      self.finished = false
   end

   if pressed and char == "escape" then
      self.canceled = true
   end

   if not text then
      self.this_frame[char] = true
      return
   end

   char = translate(char, text)
   if not char then return end
   table.insert(self.chars, char)
end

function TextHandler:bind_keys(bindings)
   for k, v in pairs(bindings) do
      self.bindings[k] = v
   end

   self.keybinds:enable(bindings)
end

function TextHandler:unbind_keys(bindings)
   for _, k in ipairs(bindings) do
      self.bindings[k] = nil
   end

   self.keybinds:disable(bindings)
end

function TextHandler:forward_to(handler)
   class.assert_is_an(IKeyInput, handler)
   self.forwards = handler
end

function TextHandler:focus()
   input.set_key_repeat(true)
   input.set_text_input(true)
   input.set_key_handler(self)
   self.keybinds:set_dirty()
end

function TextHandler:halt_input()
   self.modifiers = {}
   self.halted = true
end

function TextHandler:update_repeats()
end

function TextHandler:key_held_frames()
   return 0
end

function TextHandler:prepend_key_modifiers(key)
   local new = ""

   if self.modifiers.ctrl then
      new = new .. "ctrl_"
   end
   if self.modifiers.shift then
      new = new .. "shift_"
   end
   if self.modifiers.alt then
      new = new .. "alt_"
   end
   if self.modifiers.gui then
      new = new .. "gui_"
   end

   return new .. key
end


function TextHandler:run_key_action(key, ...)
   local keybind

   local special = false
   if key == "text_submitted" or key == "text_canceled" then
      keybind = key
      special = true
   else
      keybind = self.keybinds:key_to_keybind(key, self.modifiers)
   end

   local func = self.bindings[keybind]
   if func == nil and not special then
      func = self.bindings["raw_" .. key]
   end

   if func then
      return func(...)
   elseif not special and self.bindings["text_entered"] then
      return self.bindings["text_entered"](key, ...)
   elseif self.forwards then
      return self.forwards:run_key_action(key, ...)
   end

   return nil, false
end

function TextHandler:run_actions()
   local ran = {}
   for _, c in ipairs(self.chars) do
      self:run_key_action(c)
      ran[c] = true
   end

   for c, _ in pairs(self.this_frame) do
      if not ran[c] then
         local keybind = self.keybinds:key_to_keybind(c, self.modifiers)

         local func = self.bindings[keybind]
         if func == nil then
            local with_modifiers = self:prepend_key_modifiers(c)
            func = self.bindings["raw_" .. with_modifiers]
         end

         if func then
            func()
         end
      end
   end

   if self.finished then
      self:run_key_action("text_submitted")
   end

   if self.canceled then
      self:run_key_action("text_canceled")
   end

   self.chars = {}
   self.this_frame = {}

   self.finished = false
   self.canceled = false
end

return TextHandler
