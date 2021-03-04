local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local CircularBuffer = require("api.CircularBuffer")

local UiFpsGraph = class.class("UiFpsGraph", IUiElement)

function UiFpsGraph:init(color, smoothing_factor, base_max, base_min)
   self.max = 0
   self.min = 0
   self.base_max = base_max or nil
   self.base_min = base_min or nil
   self.use_min = true
   self.step = 1
   self.points = CircularBuffer:new(100)
   self.smoothed = CircularBuffer:new(100)
   self.color = color or {0, 0, 255, 128}
   self.smoothing_factor = smoothing_factor or 1.0
end

function UiFpsGraph:relayout(x, y, width, height)
   self.x = x
   self.y = y
   local size = math.max(math.floor(self.width / self.step), 2)
   if size > self.points.max_length then
      self.points = CircularBuffer:new(size)
      self.smoothed = CircularBuffer:new(size)
   end
   self.width = width
   self.height = height
end

function UiFpsGraph:update()
end

function UiFpsGraph:clear()
   self.max = 0
   self.points = CircularBuffer:new(100)
end

function UiFpsGraph:add_point(n)
   self.points:push(n)
   local prev = self.smoothed:get(1)
   if prev then
      local smoothed = self.smoothing_factor * n + (1 - self.smoothing_factor) * prev
      self.smoothed:push(smoothed)
   else
      self.smoothed:push(n)
   end

   -- self.max = math.max(self.max, n)
   -- self.min = math.min(self.min, n)

   if self.base_max then
      self.max = self.base_max
   else
      self.max = self.smoothed:get(1)
   end
   if self.base_min then
      self.min = self.base_min
   else
      self.min = self.smoothed:get(1)
   end
   for _, point in self.smoothed:iter() do
      self.max = math.max(self.max, point)
      self.min = math.min(self.min, point)
   end
end

function UiFpsGraph:draw()
   Draw.set_color(255, 255, 255)
   Draw.line_rect(self.x, self.y, self.width, self.height)

   Draw.set_color(self.color)
   for i, point in self.smoothed:iter_reverse() do
      local x = self.x + self.width - (i * self.step) + 1
      local ratio
      if self.use_min then
         ratio = 1 - ((point - self.min) / (self.max - self.min))
      else
         ratio = 1 - (point / self.max)
      end
      ratio = math.clamp(ratio, 0.0, 1.0)
      Draw.line(x,
                self.y + self.height - 2,
                x,
                self.y + self.height * ratio)
   end
end

return UiFpsGraph
