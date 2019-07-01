local Draw = require("api.Draw")
local Map = require("api.Map")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiTextGroup = require("api.gui.UiTextGroup")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")

local data = require("internal.data")

local SelectScenarioMenu = class.class("SelectScenarioMenu", ICharaMakeSection)

SelectScenarioMenu:delegate("input", IInput)

function SelectScenarioMenu:init()
   self.width = 680
   self.height = 500

   self.win = UiWindow:new("select_scenario.title")
   self.list = UiList:new({"Normal", "Test"})

   self.text = UiTextGroup:new({}, 14, {0, 0, 0}, nil, nil, 15)
   self.texts = {
      {"The original game scenario.", "Play the original game scenario of Elona."},
      {"A test scenario.", "Description for a test scenario."},
   }

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }

   self.caption = "Choose a scenario. It will change the start location and win conditions."
   self.intro_sound = "base.ok1"
end

function SelectScenarioMenu:on_make_chara()
   self.list:selected_item()
end

function SelectScenarioMenu:on_charamake_finish()
   local scenario = data["base.scenario"]:ensure("elona.elona")

   local map, err = Map.generate(scenario.starting_map.generator, scenario.starting_map.params)
   if err then
      error(err)
   end

   Map.set_map(map)
end

function SelectScenarioMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20

   self.text:set_data(self.texts[self.list.selected])

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
   self.text:relayout(self.x + 165, self.y + 66)
end

function SelectScenarioMenu:draw()
   self.win:draw()

   Ui.draw_topic("Mode", self.x + 28, self.y + 30)
   Ui.draw_topic("Detail", self.x + 178, self.y + 30)

   Draw.set_font(14)
   self.text:draw()

   self.list:draw()
end

function SelectScenarioMenu:update()
   if self.list.chosen then
      return true
   elseif self.list.changed then -- TODO remove
      self.text:set_data(self.texts[self.list.selected])
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return SelectScenarioMenu
