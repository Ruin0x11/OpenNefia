local IUiElement = require("api.gui.IUiElement")
local IUiMouseButton = require("api.gui.IUiMouseButton")
local UiTheme = require("api.gui.UiTheme")
local IMouseElementProvider = require("api.gui.IMouseElementProvider")

local UiMouseMenu = class.class("UiMouseMenu", {IUiElement, IMouseElementProvider})

function UiMouseMenu:init(buttons, display_direction, button_width, button_height)
   for _, button in ipairs(buttons) do
      assert(class.is_an(IUiMouseButton, button))
   end
   self.buttons = buttons
   self.display_direction = display_direction or "vertical"
   self.button_width = button_width or 96
   self.button_height = button_height or 48
end

function UiMouseMenu:get_mouse_elements(recursive)
   local regions = {}
   for _, button in ipairs(self.buttons) do
      regions[#regions+1] = button
      if recursive and class.is_an(IMouseElementProvider, button) then
         table.append(regions, button:get_mouse_elements(recursive))
      end
   end
   return regions
end

function UiMouseMenu:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   if self.display_direction == "horizontal" then
      for i, button in ipairs(self.buttons) do
         button:relayout(self.x + (i-1) * self.button_width, self.y, self.button_width, self.button_height)
      end
   else
      for i, button in ipairs(self.buttons) do
         button:relayout(self.x, self.y + (i-1) * self.button_height, self.button_width, self.button_height)
      end
   end
end

function UiMouseMenu:draw()
   for _, button in ipairs(self.buttons) do
      button:draw()
   end
end

function UiMouseMenu:update(dt)
   for _, button in ipairs(self.buttons) do
      button:update(dt)
   end
end

return UiMouseMenu
