local Log = require("api.Log")
local IKeyInput = require("api.gui.IKeyInput")
local KeybindTranslator = require("api.gui.KeybindTranslator")

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

function KeyHandler:init(no_repeat_delay)
   self.bindings = {}
   self.this_frame = {}
   self.pressed = {}
   self.repeat_delays = {}
   self.modifiers = {}
   self.forwards = nil
   self.halted = false
   self.stop_halt = true
   self.frames_held = 0
   self.keybinds = KeybindTranslator:new()

   self.no_repeat_delay = no_repeat_delay

   self:bind_keys {
      repl = function()
         require("game.field"):query_repl()
      end
   }
end

function KeyHandler:receive_key(key, pressed, is_text, is_repeat)
   if self.forwards then
      self.forwards:receive_key(key, pressed, is_text, is_repeat)
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
   end
end

function KeyHandler:forward_to(handler)
   class.assert_is_an(IKeyInput, handler)
   self.forwards = handler
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
         Log.warn("in %s: Overwriting existing key binding for '%s'", tostring(self), k)
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
   self.this_frame = {}
   self.modifiers = {}
   self.halted = true
   self.stop_halt = false
   self.frames_held = 0
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
      Log.trace("Keybind: %s %s %s", key, keybind)
   end

   local func = self.bindings[keybind]
   if func == nil then
      local with_modifiers = self:prepend_key_modifiers(key)
      func = self.bindings["raw_" .. with_modifiers]
   end
   if func then
      return func(...), true
   elseif self.forwards then
      return self.forwards:run_key_action(key, ...)
   end

   return nil, false
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

function KeyHandler:run_actions(dt, ...)
   local ran = false
   local result

   self:update_repeats(dt)

   for key, v in pairs(self.repeat_delays) do
      -- TODO: determine what movement actions should be triggered. If
      -- two movement keys can form a diagonal, they should be fired
      -- instead of each one individually.
      if v.pressed then
         result, ran = self:run_key_action(key, ...)
         if ran then
            -- only run the first action
            break
         end
      end
   end
   if not ran then
      for key, _ in pairs(self.this_frame) do
         result, ran = self:run_key_action(key, ...)

         if ran then
            -- only run the first action
            break
         end
      end
   end

   self.halted = self.halted and not self.stop_halt
   self.this_frame = {}

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
