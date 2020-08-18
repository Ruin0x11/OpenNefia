local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local data = require("internal.data")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiRaceInfo = require("api.gui.menu.chara_make.UiRaceInfo")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")

local config = require("internal.config")

local SelectRaceMenu = class.class("SelectRaceMenu", ICharaMakeSection)

SelectRaceMenu:delegate("input", IInput)

local UiListExt = function()
   local E = {}

   function E:get_item_text(entry)
      return entry.name
   end

   return E
end

function SelectRaceMenu:init(charamake_data)
   self.charamake_data = charamake_data
   self.width = 680
   self.height = 500

   local races = data["base.race"]:iter()
      :map(function(entry)
            local name = I18N.get("race." .. entry._id .. ".name")
            if entry.is_extra then
               name = name .. "(extra)"
            end
            return {
               proto = data["base.race"]:ensure(entry._id),
               name = name,
               desc = I18N.get_optional("race." .. entry._id .. ".description") or ""
            }
          end)

   if not config["base.show_charamake_extras"] then
      races = races:filter(function(entry)
            return not entry.proto.is_extra
      end)
   end

   races = races:to_list()

   table.sort(races, function(a, b) return a.proto.ordering < b.proto.ordering end)

   self.win = UiWindow:new("chara_make.select_race.title")
   self.pages = UiList:new_paged(races, 16)
   table.merge(self.pages, UiListExt())
   self.bg = Ui.random_cm_bg()

   self.race_info = UiRaceInfo:new(races[1])

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.select_race.caption"
   self.intro_sound = "base.ok1"
end

function SelectRaceMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
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

function SelectRaceMenu:get_charamake_result(charamake_data, retval)
   charamake_data.chara.race = retval
   return charamake_data
end

function SelectRaceMenu:update()
   if self.pages.model.chosen then
      return self.pages:selected_item().proto._id
   elseif self.pages.changed then
      local race_info = self.pages:selected_item()
      self.race_info:set_data(race_info)

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
