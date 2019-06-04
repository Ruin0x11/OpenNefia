local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IHudElement = require("api.gui.hud.IHudElement")
local UiTheme = require("api.gui.UiTheme")

local UiClock = class("UiClock", {IHudElement, ISettable})

local times = {
   "Midnight",
   "Dawn",
   "Morning",
   "Noon",
   "Dusk",
   "Night",
   "",
   "",
}

function UiClock:init()
   self.date = {
      hour = math.random(12),
      minute = math.random(60),
      year = 876,
      month = 6,
      day = 2,
   }
end

function UiClock:set_data(date)
   self.date = date
end

function UiClock.set_transparency(alpha)
end

function UiClock:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiClock:draw()
   Draw.set_color(255, 255, 255)
   self.t.clock:draw(self.x, self.y)
   self.t.date_label_frame:draw(self.x + 78, self.y + 8)
   self.t.clock_hand:draw(self.x + 62, self.y + 48, nil, nil, nil, true, self.date.hour * 30 + self.date.minute / 2)
   self.t.clock_hand:draw(self.x + 62, self.y + 48, self.t.clock_hand:get_height() / 2, nil, nil, true, self.date.minute * 6)

   Draw.text(string.format("%d/%d/%d", self.date.year, self.date.month, self.date.day),
             self.x + 120,
             self.y + 17, -- + vfix
             self.t.text_color)
   Draw.text_shadowed(times[self.date.hour / 4 + 1] or "",
                      self.x + 120 + 6,
                      self.y + 35,
                      self.t.text_color_light,
                      self.t.text_color_light_shadow)
end

function UiClock:update()
end

return UiClock
