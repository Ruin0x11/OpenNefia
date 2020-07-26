local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local DateTime = require("api.DateTime")
local World = require("api.World")

local UiClock = class.class("UiClock", {IUiWidget, ISettable})

function UiClock:init()
   self.date = DateTime:new()
end

function UiClock:set_data(date)
   self.date = date
end

function UiClock:default_widget_position(x, y, width, height)
   return x, y
end

function UiClock:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiClock:draw()
   Draw.set_color(255, 255, 255)
   self.t.base.clock:draw(self.x, self.y)
   self.t.base.date_label_frame:draw(self.x + 78, self.y + 8)

   local hour_rot = self.date.hour * 30 + self.date.minute / 2 + self.date.second / 60
   local minute_rot = self.date.minute * 6 + self.date.second / 10

   self.t.base.clock_hand:draw(self.x + 62, self.y + 48, nil, nil, nil, true, hour_rot)
   self.t.base.clock_hand:draw(self.x + 62, self.y + 48, self.t.base.clock_hand:get_height() / 2, nil, nil, true, minute_rot)

   Draw.text(string.format("%d/%d/%d", self.date.year, self.date.month, self.date.day),
             self.x + 120,
             self.y + 17, -- + vfix
             self.t.base.text_color)
   Draw.text_shadowed(World.time_to_text(self.date.hour),
                      self.x + 120 + 6,
                      self.y + 35,
                      self.t.base.text_color_light,
                      self.t.base.text_color_light_shadow)
end

function UiClock:update()
end

return UiClock
