local IPlotRenderable = require("mod.plot.api.IPlotRenderable")
local Path = require("mod.plot.api.Path")
local CompositeBBox = require("mod.plot.api.CompositeBBox")
local IdentityBBox = require("mod.plot.api.IdentityBBox")

local YAxis = class.class("YAxis", IPlotRenderable)

function YAxis:init(data_bounds, view_bounds)
   self.data_bounds = data_bounds
   self.view_bounds = view_bounds

   self.label_format = "%2.02f"
   self.x_pos = 0.0
   self.length = 0.025
   self.tick_count = 10

   self.ticks = Path:new()
   self.labels = {}

   self.transform = CompositeBBox:new(IdentityBBox:new_unit(), {{0.1, 0.9}, self.view_bounds})
end

function YAxis:set_data_bounds(data_bounds)
   self.data_bounds = data_bounds
end

function YAxis:refresh()
   self.ticks:clear()
   self.labels = {}
   for i = 0, self.tick_count-1 do
      local n = 1 - (i / (self.tick_count - 1))
      local tx, ty = self.transform:transform(self.x_pos - self.length, n)
      self.ticks:move_to(tx, ty)
      tx, ty = self.transform:transform(self.x_pos + self.length, n)
      self.ticks:line_to(tx, ty)

      local value = math.map(n, 1.0, 0.0, self.data_bounds[1], self.data_bounds[2])
      self.labels[#self.labels+1] = { n, string.format(self.label_format, value) }
   end
end

function YAxis:draw_with_renderer(renderer, ctx, transform)
   renderer:draw_path(ctx, self.ticks, transform)

   for _, label in ipairs(self.labels) do
      local width, height = renderer:get_text_width_height_descent(ctx, label[2], 12)
      local tx, ty = self.transform:transform(self.x_pos - 0.04, label[1])
      tx, ty = transform:transform(tx, ty)
      renderer:draw_text(ctx, label[2], tx - width, ty - height / 2, 12)
   end
end

return YAxis
