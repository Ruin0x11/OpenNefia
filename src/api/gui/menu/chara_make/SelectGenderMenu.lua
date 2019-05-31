local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IKeyInput = require("api.gui.IKeyInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local KeyHandler = require("api.gui.KeyHandler")

local SelectGenderMenu = class("SelectGenderMenu", ICharaMakeSection)

SelectGenderMenu:delegate("keys", IKeyInput)
SelectGenderMenu:delegate("win", {"x", "y", "width", "height"})

local function load_cm_bg(id)
   return Draw.load_image(string.format("graphic/g%d.bmp", id))
end

SelectGenderMenu.query = require("api.Input").query

function SelectGenderMenu:get_result()
end

function SelectGenderMenu:init()
   self.x, self.y, self.width, self.height = Ui.params_centered(370, 168)
   self.y = self.y - 20

   self.win = UiWindow:new("chara_make.select_gender.title", self.x, self.y, self.width, self.height)
   self.list = UiList:new(self.x + 38, self.y + 66, {"ui.gender3.male", "ui.gender3.female"})

   self.bg = load_cm_bg(1)

   self.keys = KeyHandler:new()
   self.keys:forward_to(self.list)
   self.keys:bind_actions {
      shift = function() self.canceled = true end
   }

   self.caption = "There is no difference in the genders."
end

function SelectGenderMenu:relayout()
   self.win:relayout()
   self.list:relayout()
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
