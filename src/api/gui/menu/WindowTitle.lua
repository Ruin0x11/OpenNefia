local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")
local I18N = require("api.I18N")
local ISettable = require("api.gui.ISettable")
local Gui = require("api.Gui")

local WindowTitle = class.class("WindowTitle", {IUiElement, ISettable})

function WindowTitle:init(title, text)
   self.title = title
   self.text = text or title
end

function WindowTitle:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
end

function WindowTitle:set_data(title, text)
   self.title = title
   self.text = text or title
end

function WindowTitle:draw()
   Draw.set_font(12) -- 12 + sizefix

   local count = math.ceil(self.width / 192)
   for i=0,count do
      self.t.message_window:draw_region("window_title", self.x + 8 + i * 192, self.y, nil, nil, {255, 255, 255})
   end

   local offset_y = 0
   if Gui.field_is_active() then
      offset_y = 1
   end
   self.t.tip_icons:draw_region(1, self.x, self.y + offset_y)

   offset_y = 0
   if I18N.is_fullwidth() then
      offset_y = 1
   end
   Draw.text_shadowed(self.text, self.x + 32, self.y + 1 + offset_y, {250, 250, 250})
end

function WindowTitle:update()
end

return WindowTitle
