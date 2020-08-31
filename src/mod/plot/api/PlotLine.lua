local IPlotRenderable = require("mod.plot.api.IPlotRenderable")
local Path = require("mod.plot.api.Path")

local PlotLine = class.class("PlotLine", IPlotRenderable)

function PlotLine:init(color)
   self.path = Path:new()
   self.color = color or { 0, 0, 0 }
end

function PlotLine:add_point(x, y)
   table.insert(self.path.vertices, { x, y })
   table.insert(self.path.commands, "line_to")
end

function PlotLine:refresh()
end

function PlotLine:draw_with_renderer(renderer, ctx, transform)
   renderer:draw_path(ctx, self.path, transform, self.color)
end

return PlotLine
