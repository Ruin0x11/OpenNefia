local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local UiGoldPlatinum = class("UiGoldPlatinum", IUiElement)

function UiGoldPlatinum:init()
   self.gold_coin = Draw.load_image("graphic/temp/gold_coin.bmp")
   self.platinum_coin = Draw.load_image("graphic/temp/platinum_coin.bmp")
end

function UiGoldPlatinum:relayout(x, y)
   self.x = x
   self.y = y
end

function UiGoldPlatinum:draw()
   local gold = 10000
   local plat = 10

   Draw.image(self.gold_coin, self.x, self.y, nil, nil, {255, 255, 255})
   Draw.text_shadowed(string.format("%d gp", gold), self.x + 28, self.y + 2)

   Draw.image(self.platinum_coin, self.x + 120, self.y, nil, nil, {255, 255, 255})
   Draw.text_shadowed(string.format("%d pp", plat), self.x + 120 + 28, self.y + 2)
end

function UiGoldPlatinum:update()
end

return UiGoldPlatinum
