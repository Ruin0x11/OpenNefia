local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")

local UiMinimap = class.class("UiMinimap", IUiWidget)

function UiMinimap:init()
end

function UiMinimap:default_widget_position(x, y, width, height)
   return x, height - (16 + 72), 136, 16 + 72
end

function UiMinimap:default_widget_z_order()
   return 70000
end

function UiMinimap:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
end

function UiMinimap:draw()
   self.t.base.hud_minimap:draw(self.x, self.y, nil, nil, {255, 255, 255})
end

function UiMinimap:update(dt)
end

return UiMinimap
