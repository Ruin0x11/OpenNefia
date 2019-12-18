local Draw = require("api.Draw")
local IDrawable = require("api.gui.IDrawable")

local fps = class.class("fps", IDrawable)

function fps:init()
   self.show_fps = true
   self.show_draw_stats = true
   self.draw_stats = {}
   self.ms = 0
   self.frames = 0
   self.text = ""
   self.threshold = 200
end

function fps:update(dt)
   if not self.show_fps then return end

   self.ms = self.ms + dt * 1000
   self.frames = self.frames + 1

   if self.ms >= self.threshold then
      self.text = string.format("FPS: %02.2f\nRAM: %04.2fMB", self.frames / (self.ms / 1000), collectgarbage("count") / 1024)
      self.frames = 0
      self.ms = 0

      if self.show_draw_stats then
         love.graphics.getStats(self.draw_stats)
         if self.draw_stats.drawcalls then
            self.text = self.text .. string.format("\nDRW: %d\nCNV: %d\nTXTR: %04.2fMB\nIMG: %d\nCNVS: %d\nFNTS: %d",
                                                   self.draw_stats.drawcalls,
                                                   self.draw_stats.canvasswitches,
                                                   self.draw_stats.texturememory / 1024 / 1024,
                                                   self.draw_stats.images,
                                                   self.draw_stats.canvases,
                                                   self.draw_stats.fonts)
         end
      end
   end
end

function fps:draw()
   if not self.show_fps then return end

   Draw.set_color(255, 255, 255)
   Draw.set_font(14)

   Draw.text(self.text, Draw.get_width() - Draw.text_width(self.text) - 5, 5)
end

return fps
