local Draw = require("api.Draw")
local IDrawable = require("api.gui.IDrawable")

local fps = class("fps", IDrawable)

function fps:init()
   self.show_fps = true
   self.ms = 0
   self.frames = 0
   self.text = ""
end

function fps:update(dt)
   if not self.show_fps then return end

   self.ms = self.ms + dt * 1000
   self.frames = self.frames + 1

   if self.ms >= 1000 then
      self.text = string.format("FPS: %02.2f", self.frames / (self.ms / 1000))
      self.frames = 0
      self.ms = 0
   end
end

function fps:draw()
   if not self.show_fps then return end

   Draw.set_color(255, 255, 255)
   Draw.set_font(14)

   Draw.text(self.text, Draw.get_width() - Draw.text_width(self.text) - 5, 5)
end

return fps
