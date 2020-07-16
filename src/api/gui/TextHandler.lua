local IKeyInput = require("api.gui.IKeyInput")
local Log = require("api.Log")
local KeybindTranslator = require("api.gui.KeybindTranslator")
local Queue = require("api.Queue")

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
   self.forwards = {}
   self.chars = {}
   self.this_frame = {}
   self.modifiers = {}
   self.finished = false
   self.canceled = false
   self.halted = false
   self.keybinds = KeybindTranslator:new()
   self.macro_queue = Queue:new()
end

local function translate(char, text)
   if text then
      return char
   end

   return nil
end

function TextHandler:receive_key(char, pressed, text, is_repeat)
   for _, forward in ipairs(self.forwards) do
      forward:receive_key(char, pressed, text, is_repeat)
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

function TextHandler:forward_to(handlers)
   if not handlers[1] then
      handlers = { handlers }
   end
   for _, handler in ipairs(handlers) do
      class.assert_is_an(IKeyInput, handler)
   end
   self.forwards = handlers
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
   self:clear_macro_queue()
end

function TextHandler:update_repeats()
end

function TextHandler:key_held_frames()
   return 0
end

function TextHandler:enqueue_macro(keybind)
   if self.bindings[keybind] == nil then
      return false
   end
   self.macro_queue:push(keybind)
   return true
end

function TextHandler:clear_macro_queue()
   self.macro_queue:clear()
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

function TextHandler:is_modifier_held(modifier)
   return not not self.modifiers[modifier]
end

function TextHandler:ignore_modifiers(modifiers)
   self.keybinds:ignore_modifiers(modifiers)
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

   if self.bindings[keybind] == nil and not special then
      keybind = "raw_" .. key
   end

   if self.bindings[keybind] == nil
      and not special
      and string.len(key) == 1
      and self.bindings["text_entered"]
   then
      return true, self.bindings["text_entered"](key, ...)
   end

   if Log.has_level("trace") then
      Log.trace("Keybind: %s %s -> \"%s\" %s", key, inspect(self.modifiers), keybind, self)
   end

   local ran, result = self:run_keybind_action(keybind, true, ...)

   if not ran then
      for _, forward in ipairs(self.forwards) do
         local did_something, first_result = forward:run_key_action(key, ...)
         if did_something then
            return did_something, first_result
         end
      end
   end

   return ran
end

function TextHandler:run_keybind_action(keybind, pressed, ...)
   local func = self.bindings[keybind]
   if func then
      return true, func(pressed, ...)
   end

   return false, nil
end

function TextHandler:release_key(key, ...)
end

function TextHandler:run_actions()
   local ran = {}

   if self.macro_queue:len() > 0 then
      local keybind = self.macro_queue:pop()
      self:run_keybind_action(keybind, true)
      return
   end

   for _, c in ipairs(self.chars) do
      self:run_key_action(c)
      ran[c] = true
   end

   for c, _ in pairs(self.this_frame) do
      if not ran[c] then
         local keybind = self.keybinds:key_to_keybind(c, self.modifiers)
         if Log.has_level("trace") then
            Log.trace("Keybind: %s %s %s", c, keybind, self)
         end

         if self.bindings[keybind] == nil then
            keybind = "raw_" .. c
         end
         self:run_keybind_action(keybind, true)
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
