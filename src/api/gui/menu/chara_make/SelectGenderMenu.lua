local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")

local SelectGenderMenu = class.class("SelectGenderMenu", ICharaMakeSection)

SelectGenderMenu:delegate("input", IInput)

function SelectGenderMenu:init()
   self.width = 370
   self.height = 168

   self.win = UiWindow:new("chara_make.select_gender.title")
   self.list = UiList:new({"ui.gender3.male", "ui.gender3.female"})

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.caption = "There is no difference in the genders."
   self.intro_sound = "base.spell"
end

function SelectGenderMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end
   }
end

function SelectGenderMenu:on_make_chara(chara)
   chara.gender = self.list:selected_item()
end

function SelectGenderMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 20
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
end

function SelectGenderMenu:draw()
   self.win:draw()
   self.t.g1:draw(
              self.x + self.width / 2,
              self.y + self.height / 2,
              self.width / 2,
              self.height - 60,
              {255, 255, 255, 30},
              true)

   Ui.draw_topic("chara_make.select_gender.gender", self.x + 28, self.y + 30)

   self.list:draw()
end

function SelectGenderMenu:update()
   if self.list.chosen then
      return self.list:selected_item()
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return SelectGenderMenu
