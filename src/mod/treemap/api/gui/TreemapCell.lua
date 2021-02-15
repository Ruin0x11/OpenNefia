local IUiElement = require("api.gui.IUiElement")
local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")
local Color = require("mod.extlibs.api.Color")

local TreemapCell = class.class("TreemapCell", IUiElement)

function TreemapCell:init(label, value_label, color, child)
   self.label = label
   self.value_label = value_label or ""
   self.color = color or { 100, 100, 200 }
   self.child = child
   self.font_size = 12
end

function TreemapCell:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.t = UiTheme.load(self)

   Draw.set_font(self.font_size)
   if self.child then
      local pad = Draw.text_height() + 10
      local pad2 = 10
      self.child:relayout(self.x + pad2, self.y + pad + pad2, self.width - pad2 * 2, self.height - pad - pad2 * 2)
   end
end

function TreemapCell:draw()
   Draw.set_font(self.font_size)
   local pad = Draw.text_height() + 10
   local color = Color:new_rgb(self.color)
   if self.height > pad then
      Draw.set_color(color:lighten_by(0.7):to_rgb())
      Draw.filled_rect(self.x, self.y, self.width, self.height)

      Draw.set_color(color:to_rgb())
      Draw.filled_rect(self.x, self.y + pad, self.width, self.height - pad)

      Draw.set_color(color:lighten_by(2.2):to_rgb())
      Draw.text(self.label, self.x + 5, self.y + 5)

      if self.height > pad + Draw.text_height() + 5 then
         Draw.set_color(color:lighten_by(2.2):to_rgb())
         Draw.text(self.value_label, self.x + 5, self.y + 5 + pad)
      end

      if self.child then
         self.child:draw()
      end
   else
      Draw.set_color(self.color)
      Draw.filled_rect(self.x, self.y, self.width, self.height)

      if self.height > pad then
         Draw.set_color(color:lighten_by(2.2):to_rgb())
         Draw.text(self.value_label, self.x + 5, self.y + 5)
      end
   end

   Draw.set_color(0, 0, 0)
   Draw.line_rect(self.x, self.y, self.width, self.height)
end

function TreemapCell:update(dt)
end

return TreemapCell
