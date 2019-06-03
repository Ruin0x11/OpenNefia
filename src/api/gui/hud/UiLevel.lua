local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")

local UiLevel = class("UiLevel", {IUiElement, ISettable})

function UiLevel:init()
   self.character_level_icon = Draw.load_image("graphic/temp/character_level_icon.bmp")
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
end

function UiLevel:draw()
   Draw.image(self.character_level_icon, self.x + 4, self.y)
   Draw.text_shadowed(string.format("Lv%s/%d", self.level, self.exp), self.x + 32, self.y + 2)
end

function UiLevel:update()
end

return UiLevel
