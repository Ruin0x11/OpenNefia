local CharaMake = require("api.CharaMake")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Ui = require("api.Ui")
local config = require("internal.config")
local data = require("internal.data")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiRaceInfo = require("api.gui.menu.chara_make.UiRaceInfo")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")

local SelectClassMenu = class.class("SelectClassMenu", ICharaMakeSection)

SelectClassMenu:delegate("input", IInput)

local UiListExt = function()
   local E = {}

   function E:get_item_text(entry)
      return entry.name
   end

   return E
end

function SelectClassMenu:init()
   self.width = 680
   self.height = 500

   self.race = CharaMake.get_section_result("api.gui.menu.chara_make.SelectRaceMenu")
   self.race_name = I18N.get("race." .. self.race .. ".name")

   local classes = data["base.class"]:iter()
      :map(function(entry)
              return {
                 proto = data["base.class"]:ensure(entry._id),
                 name = I18N.get("class." .. entry._id .. ".name"),
                 desc = I18N.get_optional("class." .. entry._id .. ".description") or ""
              }
          end)

   if not config["base.show_charamake_extras"] then
      classes = classes:filter(function(entry)
            return not entry.proto.is_extra
      end)
   end

   classes = classes:to_list()

   self.win = UiWindow:new("chara_make.select_class.title")
   self.pages = UiList:new_paged(classes, 16)
   table.merge(self.pages, UiListExt())
   self.bg = Ui.random_cm_bg()

   self.chip_batch = nil
   local image = data["base.race"]:ensure(self.race).copy_to_chara.image
   self.chip_male = ""
   self.chip_female = ""
   if type(image) == "table" and image.male then
      self.chip_male = image.male
      self.chip_female = image.female
   elseif type(image) == "string" then
      self.chip_male = image
      self.chip_female = image
   end

   self.chip_male_height = 0
   self.chip_female_height = 0

   self.race_info = UiRaceInfo:new(classes[1])

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.select_class.caption"
   self.intro_sound = "base.ok1"
end

function SelectClassMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function SelectClassMenu:on_make_chara(chara)
   chara.class = self:charamake_result().proto._id
end

function SelectClassMenu:charamake_result()
   return self.pages:selected_item()
end

function SelectClassMenu:relayout()
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y + 20

   self.chip_batch = Draw.make_chip_batch("chip")

   self.chip_male_height = select(2, self.chip_batch:tile_size(self.chip_male))
   self.chip_female_height = select(2, self.chip_batch:tile_size(self.chip_female))

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.pages:relayout(self.x + 38, self.y + 66)
   self.race_info:relayout(self.x, self.y)
   self.win:set_pages(self.pages)
end

function SelectClassMenu:draw()
   self.win:draw()
   self.bg:draw(
      self.x + self.width / 4,
      self.y + self.height / 2,
      self.width / 5 * 2,
      self.height - 80,
      {255, 255, 255, 80},
      true)

   Draw.set_color(255, 255, 255)
   Ui.draw_topic("chara_make.select_class.title", self.x + 28, self.y + 30)
   Ui.draw_topic("chara_make.select_class.detail", self.x + 188, self.y + 30)

   self.pages:draw()

   self.chip_batch:clear()
   self.chip_batch:add(self.chip_male,
                       self.x + 380,
                       self.y - 48 + 60)
   self.chip_batch:add(self.chip_female,
                       self.x + 350,
                       self.y - 48 + 60)
   self.chip_batch:draw()
   -- Draw.image(self.chip_male, self.x + 380, self.y - self.chip_male:getHeight() + 60)
   -- Draw.image(self.chip_female, self.x + 350, self.y - self.chip_female:getHeight() + 60)

   Draw.set_color(0, 0, 0)
   Draw.text(I18N.get("chara_make.select_race.race_info.race") .. ": " .. self.race_name, self.x + 460, self.y + 38)

   self.race_info:draw()
end

function SelectClassMenu:update()
   if self.pages.chosen then
      return self.pages:selected_item()
   elseif self.pages.changed then -- TODO remove
      local class = self.pages:selected_item()
      self.race_info:set_data(class)

      self.win:set_pages(self.pages)
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.pages:update()
   self.race_info:update()
end

function SelectClassMenu:release()
   if self.chip_batch then
      self.chip_batch:release()
   end
end

return SelectClassMenu
