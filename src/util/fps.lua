local fps = {}
local fps_mt = { __index = fps }

function fps:new()
   return setmetatable(
      {
         show_fps = true,
         ms = 0,
         frames = 0,
         fps = ""
      },
      fps_mt)
end

function update(dt)
   if not self.show_fps then return end

   self.ms = self.ms + dt * 1000
   self.frames = self.frames + 1

   if self.ms >= 1000 then
      fps = string.format("FPS: %02.2f", frames / (ms / 1000))
      self.frames = 0
      self.ms = 0
   end
end

function fps:draw()
   if not self.show_fps then return end

   Draw.set_color(255, 255, 255)
   Draw.set_font(14)

   Draw.text(self.fps, 5, Draw.get_height() - Draw.text_height() - 5)
end

return fps
