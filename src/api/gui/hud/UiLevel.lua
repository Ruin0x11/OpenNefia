local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")

local UiLevel = class.class("UiLevel", {IUiWidget, ISettable})

function UiLevel:init()
   self.text = ""
end

function UiLevel:set_data(level, exp)
   self.text = string.format("Lv%s/%d", level or -1, exp or -1)
end

function UiLevel:default_widget_position(x, y, width, height)
   return x + 4, height - (72 + 16) - 16
end

function UiLevel:default_widget_refresh(player)
   self:set_data(player:calc("level"), player.experience)
end

function UiLevel:default_widget_z_order()
   return 75000
end

function UiLevel:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiLevel:draw()
   Draw.set_font(13) -- 13 - en * 2
   Draw.set_color(255, 255, 255)
   self.t.base.character_level_icon:draw(self.x + 4, self.y)
   Draw.text_shadowed(self.text,
                      self.x + 32,
                      self.y + 2,
                      self.t.base.text_color_light,
                      self.t.base.text_color_light_shadow)
end

function UiLevel:update()
end

return UiLevel
