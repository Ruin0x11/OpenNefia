local Ui = require("api.Ui")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local VisualAIPlanTrail = require("mod.visual_ai.api.gui.VisualAIPlanTrail")
local VisualAIPlanGrid = require("mod.visual_ai.api.gui.VisualAIPlanGrid")
local test = require("mod.visual_ai.internal.test")

local VisualAIPlanViewer = class.class("VisualAIPlanViewer", IUiLayer)

VisualAIPlanViewer:delegate("input", IInput)

function VisualAIPlanViewer:init(plan)
   self.plan = test.test_plan()

   self.win = UiWindow:new("Visual AI", true)
   self.grid = VisualAIPlanGrid:new(self.plan)
   self.trail = VisualAIPlanTrail:new(self.plan)

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
   self.width = 800
   self.height = 480

   self.x, self.y = Ui.params_centered(self.width, self.height - 16)
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)

   local grid_w = self.width - 272
   local grid_h = self.height - 80
   local grid_x = self.x + 40
   local grid_y = self.y + 40
   self.grid:relayout(grid_x,
                      grid_y,
                      grid_w - (grid_w % self.grid.tile_size_px),
                      grid_h - (grid_h % self.grid.tile_size_px))

   self.trail:relayout(self.x + grid_w,
                       self.y + 20,
                       320,
                       self.height - 40)
end

function VisualAIPlanViewer:draw()
   self.win:draw()
   self.grid:draw()
   self.trail:draw()
end

function VisualAIPlanViewer:update(dt)
   if self.grid.changed then
      local trail, selected_idx = self.grid:get_trail_and_index()
      self.trail:set_trail(trail, selected_idx)
   end

   self.win:update(dt)
   local chosen = self.grid:update(dt)
   self.trail:update(dt)

   if chosen then
      return true, nil
   end

   if self.canceled then
      return nil, "canceled"
   end
end

return VisualAIPlanViewer
