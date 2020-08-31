local IPlotRenderable = require("mod.plot.api.IPlotRenderable")
local Path = require("mod.plot.api.Path")
local IdentityBBox = require("mod.plot.api.IdentityBBox")
local CompositeBBox = require("mod.plot.api.CompositeBBox")
local XAxis = require("mod.plot.api.XAxis")
local YAxis = require("mod.plot.api.YAxis")
local PlotLine = require("mod.plot.api.PlotLine")
local UiTheme = require("api.gui.UiTheme")

local Axes = class.class("Axes", IPlotRenderable)

local function get_bounds(dataset)
   if type(dataset) == "table" then
      return fun.iter(dataset):min(), fun.iter(dataset):max()
   elseif type(dataset) == "function" then
      return 0, 100
   end

   error("unknown dataset type")
end

function Axes:init(datasets)
   self.data_space = IdentityBBox:new{
      { 0, 0 },
      { 0, 0 }
   }

   self.axes_space = IdentityBBox:new {
      { 0.15, 0.85 },
      { 0.15, 0.85 }
   }

   self.box = Path.new_polygon(0.1, 0.1, 0.1, 0.9, 0.9, 0.9, 0.9, 0.1, 0.1, 0.1)
   self.lines = {}
   self.x_axis = XAxis:new(self.data_space.bbox[1], self.axes_space.bbox[1])
   self.y_axis = YAxis:new(self.data_space.bbox[2], self.axes_space.bbox[2])
   self.ctx = {} -- dummy

   self:set_datasets(datasets)
end

function Axes:set_datasets(datasets)
   self.datasets = datasets or {}

   local x_min, x_max
   local y_min, y_max
   for _, dataset in ipairs(self.datasets) do
      local x_min_, x_max_ = get_bounds(dataset.x)
      local y_min_, y_max_ = get_bounds(dataset.y)
      x_min = math.min(x_min or x_min_, x_min_)
      y_min = math.min(y_min or y_min_, y_min_)
      x_max = math.max(x_max or x_max_, x_max_)
      y_max = math.max(y_max or y_max_, y_max_)
   end

   self.data_space.bbox[1][1] = x_min or 0
   self.data_space.bbox[1][2] = x_max or 0
   self.data_space.bbox[2][1] = y_min or 0
   self.data_space.bbox[2][2] = y_max or 0

   self.x_axis:set_data_bounds(self.data_space.bbox[1])
   self.y_axis:set_data_bounds(self.data_space.bbox[2])

   local t = UiTheme.load()
   self.lines = {}
   for i, dataset in ipairs(self.datasets) do
      local color = t.plot["default_line_color_" .. ((i-1%10)+1)]
      local line = PlotLine:new(color)
      local data_to_axes = CompositeBBox:new(self.data_space, self.axes_space:get_bounds())
      for i, x, y in fun.zip(dataset.x, dataset.y) do
         local tx, ty = data_to_axes:transform(x, y)
         line:add_point(tx, 1 - ty)
      end
      self.lines[#self.lines+1] = line
   end
end

function Axes:refresh()
   self.x_axis:refresh()
   self.y_axis:refresh()
end

-- "transform" should translate from figure space to screen space.
function Axes:draw_with_renderer(renderer, ctx, transform)
   renderer:draw_path(ctx, self.box, transform)
   for _, line in ipairs(self.lines) do
      line:draw_with_renderer(renderer, ctx, transform)
   end
   self.x_axis:draw_with_renderer(renderer, ctx, transform)
   self.y_axis:draw_with_renderer(renderer, ctx, transform)
end

return Axes
