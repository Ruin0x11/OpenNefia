local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local EquipmentMenu = require("api.gui.menu.EquipmentMenu")
local FeatsMenu = require("api.gui.menu.FeatsMenu")
local MaterialsMenu = require("api.gui.menu.MaterialsMenu")

local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")
local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local IconBar = require("api.gui.menu.IconBar")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")

local CharacterInfoWrapper = class.class("CharacterInfoWrapper", IUiLayer)

CharacterInfoWrapper:delegate("input", IInput)

function CharacterInfoWrapper:init(player, starting_menu)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.player = player

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.submenu = nil
   self.icon_bar = IconBar:new("inventory_icons", self:make_key_hints())
   self.icon_bar:set_data {
      { icon = 9,  text = "ui.menu.chara.chara" },
      { icon = 10, text = "ui.menu.chara.wear"  },
      { icon = 11, text = "ui.menu.chara.feat" },
      { icon = 12, text = "ui.menu.chara.material" },
   }
   self.menus = {
      CharacterInfoMenu,
      EquipmentMenu,
      FeatsMenu,
      MaterialsMenu
   }

   if starting_menu then
      self.selected_index = table.index_of(self.menus, starting_menu)
      if self.selected_index == nil then
         error(("Unknown chara info menu %s"):format(starting_menu))
      end
   else
      self.selected_index = 1
   end

   self.menus = fun.iter(self.menus)
      :map(function(klass) return klass:new(self.player) end)
      :to_list()

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

function CharacterInfoWrapper:make_key_hints()
   return {
      {
         action = "ui.key_hint.action.change",
         keys = { "previous_page", "next_page", "raw_tab", "raw_ctrl_tab" }
      }
   }
end

function CharacterInfoWrapper:next_menu()
   self.selected_index = self.selected_index + 1
   if self.selected_index > #self.menus then
      self.selected_index = 1
   end

   self:switch_context()
end

function CharacterInfoWrapper:previous_menu()
   self.selected_index = self.selected_index - 1
   if self.selected_index < 1 then
      self.selected_index = #self.menus
   end

   self:switch_context()
end

function CharacterInfoWrapper:switch_context()
   self.submenu = self.menus[self.selected_index]
   self.input:forward_to(self.submenu)
   self.submenu:on_query()

   self.icon_bar:select(self.selected_index)

   self.submenu:relayout(self.x, self.y + 25, self.width, self.height)
end

function CharacterInfoWrapper:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.t = UiTheme.load(self)

   self.icon_bar:relayout(self.width - (44 * #self.menus + 60), 34, 44 * #self.menus + 40, 22)
   self.submenu:relayout(self.x, self.y + 25, self.width, self.height)
end

function CharacterInfoWrapper:draw()
   Draw.set_color(255, 255, 255)
   self.icon_bar:draw()
   self.submenu:draw()
end

function CharacterInfoWrapper:update()
   local self_canceled = self.canceled
   local result, canceled = self.submenu:update()

   self.canceled = false

   if self_canceled or canceled or result then
      -- We have to check if the player changed equipment in the equipment menu
      -- at some point, to ensure their turn gets ended.
      for _, menu in ipairs(self.menus) do
         if menu.on_exit_result then
            local result, canceled = menu:on_exit_result()
            if result or canceled then
               return result, canceled
            end
         end
      end

      if canceled or self_canceled then
         return nil, "canceled"
      elseif result then
         return result
      end
   end
end

function CharacterInfoWrapper:release()
   self.icon_bar:release()
end

return CharacterInfoWrapper
