local input = {}

local default_mouse_handler = {}
local mouse_handler = default_mouse_handler

function input.set_mouse_handler(tbl)
   mouse_handler = tbl
end

function input.reset_mouse_handler()
   mouse_handler = default_mouse_handler
end

function input.mousemoved(x, y, dx, dy, istouch)
end

function input.mousepressed(x, y, button, istouch)
   local func = mouse_handler[button]
   if func then
      func(x, y, true, istouch)
   end
end

function input.mousereleased(x, y, button, istouch)
   local func = mouse_handler[button]
   if func then
      func(x, y, false, istouch)
   end
end


local default_key_handler = {}
local key_handler = default_key_handler

function input.set_key_handler(tbl)
   key_handler = tbl
end

function input.reset_key_handler()
   key_handler = default_key_handler
end

function input.keypressed(key)
   local func = key_handler[key]
   if func then
      func(true)
   end
end

function input.keyreleased(key)
   local func = key_handler[key]
   if func then
      func(false)
   end
end


return input
