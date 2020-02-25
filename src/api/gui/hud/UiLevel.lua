local Draw = require("api.Draw")
local ISettable = require("api.gui.ISettable")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")

local UiLevel = class.class("UiLevel", {IUiWidget, ISettable})

function UiLevel:init()
   self.level = 1
   self.exp = 0
end

function UiLevel:set_data(level, exp)
   self.level = level or -1
   self.exp = exp or -1
end

function UiLevel:default_widget_position(x, y, width, height)
   return x + 4, height - (72 + 16) - 16
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
   self.t.character_level_icon:draw(self.x + 4, self.y)
   Draw.text_shadowed(string.format("Lv%s/%d", self.level, self.exp),
                      self.x + 32,
                      self.y + 2,
                      self.t.text_color_light,
                      self.t.text_color_light_shadow)
end

function UiLevel:update()
end

return UiLevel
