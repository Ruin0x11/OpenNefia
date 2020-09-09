local IPlotRenderable = require("mod.plot.api.IPlotRenderable")
local Path = require("mod.plot.api.Path")
local IdentityBBox = require("mod.plot.api.IdentityBBox")
local Axes = require("mod.plot.api.Axes")
local CompositeBBox = require("mod.plot.api.CompositeBBox")

local Figure = class.class("Figure", IPlotRenderable)

function Figure:init(datasets)
   self.axes = Axes:new(datasets)

   self.figure_space = IdentityBBox:new {
      { 0.0, 1.0 },
      { 0.0, 1.0 }
   }
end

function Figure:refresh()
   self.axes:refresh()
end

function Figure:draw_with_renderer(renderer, ctx, transform)
   self.axes:draw_with_renderer(renderer, ctx, transform)
end

return Figure
