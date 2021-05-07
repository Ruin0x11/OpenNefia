local IMouseInput = require("api.gui.IMouseInput")
local IKeyInput = require("api.gui.IKeyInput")
local config = require("internal.config")
local draw = require("internal.draw")

local input = {}

local key_handler = nil
local mouse_handler = nil

function input.set_mouse_handler(tbl)
   if tbl ~= nil then
      class.assert_is_an(IMouseInput, tbl)
   end
   mouse_handler = tbl
end

function input.mousemoved(x, y, dx, dy, istouch)
   if mouse_handler then
      local lx, ly = draw.get_logical_viewport()
      mouse_handler:receive_mouse_movement(x - lx, y - ly, dx, dy)
   end
end

function input.mousepressed(x, y, button, istouch)
   if mouse_handler then
      local lx, ly = draw.get_logical_viewport()
      mouse_handler:receive_mouse_button(x - lx, y - ly, button, true)
   end
end

function input.mousereleased(x, y, button, istouch)
   if mouse_handler then
      local lx, ly = draw.get_logical_viewport()
      mouse_handler:receive_mouse_button(x - lx, y - ly, button, false)
   end
end


function input.set_key_handler(tbl)
   if tbl ~= nil then
      class.assert_is_an(IKeyInput, tbl)
   end
   key_handler = tbl
end

local function normalize_key(scancode)
   if scancode == "lshift" or scancode == "rshift" then
      return "shift"
   elseif scancode == "lctrl" or scancode == "rctrl" then
      return "ctrl"
   elseif scancode == "lalt" or scancode == "ralt" then
      return "alt"
   elseif scancode == "lgui" or scancode == "rgui" then
      return "gui"
   end
   return scancode
end

function input.keypressed(key, scancode, isrepeat)
   if key_handler then
      key_handler:receive_key(normalize_key(key), true, false, isrepeat)
   end
end

function input.keyreleased(key, scancode)
   if key_handler then
      key_handler:receive_key(normalize_key(key), false, false)
   end
end

local joystick_deadzone = 0.75
local joystick_axes = {}

-- Joystick axes will never trigger LÖVE events, hence this function.
function input.poll_joystick_axes()
   local joystick = love.joystick.getJoysticks()[1]
   if joystick == nil then
      joystick_axes = {}
      return
   end

   for axis = 1, joystick:getAxisCount() do
      local value = joystick:getAxis(axis)
      local current = joystick_axes[axis]
      if current ~= "+" and value > joystick_deadzone then
         if current == "-" then
            input.joystickreleased(joystick, "axis_" .. axis .. "_-")
         end
         input.joystickpressed(joystick, "axis_" .. axis .. "_+")
         joystick_axes[axis] = "+"
      elseif current ~= "-" and value < -joystick_deadzone then
         if current == "+" then
            input.joystickreleased(joystick, "axis_" .. axis .. "_+")
         end
         input.joystickpressed(joystick, "axis_" .. axis .. "_-")
         joystick_axes[axis] = "-"
      elseif value >= -joystick_deadzone and value <= joystick_deadzone then
         if current == "+" then
            input.joystickreleased(joystick, "axis_" .. axis .. "_+")
         elseif current == "-" then
            input.joystickreleased(joystick, "axis_" .. axis .. "_-")
         end
         joystick_axes[axis] = nil
      end
   end
end

function input.joystickpressed(joystick, button)
   if key_handler then
      key_handler:receive_key("joystick_" .. button, true, false, false)
   end
end

function input.joystickreleased(joystick, button)
   if key_handler then
      key_handler:receive_key("joystick_" ..  button, false, false)
   end
end

function input.textinput(text)
   if key_handler then
      key_handler:receive_key(text, true, true)
   end
end

function input.halt_input()
   if mouse_handler then
      mouse_handler:halt_input()
   end

   if key_handler then
      key_handler:halt_input()
   end
end

input.set_key_repeat = love.keyboard.setKeyRepeat
input.set_text_input = love.keyboard.setTextInput

function input.set_keybinds(kbs)
   config.base.keybinds = kbs
end

return input
