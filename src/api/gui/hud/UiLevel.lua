local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local UiTheme = require("api.gui.UiTheme")

local UiLevel = class("UiLevel", {IUiElement, ISettable})

function UiLevel:init()
   self.level = math.random(1, 20)
   self.exp = math.random(100000)
end

function UiLevel:set_data(level, exp)
   self.level = level
   self.exp = exp
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
