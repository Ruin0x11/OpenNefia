local Ui = require("api.Ui")
local Gui = require("api.Gui")
local Draw = require("api.Draw")

local UiMouseMenu = require("mod.mouse_ui.api.gui.UiMouseMenu")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local InputHandler = require("api.gui.InputHandler")

local UiTestPrompt = class.class("UiTestPrompt", IUiLayer)

-- Thing to easily insert new UiElements for separate testing
UiTestPrompt:delegate("input", IInput)

function UiTestPrompt:init()
   self.autocenter = true

   self.mouse_menu = UiMouseMenu:new()
   self.menu_x = 0
   self.menu_y = 0
   self.menu_shown = false
   self:show_mouse_menu(false)

   self.toolbar = UiMouseMenu:new()

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:bind_mouse(self:make_mousemap())
   self.input:bind_mouse_elements(self:get_mouse_elements(true))
end

function UiTestPrompt:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function UiTestPrompt:show_mouse_menu(show)
   self.menu_shown = show
   for _, element in self.mouse_menu:iter_mouse_elements(true) do
      element:set_enabled(show)
      if not show then
         element:set_pressed(false)
      end
   end
end

function UiTestPrompt:unpress_mouse_elements()
   for _, other in self:iter_mouse_elements(true) do
      other:set_pressed(false)
   end
   self:show_mouse_menu(false)
end

function UiTestPrompt:unpress_unfocused_mouse_elements(element)
   local p = table.set {}
   while element do
      p[element] = true
      element = element:get_parent()
   end
   for _, other in self:iter_mouse_elements(true) do
      if not p[other] then
         other:set_pressed(false)
      end
   end
end

function UiTestPrompt:make_mousemap()
   return {
      element = function(element, pressed)
         if pressed then
            self:unpress_unfocused_mouse_elements(element)
         end
      end,
      button_2 = function(x, y, pressed)
         if pressed then
            if self.menu_shown then
               self:show_mouse_menu(false)
            else
               self.menu_x = x
               self.menu_y = y
               self.mouse_menu:relayout(x, y, 96, 48 * 4)
               self:show_mouse_menu(true)
            end
         end
      end
   }
end

function UiTestPrompt:get_mouse_elements(recursive)
   return table.append(self.mouse_menu:get_mouse_elements(true), self.toolbar:get_mouse_elements(true))
end

function UiTestPrompt:on_query()
   Gui.play_sound("base.pop2")
end

function UiTestPrompt:relayout(x, y, width, height)
   self.width = width
   self.height = height

   if self.autocenter then
      x, y = Ui.params_centered(self.width, self.height)
   end
   self.x = self.width / 2
   self.y = self.height / 2 - self.height / 4
   self.t = UiTheme.load(self)

   self.mouse_menu:relayout(self.menu_x, self.menu_y, 96, 48 * 4)
   self.toolbar:relayout(0, 0, Draw.get_width(), 48)
end

function UiTestPrompt:draw()
   if self.menu_shown then
      self.mouse_menu:draw()
   end
   self.toolbar:draw()
end

function UiTestPrompt:update(dt)
   local canceled = self.canceled

   self.canceled = false

   if canceled then
      return nil, "canceled"
   end

   if self.menu_shown then
      self.mouse_menu:update(dt)
   end
   self.toolbar:update(dt)
end

return UiTestPrompt
