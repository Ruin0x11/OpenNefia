local Gui = require("api.Gui")
local Ui = require("api.Ui")
local UiFigure = require("mod.plot.api.UiFigure")
local Figure = require("mod.plot.api.Figure")
local Plot = require("mod.plot.api.Plot")
local Draw = require("api.Draw")
local Env = require("api.Env")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")

local PlotViewer = class.class("PlotViewer", IUiLayer)

PlotViewer:delegate("input", IInput)

function PlotViewer:init(figure)
   self.figure = UiFigure:new(figure)

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function PlotViewer:default_z_order()
   return 100000000
end

function PlotViewer:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      enter = function() self.canceled = true end,
      repl_copy = function() self:copy_as_csv() end,
   }
end

function PlotViewer:on_query()
   Gui.play_sound("base.pop2")
end

function PlotViewer:relayout()
   self.width = 800
   self.height = 600
   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.y = self.y

   self.figure:relayout(0, 0, self.width, self.height)

   if self.canvas == nil then
      self.canvas = Draw.create_canvas(self.width, self.height)
      self.redraw = true
   end
end

function PlotViewer:copy_as_csv()
   local dataset = self.figure.figure.axes.datasets[1]
   if not dataset then
      return
   end

   local csv = Plot.dataset_to_csv(dataset)
   Env.set_clipboard_text(csv)
   Gui.play_sound("base.ok1")
   Gui.mes_c("Copied first plot to clipboard as CSV.", "Yellow")
end

function PlotViewer:draw()
   if self.redraw then
      Draw.with_canvas(self.canvas, function() self.figure:draw() end)
      self.redraw = false
   end
   Draw.image(self.canvas, self.x, self.y)
end

function PlotViewer:update(dt)
   self.figure:update(dt)

   if self.canceled then
      return nil, "canceled"
   end
end

function PlotViewer.plot(...)
   local datasets = Plot.make_datasets_dwim(...)
   local figure = Figure:new(datasets)
   PlotViewer:new(figure):query()
end

return PlotViewer
