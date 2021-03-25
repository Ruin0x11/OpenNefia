local Draw = require("api.Draw")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Chara = require("api.Chara")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local IconBar = require("api.gui.menu.IconBar")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local data = require("internal.data")
local WindowTitle = require("api.gui.menu.WindowTitle")
local SpellsMenu = require("api.gui.menu.SpellsMenu")
local SkillsMenu = require("api.gui.menu.SkillsMenu")

local SpellsWrapper = class.class("SpellsWrapper", IUiLayer)

SpellsWrapper:delegate("input", IInput)

function SpellsWrapper:init(index)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.submenu = nil
   self.icon_bar = IconBar:new("inventory_icons")

   self.icon_bar:set_data {
      { icon = 13, text = "ui.menu.spell.spell" },
      { icon = 14, text = "ui.menu.spell.skill" },
   }
   self.menus = {
      SpellsMenu,
      SkillsMenu
   }

   self.selected_index = math.clamp(index or 1, 1, #self.menus)
   self.sound = self.menus[self.selected_index].sound

   self:switch_context()
end

function SpellsWrapper:on_query()
   Gui.play_sound(self.sound)
end

function SpellsWrapper:make_keymap()
   return {
      previous_page = function() self:previous_menu() end,
      next_page = function() self:next_menu() end,
      raw_ctrl_tab = function() self:previous_menu() end,
      raw_tab = function() self:next_menu() end,
   }
end

function SpellsWrapper:next_menu()
   self.selected_index = self.selected_index + 1
   if self.selected_index > #self.menus then
      self.selected_index = 1
   end

   self:switch_context()

   Gui.play_sound(self.menus[self.selected_index].sound)
end

function SpellsWrapper:previous_menu()
   self.selected_index = self.selected_index - 1
   if self.selected_index < 1 then
      self.selected_index = #self.menus
   end

   Gui.play_sound("base.pop1")

   self:switch_context()
end

function SpellsWrapper:switch_context()
   self.submenu = self.menus[self.selected_index]:new(Chara.player())
   self.input:forward_to(self.submenu)

   self.icon_bar:select(self.selected_index)

   self.submenu:relayout(self.x, self.y + 25, self.width, self.height)
end

function SpellsWrapper:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.t = UiTheme.load(self)

   self.icon_bar:relayout(self.width - (44 * #self.menus + 60), 34, 44 * #self.menus + 40, 22)
   self.submenu:relayout(self.x, self.y + 25, self.width, self.height)
end

function SpellsWrapper:draw()
   Draw.set_color(255, 255, 255)
   self.icon_bar:draw()
   self.submenu:draw()
end

function SpellsWrapper:update()
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

function SpellsWrapper:release()
   self.icon_bar:release()
end

return SpellsWrapper
