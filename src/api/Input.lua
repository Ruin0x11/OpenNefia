local input = require("internal.input")
local IUiLayer = require("api.gui.IUiLayer")

local internal = require("internal")

local Input = {}

Input.set_key_handler = input.set_key_handler
Input.set_mouse_handler = input.set_mouse_handler

function Input.query(ui)
   if not is_an(IUiLayer, ui) then
      error("Not a UI layer: " .. tostring(ui))
   end

   local dt = 0

   internal.draw.push_layer(ui)

   ui:focus()

   while true do
      ui:run_actions()
      local res, canceled = ui:update(dt)
      if res or canceled then return res, canceled end
      dt = coroutine.yield()
   end

   internal.draw.pop_layer()
end

return Input
