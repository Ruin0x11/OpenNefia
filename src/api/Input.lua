local input = require("internal.input")
local IUiLayer = require("api.gui.IUiLayer")

local Input = {}

Input.set_key_handler = input.set_key_handler
Input.set_mouse_handler = input.set_mouse_handler

function Input.query(ui)
   if not is_an(IUiLayer, ui) then
      error("Not a UI layer: " .. tostring(ui))
   end

   local dt = 0

   -- internal.draw.push_ui(ui)

   if ui.focus then ui:focus() end

   while true do
      local res, canceled = ui:update(dt)
      if res or canceled then return res, canceled end
      dt = coroutine.yield()
   end
   -- internal.draw.pop_ui(ui)
end

return Input
