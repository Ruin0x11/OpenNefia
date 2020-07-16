local IInput = require("api.gui.IInput")
local KeyHandler = require("api.gui.KeyHandler")
local MouseHandler = require("api.gui.MouseHandler")

local InputHandler = class.class("InputHandler", IInput)

InputHandler:delegate("keys", {
                         "bind_keys",
                         "unbind_keys",
                         "receive_key",
                         "run_key_action",
                         "run_keybind_action",
                         "key_held_frames",
                         "is_modifier_held",
                         "ignore_modifiers",
                         "release_key",
})
InputHandler:delegate("mouse", {
                         "bind_mouse",
                         "receive_mouse_movement",
                         "receive_mouse_button",
                         "run_mouse_action",
                         "run_mouse_movement_action"
})

function InputHandler:init(keys)
   self.keys = keys or KeyHandler:new()
   self.mouse = MouseHandler:new()

   self:bind_keys {
      repl = function()
         require("game.field"):query_repl()
      end
   }
end

function InputHandler:focus()
   self.keys:focus()
   self.mouse:focus()
end

function InputHandler:forward_to(handler, keys)
   self.keys:forward_to(handler, keys)
   self.mouse:forward_to(handler)
end

function InputHandler:halt_input()
   self.keys:halt_input()
   self.mouse:halt_input()
end

function InputHandler:update_repeats(dt)
   self.keys:update_repeats(dt)
   self.mouse:update_repeats(dt)
end

function InputHandler:run_actions(dt, ...)
   local ran, result = self.keys:run_actions(dt, ...)
   self.mouse:run_actions()

   return ran, result
end

function InputHandler:enqueue_macro(action)
   return self.keys:enqueue_macro(action)
end

function InputHandler:clear_macro_queue()
   self.keys:clear_macro_queue()
end

return InputHandler
