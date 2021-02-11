local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")
local ConfigMenu = require("api.gui.menu.config.ConfigMenu")
local Gui = require("api.Gui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local config_store = require("internal.config_store")

local ConfigMenuWrapper = class.class("ConfigMenuWrapper", IUiLayer)

ConfigMenuWrapper:delegate("input", IInput)

function ConfigMenuWrapper:init(is_title_screen, menu_id)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.submenu_trail = {}
   self.is_title_screen = is_title_screen

   self.input = InputHandler:new()

   menu_id = menu_id or "base.default"
   self:push_menu(menu_id)
end

function ConfigMenuWrapper:make_keymap()
   return {}
end

function ConfigMenuWrapper:push_menu(config_menu_id)
   local submenu = ConfigMenu:new(config_menu_id)

   if self.submenu then
      table.insert(self.submenu_trail, self.submenu)
   end
   self.submenu = submenu

   self:relayout()

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function ConfigMenuWrapper:go_back()
   if #self.submenu_trail == 0 then return end

   self.submenu = table.remove(self.submenu_trail)
   self.submenu:on_query()

   self:relayout()

   self.input:forward_to(self.submenu)
   self.input:halt_input()
end

function ConfigMenuWrapper:relayout(x, y, width, height)
   self.x = x or 0
   self.y = y or 0
   self.width = width or Draw.get_width()
   self.height = height or Draw.get_height()
   self.t = UiTheme.load(self)

   if self.submenu then
      self.submenu:relayout(self.x, self.y, self.width, self.height)
   end
end

function ConfigMenuWrapper:draw()
   if self.is_title_screen then
      Draw.set_color(255, 255, 255)
      self.t.base.title:draw(0, 0, Draw.get_width(), Draw.get_height())
   end

   self.submenu:draw()
end

function ConfigMenuWrapper:update(dt)
   if not self.submenu then
      return nil, "canceled"
   end

   local result, canceled = self.submenu:update(dt)

   if canceled then
      if #self.submenu_trail == 0 then
         self.canceled = true
      else
         self:go_back()
      end
   elseif result then
      self:push_menu(result)
   end

   if self.canceled then
      config_store.save()
      return nil, "canceled"
   end
end

return ConfigMenuWrapper
