local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")

local NefiaCompletionDrawable = class.class("NefiaCompletionDrawable", IDrawable)

function NefiaCompletionDrawable:init()
   local coords = Draw.get_coords()
   local tw, th = coords:get_size()
   self.t = UiTheme.load(self)
   self.offset_x = math.floor(tw / 4)
   self.offset_y = math.floor(th / 4)
   self.region = 1
end

function NefiaCompletionDrawable:update(dt)
end

function NefiaCompletionDrawable:draw(x, y)
   Draw.set_color(255, 255, 255)
   self.t.base.nefia_mark:draw_region(self.region, x + self.offset_x, y + self.offset_y)
end

return NefiaCompletionDrawable
