local IUiElement = require("api.gui.IUiElement")
local CompositeBBox = require("mod.plot.api.CompositeBBox")
local Figure = require("mod.plot.api.Figure")
local Love2DRenderer = require("mod.plot.api.Love2DRenderer")
local Draw = require("api.Draw")

local UiFigure = class.class("UiFigure", IUiElement)

function UiFigure:init(figure)
   assert(class.is_an(Figure, figure))
   self.figure = figure
   self.screen_space = {{0, 0}, {0, 0}}
   self.transform = CompositeBBox:new(figure.figure_space, self.screen_space)
   self.renderer = Love2DRenderer:new()
   self.ctx = {} -- dummy
end

function UiFigure:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.screen_space[1][1] = self.x
   self.screen_space[2][1] = self.y
   self.screen_space[1][2] = self.x + self.width
   self.screen_space[2][2] = self.y + self.height
   self.transform:invalidate()

   self.figure:refresh()
end

function UiFigure:draw()
   Draw.set_line_style("smooth")
   Draw.set_color(234, 226, 206)
   Draw.filled_rect(self.x, self.y, self.width, self.height)
   self.figure:draw_with_renderer(self.renderer, self.ctx, self.transform)
   Draw.set_line_style()
end

function UiFigure:update(dt)
end

return UiFigure
