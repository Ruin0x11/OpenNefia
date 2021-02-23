local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")

local UiShadowedText = class.class("UiShadowedText", {IUiElement, ISettable})

function UiShadowedText:init(str, font, color, shadow_color)
   self.font_width, self.font_style = font or 14, nil
   self.color = color or {255, 255, 255}
   self.shadow_color = shadow_color or {0, 0, 0}

   self:set_data(str)
end

function UiShadowedText:relayout(x, y)
   self.x = x
   self.y = y
end

function UiShadowedText:set_data(str)
   Draw.set_font(self.font_width, self.font_style)
   self.text = Draw.make_text(str)
end

function UiShadowedText:draw()
   Draw.set_color(self.shadow_color[1], self.shadow_color[2], self.shadow_color[3], self.shadow_color[4])
   Draw.set_font(self.font_width, self.font_style)
   for dx = -1, 1 do
      for dy = -1, 1 do
         Draw.text(self.text, self.x + dx, self.y + dy)
      end
   end
   Draw.set_color(self.color[1], self.color[2], self.color[3], self.color[4])
   Draw.text(self.text, self.x, self.y)
end

function UiShadowedText:update(dt)
end

return UiShadowedText
