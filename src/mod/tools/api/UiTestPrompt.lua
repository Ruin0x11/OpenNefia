local Ui = require("api.Ui")
local Gui = require("api.Gui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local InputHandler = require("api.gui.InputHandler")

local UiTestPrompt = class.class("UiTestPrompt", IUiLayer)

-- Thing to easily insert new UiElements for separate testing
UiTestPrompt:delegate("input", IInput)

function UiTestPrompt:init()
   self.autocenter = true

   local InventoryWeightGraph = require("mod.weight_graph.api.gui.InventoryWeightGraph")
   self.weight_graph = InventoryWeightGraph:new()

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function UiTestPrompt:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function UiTestPrompt:on_query()
   Gui.play_sound("base.pop2")
end

function UiTestPrompt:relayout(x, y, width, height)
   self.width = width
   self.height = height

   if self.autocenter then
      x, y = Ui.params_centered(self.width, self.height)
   end
   self.x = self.width / 2
   self.y = self.height / 2 - self.height / 4
   self.t = UiTheme.load(self)

   self.weight_graph:relayout(self.x, self.y, 24, 408)
end

function UiTestPrompt:draw()
   self.weight_graph:draw()
end

function UiTestPrompt:update(dt)
   local canceled = self.canceled

   self.canceled = false

   if canceled then
      return nil, "canceled"
   end

   self.weight_graph:update(dt)
end

return UiTestPrompt
