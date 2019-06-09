local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")
local ISettable = require("api.gui.ISettable")

local UiBar = class("UiBar", {IUiElement, ISettable})

function UiBar:init(bar_kind, max, value, show_digit)
   value = value or max

   self.bar_kind = bar_kind
   self.max = max
   self.value = math.min(value, max)
   self.show_digit = show_digit or true

   self:recalc_inner_width()
end

function UiBar:recalc_inner_width()
   self.inner_width = math.min(math.floor(self.value * 84 / self.max), 100)
end

function UiBar:set_data(value, max)
   self.value = value
   if max then
      self.max = max
   end

   self:recalc_inner_width()
end

function UiBar:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
   self.bar = self.t[self.bar_kind]
end

function UiBar:draw()
   Draw.set_font(12, "bold") -- 12 - en * 2
   self.t.hp_bar_frame:draw(self.x, self.y, 104, 15, {255, 255, 255})

   if self.inner_width > 0 then
      Draw.set_color(255, 255, 255)
      self.bar:draw_percentage_bar(self.x + 16, self.y + 5, self.inner_width, 6)
   end

   if self.show_digit then
      Draw.text_shadowed(string.format("%d(%d)", self.value, self.max),
                         self.x + 20,
                         self.y - 8,
                         self.t.text_color_light,
                         self.t.text_color_light_shadow)
   end
end

function UiBar:update()
end

return UiBar