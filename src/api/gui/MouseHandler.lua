local IMouseInput = require("api.gui.IMouseInput")
local IMouseElement = require("api.gui.IMouseElement")
local PriorityMap = require("api.PriorityMap")

local input = require("internal.input")

local MouseHandler = class.class("MouseHandler", IMouseInput)

function MouseHandler:init()
   self.bindings = {}
   self.this_frame = {}
   self.regions_this_frame = {}
   self.mouse_elements = PriorityMap:new()
   self.active_regions = {}
   self.forwards = nil
   self.movement = nil
end

function MouseHandler:receive_mouse_button(x, y, button, pressed)
   self.this_frame[button] = {x = x, y = y, pressed = pressed}

   if pressed then
      for _, _, region in self.mouse_elements:iter() do
         if region:is_mouse_intersecting(x, y, button, pressed) and region:is_mouse_region_enabled() then
            local other_region = self.active_regions[button]
            if other_region then
               other_region:on_mouse_released(x, y, button)
            end

            region:on_mouse_pressed(x, y, button)
            self.active_regions[button] = region
            self.regions_this_frame[region] = {x = x, y = y, button = button, pressed = true}
         end
      end
   else
      local region = self.active_regions[button]
      if region then
         region:on_mouse_released(x, y, button)
         self.regions_this_frame[region] = {x = x, y = y, button = button, pressed = false}
      end
   end
end

function MouseHandler:receive_mouse_movement(x, y, dx, dy)
   self.movement = {x = x, y = y, dx = dx, dy = dy}
end

function MouseHandler:bind_mouse(bindings)
   self.bindings = bindings
end

function MouseHandler:bind_mouse_elements(ui_elements, priority)
   for _, ui_element in ipairs(ui_elements) do
      assert(class.is_an(IMouseElement, ui_element))
      self.mouse_elements:set(ui_element, true, priority or 100000)
   end
end

function MouseHandler:unbind_mouse_elements(ui_elements, priority)
   for _, ui_element in ipairs(ui_elements) do
      assert(class.is_an(IMouseElement, ui_element))
      self.mouse_elements:set(ui_element, nil)
   end
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
   -- for _, forward in ipairs(self.forwards) do
   --    forward:halt_input()
   -- end
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

function MouseHandler:run_mouse_element_action(element, pressed, x, y, button)
   local func = self.bindings["element"]
   if func then
      func(element, pressed, x, y, button)
   elseif self.forwards then
      --self.forwards:run_mouse_element_action(element, pressed, x, y, button)
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
   for k, v in pairs(self.this_frame) do
      self:run_mouse_action(k, v.x, v.y, v.pressed)
   end
   for element, v in pairs(self.regions_this_frame) do
      self:run_mouse_element_action(element, v.pressed, v.x, v.y, v.button)
   end

   if self.movement then
      self:run_mouse_movement_action(self.movement.x,
                                     self.movement.y,
                                     self.movement.dx,
                                     self.movement.dy)
   end

   self.this_frame = {}
   self.regions_this_frame = {}
   self.movement = nil
end

return MouseHandler
