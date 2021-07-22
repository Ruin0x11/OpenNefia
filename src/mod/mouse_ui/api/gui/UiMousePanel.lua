local Color = require("mod.extlibs.api.Color")

local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local UiTheme = require("api.gui.UiTheme")
local UiMouseStyle = require("mod.mouse_ui.api.UiMouseStyle")

local UiMousePanel = class.class("UiMousePanel", IUiMouseElement)

function UiMousePanel:init(opts)
   self.padding = opts.padding or UiMouseStyle.default_padding()
   self:set_child(opts.child)
end

function UiMousePanel:get_mouse_elements(recursive)
   if self.child then
      return self.child:get_mouse_elements(recursive)
   end
   return {}
end

function UiMousePanel:set_child(child)
   if child ~= nil then
      assert(class.is_an(IUiMouseElement, child))
      child._parent = self
   end
   self.child = child
end

function UiMousePanel:get_minimum_width()
   return math.max(self.width, self.child and self.child:get_minimum_width() or 0)
end

function UiMousePanel:get_minimum_height()
   return math.max(self.height, self.child and self.child:get_minimum_height() or 0)
end

function UiMousePanel:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   self.color = {192, 192, 192}
   self.color_dark = {Color:new_rgb(self.color):lighten_by(0.5):to_rgb()}
   self.color_light = {Color:new_rgb(self.color):lighten_by(1.5):to_rgb()}

   if self.child then
      self.child:relayout(self.padding:apply(self.x, self.y, self.width, self.height))
   end
end

function UiMousePanel:draw()
   UiMouseStyle.draw_panel(self.x, self.y, self.width, self.height, 2, self.pressed, self.color, self.color_dark, self.color_light)

   if self.child then
      self.child:draw()
   end
end

function UiMousePanel:update(dt)
   if self.child then
      self.child:update(dt)
   end
end

return UiMousePanel
