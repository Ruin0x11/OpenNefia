local IHud = require("api.gui.hud.IHud")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local WidgetContainer = require("api.gui.WidgetContainer")

local MainHud = class.class("MainHud", IHud)
MainHud:delegate("input", IInput)

function MainHud:init()
   self.input = InputHandler:new()

   self.widgets = WidgetContainer:new()
end

function MainHud:default_z_order()
   return 100000 -- Gui.LAYER_Z_ORDER_HUD
end

function MainHud:reset()
end

function MainHud:on_theme_switched()
end

function MainHud:relayout(x, y, width, height)
   self.width = width or self.width
   self.height = height or self.height
   self.x = x or self.x
   self.y = y or self.y

   self.widgets:relayout(self.x, self.y, self.width, self.height)
end

function MainHud:refresh(player)
   if player == nil then
      return
   end

   self.widgets:refresh(player)
end

function MainHud:draw(draw_x, draw_y)
   self.widgets:draw(draw_x, draw_y)
end

function MainHud:update(dt)
   self.widgets:update(dt)

   if self.widgets.updated and self.x then
      self.widgets:relayout(self.x, self.y, self.width, self.height)
      self.widgets.updated = false
   end
end

return MainHud
