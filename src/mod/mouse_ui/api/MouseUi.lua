local UiMouseButton = require("mod.mouse_ui.api.gui.UiMouseButton")
local UiMouseMenuButton = require("mod.mouse_ui.api.gui.UiMouseMenuButton")
local UiMouseMenu = require("mod.mouse_ui.api.gui.UiMouseMenu")

local MouseUi = {}

function MouseUi.make_mouse_menu(spec, display_direction, button_width, button_height)
   assert(type(spec) == "table")

   local buttons = {}

   for i, entry in ipairs(spec) do
      if entry.text == nil then
         error("Menu entry " .. i .. " missing 'text' property")
      end
      local text = tostring(entry.text)
      local element
      if entry.cb then
         element = UiMouseButton:new(text, entry.cb)
      elseif entry.menu then
         if entry.id == nil then
            error("Menu entry " .. i .. " missing 'id' property")
         end
         local l_button_width = entry.button_width
         local l_button_height = entry.button_height
         local l_display_direction = entry.display_direction or "horizontal"
         element = UiMouseMenuButton:new(text, entry.id, MouseUi.make_mouse_menu(entry.menu, "vertical", l_button_width, l_button_height), l_display_direction)
      else
         element = UiMouseButton:new(text)
      end
      buttons[#buttons+1] = element
   end

   return UiMouseMenu:new(buttons, display_direction, button_width, button_height)
end

function MouseUi.make_toolbar(spec, button_width, button_height)
   for _, entry in ipairs(spec) do
      if entry.menu then
         entry.display_direction = "vertical"
      end
   end
   return MouseUi.make_mouse_menu(spec, "horizontal", 96, 24)
end

return MouseUi
