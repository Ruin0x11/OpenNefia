local input = require("internal.input")

local Input = {}

Input.set_key_handler = input.set_key_handler
Input.set_mouse_handler = input.set_mouse_handler

function Input.query(ui)
   -- internal.draw.push_ui(ui)
   if not ui.update then
      error("Not a UI object: " .. tostring(ui))
   end
   if ui.focus then ui:focus() end
   while true do
      local res = ui:update()
      if res then return res end
      coroutine.yield()
   end
   -- internal.draw.pop_ui(ui)
end

return Input
