local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IHudElement = require("api.gui.hud.IHudElement")

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

   self.clock = Draw.load_image("graphic/temp/clock.bmp")
   self.clock_hand = Draw.load_image("graphic/temp/clock_hand.bmp")
   self.date_label_frame = Draw.load_image("graphic/temp/date_label_frame.bmp")
end

function UiClock:set_data(date)
   self.date = date
end

function UiClock.set_transparency(alpha)
end

function UiClock:relayout(x, y)
   self.x = x
   self.y = y
end

function UiClock:draw()
   Draw.set_color(255, 255, 255)
   Draw.image(self.clock, self.x, self.y)
   Draw.image(self.date_label_frame, self.x + 78, self.y + 8)
   Draw.image(self.clock_hand, self.x + 62, self.y + 48, nil, nil, nil, true, self.date.hour * 30 + self.date.minute / 2)
   Draw.image(self.clock_hand, self.x + 62, self.y + 48, self.clock_hand:getWidth() / 2, nil, nil, true, self.date.minute * 6)

   Draw.text(string.format("%d/%d/%d", self.date.year, self.date.month, self.date.day),
             self.x + 120,
             self.y + 17, -- + vfix
             {0, 0, 0})
   Draw.text_shadowed(times[self.date.hour / 4 + 1] or "", self.x + 120 + 6, self.y + 35)
end

function UiClock:update()
end

return UiClock
