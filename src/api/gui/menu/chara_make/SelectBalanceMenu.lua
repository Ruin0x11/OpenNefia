local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiTextGroup = require("api.gui.UiTextGroup")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")

local SelectBalanceMenu = class.class("SelectBalanceMenu", ICharaMakeSection)

SelectBalanceMenu:delegate("input", IInput)

function SelectBalanceMenu:init(charamake_data)
   self.charamake_data = charamake_data
   self.width = 680
   self.height = 500

   self.win = UiWindow:new("select_balance.title")
   self.list = UiList:new({"Normal", "Overdose"})

   self.text = UiTextGroup:new({}, nil, nil, nil, 15)
   self.texts = {
      {"Normal mode is normal.", "It is a normal mode."},
      {"Overdose is another mode.", "Stats are gained by 3."},
   }

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.caption = "Choose a balance."
end

function SelectBalanceMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function SelectBalanceMenu:on_charamake_finish()
   return self.list:selected_item()
end

function SelectBalanceMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20

   self.text:set_data(self.texts[self.list.selected])

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
   self.text:relayout(self.x + 165, self.y + 66)
end

function SelectBalanceMenu:draw()
   self.win:draw()

   Ui.draw_topic("Mode", self.x + 28, self.y + 30)
   Ui.draw_topic("Detail", self.x + 178, self.y + 30)

   Draw.set_font(14)
   self.text:draw()

   self.list:draw()
end

function SelectBalanceMenu:update()
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

return SelectBalanceMenu
