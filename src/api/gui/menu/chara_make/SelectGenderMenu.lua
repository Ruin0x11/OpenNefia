local I18N = require("api.I18N")
local Ui = require("api.Ui")
local Log = require("api.Log")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")

local SelectGenderMenu = class.class("SelectGenderMenu", ICharaMakeSection)

SelectGenderMenu:delegate("input", IInput)

local UiListExt = function()
   local E = {}

   function E:get_item_text(entry)
      return entry.name
   end

   return E
end

function SelectGenderMenu:init(charamake_data)
   self.charamake_data = charamake_data
   self.width = 370
   self.height = 168

   local genders = {
      "male",
      "female"
   }

   self.genders = fun.iter(genders)
      :map(function(g)
            return { name = I18N.capitalize(I18N.get("ui.sex3." .. g)), gender = g }
          end)
      :to_list()

   self.list = UiList:new(self.genders)
   table.merge(self.list, UiListExt())

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("chara_make.select_gender.title", true, key_hints)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.select_gender.caption"
   self.intro_sound = "base.spell"
end

function SelectGenderMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function SelectGenderMenu:make_key_hints()
   return {
      {
         action = "ui.key_hint.action.back",
         keys = { "cancel", "escape" }
      },
   }
end

function SelectGenderMenu:on_charamake_finish(chara)
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
   self.t.base.g1:draw(
              self.x + self.width / 2,
              self.y + self.height / 2,
              self.width / 2,
              self.height - 60,
              {255, 255, 255, 30},
              true)

   Ui.draw_topic("chara_make.select_gender.gender", self.x + 28, self.y + 30)

   self.list:draw()
end

function SelectGenderMenu:get_charamake_result(charamake_data, retval)
   local chara = charamake_data.chara
   chara.gender = retval

   if chara.image == nil or chara.image == "base.default" then
      local ElonaChara = require("mod.elona.api.ElonaChara")
      local image = ElonaChara.default_chara_image(chara)
      if image then
         chara.image = image
      else
         Log.error("No chara image for %s", chara)
      end
   end

   return charamake_data
end

function SelectGenderMenu:update()
   if self.list.chosen then
      return self.list:selected_item().gender
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return SelectGenderMenu
