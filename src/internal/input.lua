local IMouseInput = require("api.gui.IMouseInput")
local IKeyInput = require("api.gui.IKeyInput")
local config = require("internal.config")

local input = {}

local mouse_handler = nil

function input.set_mouse_handler(tbl)
   if tbl ~= nil then
      class.assert_is_an(IMouseInput, tbl)
   end
   mouse_handler = tbl
end

function input.reset_mouse_handler()
   mouse_handler = default_mouse_handler
end

function input.mousemoved(x, y, dx, dy, istouch)
   if mouse_handler then
      mouse_handler:receive_mouse_movement(x, y, dx, dy)
   end
end

function input.mousepressed(x, y, button, istouch)
   if mouse_handler then
      mouse_handler:receive_mouse_button(x, y, button, true)
   end
end

function input.mousereleased(x, y, button, istouch)
   if mouse_handler then
      mouse_handler:receive_mouse_button(x, y, button, false)
   end
end


local key_handler = nil

function input.set_key_handler(tbl)
   if tbl ~= nil then
      class.assert_is_an(IKeyInput, tbl)
   end
   key_handler = tbl
end

local function translate_scancode(scancode)
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
      key_handler:receive_key(translate_scancode(scancode), true, false, isrepeat)
   end
end

function input.keyreleased(key, scancode)
   if key_handler then
      key_handler:receive_key(translate_scancode(scancode), false, false)
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
   config["base.keybinds"] = kbs
end

return input
