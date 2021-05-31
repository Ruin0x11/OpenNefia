local IUiMouseButton = require("mod.mouse_ui.api.gui.IUiMouseButton")
local UiTheme = require("api.gui.UiTheme")
local IMouseElementProvider = require("api.gui.IMouseElementProvider")
local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local IMouseElement = require("api.gui.IMouseElement")

local UiMouseMenu = class.class("UiMouseMenu", IUiMouseElement)

function UiMouseMenu:init(opts)
   self.min_child_width = opts.child_width or 96
   self.min_child_height = opts.child_height or 48
   opts.children = opts.children or {}
   for _, button in ipairs(opts.children) do
      assert(class.is_an(IUiMouseButton, button))
   end
   self.children = opts.children
   self.display_direction = opts.display_direction or "vertical"
   self:_update_button_sizes()
end


function UiMouseMenu:_update_button_sizes()
   self.child_width = self.min_child_width
   self.child_height = self.min_child_height
   for _, button in ipairs(self.children) do
      assert(class.is_an(IUiMouseButton, button))
      self.child_width = math.max(self.child_width, button:get_minimum_width())
      self.child_height = math.max(self.child_height, button:get_minimum_height())
      button._parent = self
   end
end

function UiMouseMenu:get_mouse_elements(recursive)
   local regions = {}
   for _, child in ipairs(self.children) do
      if class.is_an(IMouseElement, child) then
         regions[#regions+1] = child
      end
      if recursive then
         table.append(regions, child:get_mouse_elements(recursive))
      end
   end
   return regions
end

function UiMouseMenu:get_minimum_width()
   if self.display_direction == "horizontal" then
      return math.max(self.min_child_width * #self.children, fun.iter(self.children):map(IUiMouseElement.get_minimum_width):sum())
   else
      return self.min_child_width * #self.children
   end
end

function UiMouseMenu:get_minimum_height()
   if self.display_direction == "horizontal" then
      return self.min_child_height * #self.children
   else
      return math.max(self.min_child_height * #self.children, fun.iter(self.children):map(IUiMouseElement.get_minimum_height):sum())
   end
end

function UiMouseMenu:find_menu(id)
   for _, button in self:iter_mouse_elements(true) do
      if button.id == id and class.is_an(IMouseElementProvider, button) then
         return button
      end
   end
end

function UiMouseMenu:add_button(button)
   assert(class.is_an(IUiMouseButton, button))
   self.children[#self.children+1] = button
   self:_update_button_sizes()
end

function UiMouseMenu:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   if self.display_direction == "horizontal" then
      for i, button in ipairs(self.children) do
         button:relayout(self.x + (i-1) * self.child_width, self.y, self.child_width, self.child_height)
      end
   else
      for i, button in ipairs(self.children) do
         button:relayout(self.x, self.y + (i-1) * self.child_height, self.child_width, self.child_height)
      end
   end
end

function UiMouseMenu:draw()
   for _, button in ipairs(self.children) do
      button:draw()
   end
end

function UiMouseMenu:update(dt)
   for _, button in ipairs(self.children) do
      button:update(dt)
   end
end

return UiMouseMenu
