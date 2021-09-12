local IInput = require("api.gui.IInput")
local IConfigMenu = require("api.gui.menu.config.IConfigMenu")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local Ui = require("api.Ui")
local Draw = require("api.Draw")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local data = require("internal.data")

local ConfigThemeMenu = class.class("ConfigThemeMenu", IConfigMenu)

ConfigThemeMenu:delegate("input", IInput)

function ConfigThemeMenu:init(config_menu_id)
   self.list = UiList:new_paged({"a", "b", "c"}, 16)

   local key_hints = self:make_key_hints()
   self.win = UiWindow:new("config.menu.base.theme.name", true, key_hints)

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys(self:make_keymap())
end

function ConfigThemeMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function ConfigThemeMenu:make_key_hints()
   local hints = self.list:make_key_hints()

   hints[#hints+1] = {
      action = "ui.key_hint.action.close",
      keys = { "cancel", "escape" }
   }

   return hints
end

function ConfigThemeMenu:on_query()
   self.canceled = false
end

function ConfigThemeMenu:relayout()
   self.width = 650
   self.height = 500

   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 12

   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)
   if self.list.page_max > 1 then
      self.win:set_pages(self.list.model)
   end
   self.list:relayout(self.x + 56, self.y + 66)
end

function ConfigThemeMenu:draw()
   self.win:draw()

   Ui.draw_topic("config.common.menu", self.x + 34, self.y + 36)
   self.list:draw()
end

function ConfigThemeMenu:update(dt)
   local canceled = self.canceled

   self.canceled = false

   self.win:update(dt)
   self.list:update(dt)

   if canceled then
      return nil, "canceled"
   end
end

return ConfigThemeMenu
