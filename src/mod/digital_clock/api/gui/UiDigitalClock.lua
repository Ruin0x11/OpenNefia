local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local World = require("api.World")
local DateTime = require("api.DateTime")

local UiDigitalClock = class.class("UiDigitalClock", IUiWidget)

function UiDigitalClock:init(display_seconds)
   self.frame = 0
   self.time_of_day_text = ""
   self.date = DateTime:new()
   self.display_seconds = display_seconds
end

function UiDigitalClock:default_widget_position(x, y, width, height)
   return x + 16, y + 16
end

function UiDigitalClock:default_widget_refresh()
   self.date = World.date()
   self.time_of_day_text = World.time_to_text(self.date.hour)
end

function UiDigitalClock:default_widget_z_order()
   return 75000
end

function UiDigitalClock:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   self.padding = 4
   self.digit_w = self.t.digital_clock.digits:get_width() / 10
   self.colon_w = self.t.digital_clock.colon:get_width()

   if self.display_seconds then
      self.width = self.digit_w * 6 + self.colon_w * 2 + self.padding * 2
   else
      self.width = self.digit_w * 4 + self.colon_w     + self.padding * 2
   end
   self.height = self.t.digital_clock.digits:get_height() + self.padding * 2
end

function UiDigitalClock:draw()
   local digit_h_1 = math.floor(self.date.hour / 10)
   local digit_h_2 =            self.date.hour % 10
   local digit_m_1 = math.floor(self.date.minute / 10)
   local digit_m_2 =            self.date.minute % 10
   local digit_s_1 = math.floor(self.date.second / 10)
   local digit_s_2 = math.floor(self.date.second % 10)

   Draw.filled_rect(self.x, self.y, self.width, self.height, {70, 70, 100, 120})
   Draw.set_color(213, 213, 255)
   self.t.digital_clock.digits:draw_region(digit_h_1 + 1, self.x + self.padding,                                   self.y + self.padding)
   self.t.digital_clock.digits:draw_region(digit_h_2 + 1, self.x + self.padding + self.digit_w,                    self.y + self.padding)
   if math.floor(self.frame * 2) % 2 == 1 then
      self.t.digital_clock.colon:draw(                    self.x + self.padding + self.digit_w * 2,                self.y + self.padding)
   end
   self.t.digital_clock.digits:draw_region(digit_m_1 + 1, self.x + self.padding + self.digit_w * 2 + self.colon_w, self.y + self.padding)
   self.t.digital_clock.digits:draw_region(digit_m_2 + 1, self.x + self.padding + self.digit_w * 3 + self.colon_w, self.y + self.padding)
   if self.display_seconds then
      if math.floor(self.frame * 2) % 2 == 1 then
         self.t.digital_clock.colon:draw(                    self.x + self.padding + self.digit_w * 4 + self.colon_w,     self.y + self.padding)
      end
      self.t.digital_clock.digits:draw_region(digit_s_1 + 1, self.x + self.padding + self.digit_w * 4 + self.colon_w * 2, self.y + self.padding)
      self.t.digital_clock.digits:draw_region(digit_s_2 + 1, self.x + self.padding + self.digit_w * 5 + self.colon_w * 2, self.y + self.padding)
   end

   Draw.set_font(12)
   Draw.text_shadowed(string.format("%d/%d/%d (%s)", self.date.year, self.date.month, self.date.day, self.time_of_day_text),
             self.x + 5,
             self.y + self.height + self.padding,
             self.t.base.text_color_light,
             self.t.base.text_color_light_shadow)
end

function UiDigitalClock:update(dt)
   self.frame = self.frame + dt
end

return UiDigitalClock
