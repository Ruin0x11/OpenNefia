local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local VisualAIPlanGrid = require("mod.visual_ai.api.gui.VisualAIPlanGrid")
local Ui = require("api.Ui")
local test = require("mod.visual_ai.internal.test")

local VisualAIPlanViewer = class.class("VisualAIPlanViewer", IUiLayer)

VisualAIPlanViewer:delegate("input", IInput)

function VisualAIPlanViewer:init(plan)
   self.plan = test.test_plan()

   self.win = UiWindow:new("Visual AI", true)
   self.grid = VisualAIPlanGrid:new(self.plan)

   self.input = InputHandler:new()
   self.input:forward_to(self.grid)
   self.input:bind_keys(self:make_keymap())
end

function VisualAIPlanViewer:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function VisualAIPlanViewer:on_query()
   self.canceled = false
end

function VisualAIPlanViewer:relayout(x, y, width, height)
   self.width = 700
   self.height = 458

   self.x, self.y = Ui.params_centered(self.width, self.height - 16)
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)

   local grid_w = self.width - 140
   local grid_h = self.height - 80
   local grid_x = self.x + 40
   local grid_y = self.y + 40
   self.grid:relayout(grid_x,
                      grid_y,
                      grid_w - (grid_w % self.grid.tile_size_px),
                      grid_h - (grid_h % self.grid.tile_size_px))
end

function VisualAIPlanViewer:draw()
   self.win:draw()
   self.grid:draw()
end

function VisualAIPlanViewer:update(dt)
   self.win:update(dt)
   local chosen = self.grid:update(dt)
   if chosen then
      return true, nil
   end

   if self.canceled then
      return nil, "canceled"
   end
end

return VisualAIPlanViewer
