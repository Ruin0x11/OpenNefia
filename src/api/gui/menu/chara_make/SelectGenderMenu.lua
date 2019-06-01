local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")

local SelectGenderMenu = class("SelectGenderMenu", ICharaMakeSection)

SelectGenderMenu:delegate("input", IInput)

local function load_cm_bg(id)
   return Draw.load_image(string.format("graphic/g%d.bmp", id))
end

function SelectGenderMenu:on_charamake_finish()
end

function SelectGenderMenu:init()
   self.width = 370
   self.height = 168

   self.win = UiWindow:new("chara_make.select_gender.title")
   self.list = UiList:new({"ui.gender3.male", "ui.gender3.female"})

   self.bg = load_cm_bg(1)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }

   self.caption = "There is no difference in the genders."
end

function SelectGenderMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 20

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
end

function SelectGenderMenu:draw()
   self.win:draw()
   Draw.image(self.bg,
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
