local TopicWindow = require("api.gui.TopicWindow")
local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local UiTheme = require("api.gui.UiTheme")

local IconBar = class("IconBar", {IUiElement, ISettable})

function IconBar:init()
   self.icon_set = nil
   self.index = 1
   self.bar = TopicWindow:new(5, 5)
end

function IconBar:set_data(icon_set)
   self.icon_set = icon_set
end

function IconBar:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   self.bar:relayout(x, y, width, height)
end

function IconBar:draw()
   self.bar:draw()
   self.t.radar_deco:draw(self.x - 28, self.y - 8, nil, nil, {255, 255, 255})

   if not self.icon_set then return end

   Draw.set_font(12) -- 12 + sizefix - en * 2

   for i=1,12 do
      local x = self.x + (i-1) * 44
      self.icon_set:draw_region(i, x + 20, self.y - 24)

      local color = {165, 165, 165}
      if self.index == i then
         color = {255, 255, 255}

         love.graphics.setBlendMode("add")
         self.icon_set:draw_region(i, x + 20, self.y - 24, nil, nil, {255, 255, 255, 70})
         love.graphics.setBlendMode("alpha")
      end


      local text = "cmd" .. tostring(i)
      Draw.text_shadowed(text, x + 46 - math.floor(Draw.text_width(text) / 2), self.y + 7, color)

      local invkey = "(" .. tostring(i) .. ")"
      if invkey then
         Draw.text_shadowed(invkey, x + 46, self.y + 18, {235, 235, 235})
      end
   end

   local key_help = "Tab,Ctrl+Tab [Window]"
   Draw.text_shadowed(key_help, self.x + self.width - Draw.text_width(key_help) - 6, self.y + 32)
end

function IconBar:update()
end

return IconBar
