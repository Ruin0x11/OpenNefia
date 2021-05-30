local Draw = require("api.Draw")
local Color = require("mod.extlibs.api.Color")

local UiMousePadding = require("mod.mouse_ui.api.gui.UiMousePadding")
local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local UiTheme = require("api.gui.UiTheme")

local UiMousePanel = class.class("UiMousePanel", IUiMouseElement)

function UiMousePanel:init(opts)
   self.padding = opts.padding or UiMousePadding:new()
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
   Draw.set_color(self.color)
   Draw.filled_rect(self.x, self.y, self.width-1, self.height-1)

   if self.pressed then
      Draw.set_color(self.color_dark)
   else
      Draw.set_color(self.color_light)
   end
   Draw.line(self.x, self.y, self.x + self.width, self.y)
   Draw.line(self.x, self.y, self.x, self.y + self.height)

   if self.pressed then
      Draw.set_color(self.color_light)
   else
      Draw.set_color(self.color_dark)
   end
   Draw.line(self.x, self.y + self.height-1, self.x + self.width, self.y + self.height-1)
   Draw.line(self.x + self.width, self.y, self.x + self.width, self.y + self.height)

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
