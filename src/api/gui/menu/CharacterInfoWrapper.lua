local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Chara = require("api.Chara")

local CharacterSheetMenu = require("api.gui.menu.CharacterSheetMenu")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local IconBar = require("api.gui.menu.IconBar")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local data = require("internal.data")
local WindowTitle = require("api.gui.menu.WindowTitle")

local CharacterInfoWrapper = class.class("CharacterInfoWrapper", IUiLayer)

CharacterInfoWrapper:delegate("input", IInput)

function CharacterInfoWrapper:init()
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.submenu = nil
   self.icon_bar = IconBar:new("inventory_icons")
   self.icon_bar:set_data {
      { icon = 1, text = "asd" },
      { icon = 1, text = "asd" },
      { icon = 1, text = "asd" },
   }
   self.menu_count = 3

   self.title = WindowTitle:new()

   self.selected_index = 1
   self:switch_context()
end

function CharacterInfoWrapper:make_keymap()
   return {
      previous_page = function() self:previous_menu() end,
      next_page = function() self:next_menu() end,
      raw_ctrl_tab = function() self:previous_menu() end,
      raw_tab = function() self:next_menu() end,
   }
end

function CharacterInfoWrapper:next_menu()
   self.selected_index = self.selected_index + 1
   if self.selected_index > self.menu_count then
      self.selected_index = 1
   end

   self:switch_context()
end

function CharacterInfoWrapper:previous_menu()
   self.selected_index = self.selected_index - 1
   if self.selected_index < 1 then
      self.selected_index = self.menu_count
   end

   self:switch_context()
end

function CharacterInfoWrapper:switch_context()
   Gui.play_sound("base.chara")
   self.submenu = CharacterSheetMenu:new(nil, Chara.player())
   self.input:forward_to(self.submenu)

   self.icon_bar:select(self.selected_index)

   local title_string = I18N.get("ui.chara_sheet.hint.reroll")
      .. I18N.get("ui.hint.portrait")
      .. I18N.get("ui.chara_sheet.hint.confirm")

   self.title:set_data(title_string)

   self.submenu:relayout(self.x, self.y + 25, self.width, self.height)

   collectgarbage()
end

function CharacterInfoWrapper:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.t = UiTheme.load(self)

   self.icon_bar:relayout(self.width - (44 * self.menu_count + 60), 34, 44 * self.menu_count + 40, 22)
   self.submenu:relayout(self.x, self.y + 25, self.width, self.height)
   self.title:relayout(236 - 10, 0, Draw.get_width() - 236 - 10, 16)
end

function CharacterInfoWrapper:draw()
   Draw.set_color(255, 255, 255)
   self.icon_bar:draw()
   self.submenu:draw()
   self.title:draw()
end

function CharacterInfoWrapper:update()
   local result, canceled = self.submenu:update()
   if canceled then
      return nil, "canceled"
   elseif result then
      return result
   end

   if self.canceled then
      return nil, "canceled"
   end
end

function CharacterInfoWrapper:release()
   self.icon_bar:release()
end

return CharacterInfoWrapper
