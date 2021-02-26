local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local Gui = require("api.Gui")

local UiStaminaWidget = class.class("UiStaminaWidget", {IUiWidget, ISettable})

function UiStaminaWidget:init()
   self.min = 0
   self.max = 0
end

function UiStaminaWidget:default_widget_position(x, y, width, height)
   return 10, Gui.message_window_y() - 30 - 16
end

function UiStaminaWidget:default_widget_refresh(player)
   self:set_data(player)
end

function UiStaminaWidget:set_data(player)
   self.min = player.stamina
   self.max = player.max_stamina
   self.str = ("ST:%d/%d"):format(self.min, self.max)
end

function UiStaminaWidget:relayout(x, y)
   self.x = x
   self.y = y
end

function UiStaminaWidget:draw()
   Draw.set_font(13)
   Draw.text_shadowed(self.str, self.x, self.y)
end

function UiStaminaWidget:update()
end

return UiStaminaWidget
