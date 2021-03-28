local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")

local UiGoldPlatinum = class.class("UiGoldPlatinum", IUiWidget)

function UiGoldPlatinum:init()
   self.gp_text = ""
   self.pp_text = ""
end

function UiGoldPlatinum:default_widget_position(x, y, width, height)
   return width - 240, height - (72 + 16) - 16
end

function UiGoldPlatinum:default_widget_z_order()
   return 75000
end

function UiGoldPlatinum:default_widget_refresh(player)
   self.gp_text = string.format("%d gp", player.gold)
   self.pp_text = string.format("%d gp", player.platinum)
end

function UiGoldPlatinum:relayout(x, y)
   self.x = x
   self.y = y
   self.t = UiTheme.load(self)
end

function UiGoldPlatinum:draw()
   Draw.set_font(12)

   Draw.set_color(255, 255, 255)
   self.t.base.gold_coin:draw(self.x, self.y)
   Draw.text_shadowed(self.gp_text,
                      self.x + 28,
                      self.y + 2,
                      self.t.base.text_color_light,
                      self.t.base.text_color_light_shadow)

   self.t.base.platinum_coin:draw(self.x + 120, self.y)
   Draw.text_shadowed(self.pp_text,
                      self.x + 120 + 28,
                      self.y + 2,
                      self.t.base.text_color_light,
                      self.t.base.text_color_light_shadow)
end

function UiGoldPlatinum:update()
end

return UiGoldPlatinum
