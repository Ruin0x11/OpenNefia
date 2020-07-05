local IMouseInput = require("api.gui.IMouseInput")

local input = require("internal.input")

local MouseHandler = class.class("MouseHandler", IMouseInput)

function MouseHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.forwards = nil
   self.movement = nil
end

function MouseHandler:receive_mouse_button(x, y, button, pressed)
   self.this_frame[button] = {x = x, y = y, pressed = pressed}
end

function MouseHandler:receive_mouse_movement(x, y, dx, dy)
   self.movement = {x = x, y = y, dx = dx, dy = dy}
end

function MouseHandler:bind_mouse(bindings)
   self.bindings = bindings
end

function MouseHandler:forward_to(handlers)
   if not handlers[1] then
      handlers = { handlers }
   end
   for _, handler in ipairs(handlers) do
      assert(class.is_an(IMouseInput, handler))
   end
   self.forwards = handlers
end

function MouseHandler:focus()
   input.set_mouse_handler(self)
end

function MouseHandler:halt_input()
end

function MouseHandler:update_repeats()
end

function MouseHandler:enqueue_macro()
end

function MouseHandler:clear_macro_queue()
end

function MouseHandler:run_mouse_action(button, x, y, pressed)
   local func = self.bindings["button_" .. button]
   if func then
      func(x, y, pressed)
   elseif self.forwards then
      --self.forwards:run_mouse_action(button, x, y, pressed)
   end
end

function MouseHandler:run_mouse_movement_action(x, y, dx, dy)
   local func = self.bindings["moved"]
   if func then
      func(x, y, dx, dy)
   elseif self.forwards then
      --self.forwards:run_mouse_movement_action(x, y, dx, dy)
   end
end

function MouseHandler:run_actions()
   local ran = {}
   for k, v in pairs(self.this_frame) do
      self:run_mouse_action(k, v.x, v.y, v.pressed)
   end

   if self.movement then
      self:run_mouse_movement_action(self.movement.x,
                                     self.movement.y,
                                     self.movement.dx,
                                     self.movement.dy)
   end

   self.this_frame = {}
   self.movement = nil
end

return MouseHandler
