local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")

local UiGoldPlatinum = class.class("UiGoldPlatinum", IUiElement)

function UiGoldPlatinum:init()
end

function UiGoldPlatinum:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiGoldPlatinum:draw()
   local gold = 10000
   local plat = 10

   self.t.gold_coin:draw(self.x, self.y, nil, nil, {255, 255, 255})
   Draw.text_shadowed(string.format("%d gp", gold),
                      self.x + 28,
                      self.y + 2,
                      self.t.text_color_light,
                      self.t.text_color_light_shadow)

   self.t.platinum_coin:draw(self.x + 120, self.y, nil, nil, {255, 255, 255})
   Draw.text_shadowed(string.format("%d pp", plat),
                      self.x + 120 + 28,
                      self.y + 2,
                      self.t.text_color_light,
                      self.t.text_color_light_shadow)
end

function UiGoldPlatinum:update()
end

return UiGoldPlatinum
