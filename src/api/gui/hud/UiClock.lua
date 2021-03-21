local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local DateTime = require("api.DateTime")
local World = require("api.World")
local save = require("internal.global.save")
local I18N = require("api.I18N")
local UiShadowedText = require("api.gui.UiShadowedText")

local UiClock = class.class("UiClock", {IUiWidget, ISettable})

function UiClock:init()
   self.date = DateTime:new()
   self.date_text = ""
   self.time_weather_text = UiShadowedText:new("")
end

function UiClock:default_widget_position(x, y, width, height)
   return x, y
end

function UiClock:default_widget_refresh()
   self:set_data(save.base.date)
end

function UiClock:set_data(date)
   self.date = date
   self.date_text = Draw.make_text(("%d/%d/%d"):format(self.date.year, self.date.month, self.date.day))
   self.time_weather_text = UiShadowedText:new(("%s %s"):format(World.time_to_text(self.date.hour), I18N.get("weather." .. save.elona.weather_id .. ".name")), 13)
end

function UiClock:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
   self.width = self.t.base.clock:get_width()
   self.height = self.t.base.clock:get_height()
end

function UiClock:draw()
   Draw.set_font(13)

   -- >>>>>>>> shade2/screen.hsp:326 					;clock ..
   Draw.set_color(255, 255, 255)
   self.t.base.clock:draw(self.x, self.y)
   self.t.base.date_label_frame:draw(self.x + 78, self.y + 8)
   -- <<<<<<<< shade2/screen.hsp:332 	gcopy selInf,448,376,128,24 ...

   -- >>>>>>>> shade2/screen.hsp:345 	color 0 ..
   local hour_rot = self.date.hour * 30 + self.date.minute / 2 + self.date.second / 60
   local minute_rot = self.date.minute * 6 + self.date.second / 10

   self.t.base.clock_hand:draw(self.x + 62, self.y + 48, nil, nil, nil, true, hour_rot)
   self.t.base.clock_hand:draw(self.x + 62, self.y + 48, self.t.base.clock_hand:get_height() / 2, nil, nil, true, minute_rot)

   Draw.text(self.date_text,
             self.x + 120,
             self.y + 17, -- + vfix
             self.t.base.text_color)
   self.time_weather_text:relayout(self.x + 120 + 6, self.y + 35)
   self.time_weather_text:draw()
   -- <<<<<<<< shade2/screen.hsp:351  ..
end

function UiClock:update()
end

return UiClock
