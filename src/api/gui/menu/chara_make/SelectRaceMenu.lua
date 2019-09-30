local Draw = require("api.Draw")
local Ui = require("api.Ui")
local data = require("internal.data")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiRaceInfo = require("api.gui.menu.chara_make.UiRaceInfo")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")

local SelectRaceMenu = class.class("SelectRaceMenu", ICharaMakeSection)

SelectRaceMenu:delegate("input", IInput)

function SelectRaceMenu:init()
   self.width = 680
   self.height = 500

   local races = data["base.race"]:iter():extract("_id"):to_list()

   self.win = UiWindow:new("chara_make.select_race.title")
   self.pages = UiList:new_paged(races, 16)
   self.bg = Ui.random_cm_bg()

   -- self.chip_male = Draw.load_image("graphic/temp/chara_male.bmp")
   -- self.chip_female = Draw.load_image("graphic/temp/chara_female.bmp")

   self.race_info = UiRaceInfo:new(races[1])

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }

   self.caption = "Yaa. I've been waiting for you."
   self.intro_sound = "base.ok1"
end

function SelectRaceMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 38, self.y + 66)
   self.race_info:relayout(self.x, self.y)
   self.win:set_pages(self.pages)
end

function SelectRaceMenu:draw()
   self.win:draw()

   self.bg:draw(
              self.x + self.width / 4,
              self.y + self.height / 2,
              self.width / 5 * 2,
              self.height - 80,
              {255, 255, 255, 80},
              true)

   Draw.set_color(255, 255, 255)
   Ui.draw_topic("chara_make.select_race.race", self.x + 28, self.y + 30)
   Ui.draw_topic("chara_make.select_race.detail", self.x + 188, self.y + 30)

   self.pages:draw()

   -- Draw.image(self.chip_male, self.x + 480, self.y + 96, 96, 96, {255, 255, 255, 40})
   -- Draw.image(self.chip_female, self.x + 350, self.y + 96, 96, 96, {255, 255, 255, 40})

   self.race_info:draw()
end

function SelectRaceMenu:on_query()
end

function SelectRaceMenu:on_make_chara(chara)
   chara.race = self:charamake_result()
end

function SelectRaceMenu:charamake_result()
   return self.pages:selected_item()
end

function SelectRaceMenu:update()
   if self.pages.model.chosen then
      return self.pages:selected_item()
   elseif self.pages.changed then
      local race = self.pages:selected_item()
      self.race_info:set_data(race)

      self.win:set_pages(self.pages)
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.pages:update()
   self.win:update()
   self.race_info:update()
end

return SelectRaceMenu
