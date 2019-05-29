local Draw = require("api.Draw")
local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local UiPages = require("api.gui.UiPages")
local UiRaceInfo = require("api.gui.menu.chara_make.UiRaceInfo")
local UiWindow = require("api.gui.UiWindow")

local SelectRaceMenu = class("SelectRaceMenu", IUiLayer)

SelectRaceMenu:delegate("pages", "focus")
SelectRaceMenu:delegate("win", {"x", "y", "width", "height", "relayout"})

local function random_cm_bg()
   return Draw.load_image(string.format("graphic/g%d.bmp", math.random(4) - 1))
end

function SelectRaceMenu:init()
   local races = table.of(function(i) return "race" .. i end, 100)

   self.x, self.y, self.width, self.height = Ui.params_centered(680, 500)
   self.y = self.y + 20

   self.win = UiWindow:new("chara_make.select_race.title", self.x, self.y, self.width, self.height)
   self.pages = UiPages:new(self.x + 38, self.y + 66, races, 16)
   self.bg = random_cm_bg()

   self.chip_male = Draw.load_image("graphic/temp/chara_male.bmp")
   self.chip_female = Draw.load_image("graphic/temp/chara_female.bmp")

   self.race_info = UiRaceInfo:new(self.x, self.y, races[1])
end

function SelectRaceMenu:draw()
   self.win:draw()
   Draw.image(self.bg,
              self.x + self.width / 4,
              self.y + self.height / 2,
              self.width / 5 * 2,
              self.height - 80,
              {255, 255, 255, 80},
              true)
   Draw.set_color()
   Ui.draw_topic("chara_make.select_race.race", self.x + 28, self.y + 30)
   Ui.draw_topic("chara_make.select_race.detail", self.x + 188, self.y + 30)

   self.pages:draw()

   Draw.image(self.chip_male, self.x + 480, self.y + 96, 96, 96, {255, 255, 255, 40})
   Draw.image(self.chip_female, self.x + 350, self.y + 96, 96, 96, {255, 255, 255, 40})

   self.race_info:draw()
end

function SelectRaceMenu:update()
   if self.pages.chosen then
      return self.pages:selected_item()
   elseif self.pages.changed then
      local race = self.pages:selected_item()
      self.race_info:set_data(race)

      self.win:set_pages(self.pages)
   end

   self.pages:update()
end

return SelectRaceMenu
