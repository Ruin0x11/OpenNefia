local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")

local WatcherWidget = class.class("WatcherWidget", IUiWidget)

function WatcherWidget:init()
end

function WatcherWidget:default_widget_position(x, y, width, height)
   return x, y
end

function WatcherWidget:on_top_of_frame()
end

function WatcherWidget:update_variable(name, value)
end

function WatcherWidget:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
end

function WatcherWidget:draw()
end

function WatcherWidget:update(dt)
end

return WatcherWidget
