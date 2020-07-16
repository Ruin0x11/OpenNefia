local Log = require("api.Log")
local IKeyInput = require("api.gui.IKeyInput")
local KeybindTranslator = require("api.gui.KeybindTranslator")
local Queue = require("api.Queue")

local input = require("internal.input")

-- TODO: needs to handle direction keypress combinations
local REPEATS = table.set {
   "north",
   "south",
   "west",
   "east",
   "northwest",
   "northeast",
   "southwest",
   "southeast"
}

local MODIFIERS = table.set {
   "ctrl",
   "alt",
   "shift",
   "gui"
}

-- A key handler that will fire actions only on the same frame a
-- keypressed event is received. For use when key repeat is *on*.
local KeyHandler = class.class("KeyHandler", IKeyInput)

function KeyHandler:init(no_repeat_delay, capture_released)
   self.bindings = {}
   self.pressed = {}
   self.unpressed_this_frame = {}
   self.repeat_delays = {}
   self.modifiers = {}
   self.forwards = {}
   self.halted = false
   self.stop_halt = true
   self.frames_held = 0
   self.keybinds_held = {}
   self.keybinds = KeybindTranslator:new()
   self.macro_queue = Queue:new()

   self.no_repeat_delay = no_repeat_delay
   self.capture_released = capture_released
end

function KeyHandler:receive_key(key, pressed, is_text, is_repeat)
   for _, forward in ipairs(self.forwards) do
      forward:receive_key(key, pressed, is_text, is_repeat)
   end

   if is_text then return end
   if self.halted and is_repeat then return end

   if MODIFIERS[key] then
      self.modifiers[key] = pressed
   end

   if pressed then
      self.pressed[key] = true
   else
      self.pressed[key] = nil
      self.repeat_delays[key] = nil
      self.unpressed_this_frame[key] = true
   end
end

function KeyHandler:forward_to(handlers)
   if not handlers[1] then
      handlers = { handlers }
   end
   for _, handler in ipairs(handlers) do
      class.assert_is_an(IKeyInput, handler)
   end
   self.forwards = handlers
end

function KeyHandler:focus()
   -- BUG: will not take into account forwards. If there is a child
   -- element with a TextHandler, then text input could get messed up.
   input.set_key_repeat(true)
   input.set_text_input(false)
   input.set_key_handler(self)
   self.keybinds:set_dirty()
end

function KeyHandler:bind_keys(bindings)
   for k, v in pairs(bindings) do
      if self.bindings[k] ~= nil then
         Log.trace("in %s: Overwriting existing key binding for '%s'", tostring(self), k)
      end

      self.bindings[k] = v
   end

   self.keybinds:enable(bindings)
end

function KeyHandler:unbind_keys(bindings)
   for _, k in ipairs(bindings) do
      self.bindings[k] = nil
   end

   self.keybinds:disable(bindings)
end

function KeyHandler:halt_input()
   self.repeat_delays = {}
   self.pressed = {}
   self.modifiers = {}
   self.halted = true
   self.stop_halt = false
   self.frames_held = 0
   self.keybinds_held = {}
   self:clear_macro_queue()
end

-- Special key repeat for keys bound to a movement action.
function KeyHandler:is_repeating_key(key)
   return REPEATS[self.keybinds:key_to_keybind(key, {}) or ""]
end

function KeyHandler:prepend_key_modifiers(key)
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

function KeyHandler:is_modifier_held(modifier)
   return not not self.modifiers[modifier]
end

function KeyHandler:ignore_modifiers(modifiers)
   self.keybinds:ignore_modifiers(modifiers)
end

function KeyHandler:run_key_action(key, ...)
   local it = self.repeat_delays[key]
   if it then
      it.wait_remain = it.wait_remain - 1
      if it.wait_remain <= 0 then
         if self:is_repeating_key(key) then
            it.delay = 40 * 2
         end
         it.fast = true
      elseif it.fast then
         if self:is_repeating_key(key) then
            it.delay = 40 * 2
         else
            it.delay = 10
         end
      else
         it.delay = 200
      end
      it.pressed = false
   end

   local keybind = self.keybinds:key_to_keybind(key, self.modifiers)
   if Log.has_level("trace") then
      Log.trace("Keybind: %s %s -> \"%s\" %s", key, inspect(self.modifiers), keybind, self)
   end

   if self.bindings[keybind] == nil then
      local with_modifiers = self:prepend_key_modifiers(key)
      keybind = "raw_" .. with_modifiers
   end

   self.keybinds_held[key] = self.keybinds_held[key] or {}
   table.insert(self.keybinds_held[key], keybind)

   local ran, result = self:run_keybind_action(keybind, true, ...)

   if not ran then
      for _, forward in ipairs(self.forwards) do
         local did_something, first_result = forward:run_key_action(key, ...)
         if did_something then
            return did_something, first_result
         end
      end
   end

   return ran, result
end

function KeyHandler:run_keybind_action(keybind, pressed, ...)
   local func = self.bindings[keybind]
   if func then
      return true, func(pressed, ...)
   end

   return false, nil
end

function KeyHandler:handle_repeat(key, dt)
   local it = self.repeat_delays[key] or {}

   if it.wait_remain == nil then
      if self:is_repeating_key(key) then
         if self.no_repeat_delay then
            it.wait_remain = 0
            it.delay = 40
         else
            it.wait_remain = 3
            it.delay = 200
         end
      else
         it.wait_remain = 0
         it.delay = 600
      end
      it.pressed = true
   else
      it.delay = it.delay - dt * 1000
      if it.delay <= 0 then
         -- Wait until a key action is fired for this key to remove
         -- pressed state.
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
      self:handle_repeat(key, dt)
   end
end

function KeyHandler:key_held_frames()
   return self.frames_held
end

function KeyHandler:enqueue_macro(keybind)
   if self.bindings[keybind] == nil then
      return false
   end
   self.macro_queue:push(keybind)
   return true
end

function KeyHandler:clear_macro_queue()
   self.macro_queue:clear()
end

function KeyHandler:release_key(key, ...)
   local keybinds = self.keybinds_held[key]
   if keybinds then
      for _, keybind in ipairs(keybinds) do
         if self.capture_released then
            self:run_keybind_action(keybind, false, ...)
         end
      end
      self.keybinds_held[key] = nil
   end

   for _, forward in ipairs(self.forwards) do
      forward:release_key(key, ...)
   end
end

function KeyHandler:run_actions(dt, ...)
   local ran = false
   local result

   if self.macro_queue:len() > 0 then
      local keybind = self.macro_queue:pop()
      return self:run_keybind_action(keybind, true, ...)
   end

   self:update_repeats(dt)

   for key, _ in pairs(self.unpressed_this_frame) do
      self:release_key(key)
   end

   for key, v in pairs(self.repeat_delays) do
      -- TODO: determine what movement actions should be triggered. If
      -- two movement keys can form a diagonal, they should be fired
      -- instead of each one individually.
      if v.pressed then
         ran, result = self:run_key_action(key, ...)
         if ran then
            -- only run the first action
            break
         end
      end
   end

   self.keybinds_held = {}
   self.unpressed_this_frame = {}

   self.halted = self.halted and not self.stop_halt

   if next(self.pressed) then
      if ran then
         self.frames_held = self.frames_held + 1
      end
   else
      self.frames_held = 0
   end

   return ran, result
end

return KeyHandler
