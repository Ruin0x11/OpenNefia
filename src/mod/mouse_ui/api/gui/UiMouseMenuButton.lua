local Draw = require("api.Draw")

local IMouseElementProvider = require("api.gui.IMouseElementProvider")
local UiMouseMenu = require("mod.mouse_ui.api.gui.UiMouseMenu")
local IUiMouseButton = require("mod.mouse_ui.api.gui.IUiMouseButton")
local UiShadowedText = require("api.gui.UiShadowedText")
local UiTheme = require("api.gui.UiTheme")

local UiMouseMenuButton = class.class("UiMouseMenuButton", {IUiMouseButton, IMouseElementProvider})

function UiMouseMenuButton:init(text, id, menu, display_direction)
   self.text = UiShadowedText:new(text)
   self.id = id
   self.pressed = false
   self.enabled = true
   self:set_menu(menu)
   self.label_vertices = {}
   self.label_vertices_pressed = {}
   self.display_direction = display_direction or "horizontal"
end

function UiMouseMenuButton:get_mouse_elements(recursive)
   if self.menu then
      return self.menu:get_mouse_elements(recursive)
   end
   return {}
end

function UiMouseMenuButton:get_minimum_width()
   return self.text:text_width() + 6
end

function UiMouseMenuButton:get_minimum_height()
   return self.text:text_height() + 6
end

function UiMouseMenuButton:add_button(button)
   if self.menu == nil then
      self.menu = UiMouseMenu:new({})
   end
   self.menu:add_button(button)
   button._parent = self
end

function UiMouseMenuButton:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   self.label_vertices = {
      self.x + self.width - 2, self.y + self.height - 2,
      self.x + self.width - 2, self.y + self.height - 2 - 10,
      self.x + self.width - 2 - 10, self.y + self.height - 2,
   }
   self.label_vertices_pressed = fun.iter(self.label_vertices):map(function(i) return i + 2 end):to_list()

   if self.menu then
      local bx = self.x
      local by = self.y
      if self.display_direction == "vertical" then
         by = self.y + self.height
      else
         bx = self.x + self.menu.button_width
      end
      local button_count = self.menu:iter_mouse_elements():length()
      if self.y + self.menu.button_height * button_count > Draw.get_height() then
         by = self.y - self.menu.button_height * button_count
      end
      if self.x + self.menu.button_width > Draw.get_width() then
         bx = self.x - self.menu.button_width
      end
      self.menu:relayout(bx, by, self.width, self.height)
   end
end

function UiMouseMenuButton:on_mouse_pressed(x, y, button)
   if button == 1 then
      self:set_pressed(not self.pressed)
      return true
   end
   return false
end

function UiMouseMenuButton:on_mouse_released(x, y, button)
   return true
end

function UiMouseMenuButton:is_mouse_region_enabled()
   return self.enabled
end

function UiMouseMenuButton:is_pressed()
   return self.pressed
end

function UiMouseMenuButton:is_enabled()
   return self.enabled
end

function UiMouseMenuButton:set_pressed(pressed)
   self.pressed = pressed

   if self.menu then
      for _, ui_button in self.menu:iter_mouse_elements()  do
         ui_button.enabled = self.pressed
      end
   end
end

function UiMouseMenuButton:set_enabled(enabled)
   self.enabled = enabled
end

function UiMouseMenuButton:set_text(text)
   self.text:set_data(text)
end

function UiMouseMenuButton:set_menu(menu)
   if menu then
      assert(class.is_an(UiMouseMenu, menu))
      for _, ui_button in menu:iter_mouse_elements(false)  do
         ui_button._parent = self
      end
   end
   self.menu = menu
end

function UiMouseMenuButton:draw()
   Draw.set_color(192, 192, 192)
   Draw.filled_rect(self.x, self.y, self.width-1, self.height-1)

   Draw.set_color(128, 128, 128)
   if self.pressed then
      Draw.filled_polygon(self.label_vertices_pressed)
   else
      Draw.filled_polygon(self.label_vertices)
   end

   if self.pressed then
      Draw.set_color(128, 128, 128)
   else
      Draw.set_color(255, 255, 255)
   end
   Draw.line(self.x, self.y, self.x + self.width, self.y)
   Draw.line(self.x, self.y, self.x, self.y + self.height)

   if self.pressed then
      Draw.set_color(192, 192, 192)
   else
      Draw.set_color(128, 128, 128)
   end
   Draw.line(self.x, self.y + self.height-1, self.x + self.width, self.y + self.height-1)
   Draw.line(self.x + self.width, self.y, self.x + self.width, self.y + self.height)

   local w = self.text:text_width()
   local h = self.text:text_height()
   local x = self.x + (self.width / 2) - (w / 2)
   local y = self.y + (self.height / 2) - (h / 2)
   if self.pressed then
      x = x + 2
      y = y + 2
   end
   self.text:relayout(x, y)

   self.text:draw()

   if self.menu and self.pressed then
      self.menu:draw()
   end
end

function UiMouseMenuButton:update(dt)
   if self.pressed and self.menu then
      self.menu:update(dt)
   end
end

return UiMouseMenuButton
