local IMouseInput = require("api.gui.IMouseInput")

local internal = require("internal")

local MouseHandler = class("MouseHandler", IMouseInput)

function MouseHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.movement = nil
end

function MouseHandler:receive_mouse_button(x, y, button, pressed)
   self.this_frame[button] = {x = x, y = y, pressed = pressed}
end

function MouseHandler:receive_mouse_movement(x, y, dx, dy)
   self.movement = {x = x, y = y, dx = dx, dy = dy}
end

function MouseHandler:bind_actions(bindings)
   self.bindings = bindings
end

function MouseHandler:focus()
   internal.input.set_mouse_handler(self)
end

function MouseHandler:run_actions()
   local ran = {}
   for k, v in pairs(self.this_frame) do
      local func = self.bindings[k]
      if func then func(v.x, v.y, v.pressed) end
   end

   if self.movement then
      local func = self.bindings["moved"]
      if func then func(self.movement.x,
                        self.movement.y,
                        self.movement.dx,
                        self.movement.dy) end
   end

   self.this_frame = {}
   self.movement = nil
end

return MouseHandler
