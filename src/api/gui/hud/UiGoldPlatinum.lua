local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")

local UiGoldPlatinum = class.class("UiGoldPlatinum", IUiWidget)

function UiGoldPlatinum:init()
end

function UiGoldPlatinum:default_widget_position(x, y, width, height)
   return width - 240, height - (72 + 16) - 16
end

function UiGoldPlatinum:default_widget_z_order()
   return 75000
end

function UiGoldPlatinum:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiGoldPlatinum:draw()
   local Chara = require("api.Chara")
   local chara = Chara.player()
   if not chara then
      return
   end
   local gold = chara.gold
   local plat = chara.platinum

   Draw.set_font(12)

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
