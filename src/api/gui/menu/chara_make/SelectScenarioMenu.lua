local Draw = require("api.Draw")
local Map = require("api.Map")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local I18N = require("api.I18N")
local UiList = require("api.gui.UiList")
local UiTextGroup = require("api.gui.UiTextGroup")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")

local data = require("internal.data")
local save = require("internal.global.save")

local SelectScenarioMenu = class.class("SelectScenarioMenu", ICharaMakeSection)

SelectScenarioMenu:delegate("input", IInput)

local UiListExt = function()
   local E = {}

   function E:get_item_text(entry)
      return entry.name
   end

   return E
end

function SelectScenarioMenu:init(charamake_data)
   self.charamake_data = {}
   self.width = 680
   self.height = 500

   local scenarios = data["base.scenario"]:iter()
      :map(function(s) return {
         id = s,
         name = I18N.get("scenario._." .. s._id .. ".name"),
         description = I18N.get("scenario._." .. s._id .. ".description")
      }
      end)
      :to_list()
   table.sort(scenarios, function(a, b) return a.name < b.name end)

   self.scenario_id = nil

   self.list = UiList:new(scenarios)
   table.merge(self.list, UiListExt(self))

   self.text = UiTextGroup:new({}, 14, {0, 0, 0}, nil, nil, 15)

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("select_scenario.title", true, key_hints)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.select_scenario.caption"
   self.intro_sound = "base.ok1"
end

function SelectScenarioMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function SelectScenarioMenu:make_key_hints()
   return {
      {
         action = "ui.key_hint.action.back",
         keys = { "cancel", "escape" }
      }
   }
end

function SelectScenarioMenu:on_charamake_finish()
   save.base.scenario = self.scenario_id
end

function SelectScenarioMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20

   self.text:set_data({self.list:selected_item().description})

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
   self.text:relayout(self.x + 165, self.y + 66)
end

function SelectScenarioMenu:draw()
   self.win:draw()

   Ui.draw_topic("chara_make.select_scenario.name", self.x + 28, self.y + 30)
   Ui.draw_topic("chara_make.select_scenario.detail", self.x + 178, self.y + 30)

   self.text:draw()
   self.list:draw()
end

function SelectScenarioMenu:update()
   if self.list.chosen then
      self.scenario_id = self.list:selected_item().id
      return self.scenario_id
   elseif self.list.changed then
      self.text:set_data({self.list:selected_item().description})
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return SelectScenarioMenu
