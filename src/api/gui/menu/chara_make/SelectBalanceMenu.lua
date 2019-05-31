local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IKeyInput = require("api.gui.IKeyInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiTextGroup = require("api.gui.UiTextGroup")
local UiWindow = require("api.gui.UiWindow")
local KeyHandler = require("api.gui.KeyHandler")

local SelectBalanceMenu = class("SelectBalanceMenu", ICharaMakeSection)

SelectBalanceMenu:delegate("keys", IKeyInput)
SelectBalanceMenu:delegate("win", {"x", "y", "width", "height"})

SelectBalanceMenu.query = require("api.Input").query

function SelectBalanceMenu:get_result()
end

function SelectBalanceMenu:init()
   self.x, self.y, self.width, self.height = Ui.params_centered(680, 500)
   self.y = self.y + 20

   self.win = UiWindow:new("select_balance.title", self.x, self.y, self.width, self.height)
   self.list = UiList:new(self.x + 38, self.y + 66, {"Normal", "Overdose"})

   self.text = UiTextGroup:new(self.x + 165, self.y + 66, {}, nil, nil, nil, 15)
   self.texts = {
      {"Normal mode is normal.", "It is a normal mode."},
      {"Overdose is another mode.", "Stats are gained by 3."},
   }

   self.keys = KeyHandler:new()
   self.keys:forward_to(self.list)
   self.keys:bind_actions {
      shift = function() self.canceled = true end
   }

   self.caption = "Choose a balance."
end

function SelectBalanceMenu:relayout()
   self.win:relayout()
   self.list:relayout()
   self.text:set_data(self.texts[self.list.selected])
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
      return self.list:selected_item()
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
