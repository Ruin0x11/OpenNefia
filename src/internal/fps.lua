local Draw = require("api.Draw")
local IDrawable = require("api.gui.IDrawable")
local fps_graph = require("internal.fps_graph")

local fps = class.class("fps", IDrawable)

function fps:init()
   self.show_fps = true
   self.show_draw_stats = true
   self.draw_stats = {}
   self.ms = 0
   self.frames = 0
   self.text = ""
   self.threshold = 200
   self.prev_fps = 0
   self.prev_ram = 0

   self.fps_graph = fps_graph:new({0, 0, 255})
   self.ram_graph = fps_graph:new({255, 0, 0})
   self.ram_diff_graph = fps_graph:new({0, 255, 0})

   self.fps_graph:relayout(0, 0, 0, 0)
   self.ram_graph:relayout(0, 0, 0, 0)
   self.ram_diff_graph:relayout(0, 0, 0, 0)
end

function fps:update(dt)
   if not self.show_fps then return end

   self.ms = self.ms + dt * 1000
   self.frames = self.frames + 1

   if self.ms >= self.threshold then
      local fps = self.frames / (self.ms / 1000)
      local ram = collectgarbage("count") / 1024
      local diff = ram - self.prev_ram
      self.text = string.format("FPS: %02.2f\nRAM: %04.2fMB \nRMD: %04.4fMB", fps, ram, diff)
      self.frames = 0
      self.ms = 0

      self.fps_graph:add_point(fps)
      self.ram_graph:add_point(ram)
      self.ram_diff_graph:add_point(diff)

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

      Draw.set_font(14)
      local x = Draw.get_width() - Draw.text_width(self.text) - 10 - 100

      self.fps_graph:relayout(x, 5, 100, 40)
      self.ram_graph:relayout(x, 5 + 45, 100, 40)
      self.ram_diff_graph:relayout(x, 5 + 45 + 45, 100, 40)

      self.prev_fps = fps
      self.prev_ram = ram
      self.prev_diff = diff
   end
end

function fps:draw()
   if not self.show_fps then return end

   Draw.set_color(255, 255, 255)
   Draw.set_font(14)

   Draw.text(self.text, Draw.get_width() - Draw.text_width(self.text) - 5, 5)

   self.fps_graph:draw()
   self.ram_graph:draw()
   self.ram_diff_graph:draw()
end

return fps
