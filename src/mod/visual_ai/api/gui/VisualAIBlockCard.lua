local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")
local VisualAIPlanGrid = require("mod.visual_ai.api.gui.VisualAIPlanGrid")
local Draw = require("api.Draw")
local Color = require("mod.extlibs.api.Color")
local UiShadowedText = require("api.gui.UiShadowedText")

local VisualAIBlockCard = class.class("VisualAIBlockCard", IUiElement)

function VisualAIBlockCard:init(text, color, icon, index)
   self.text = text
   self.color = color
   self.icon = icon
   self.index = index and tostring(index) or nil

   self.dark_color = {Color:new_rgb(color):lighten_by(0.5):to_rgb()}
   self.wrapped = {}
   self.window = TopicWindow:new(4, 1)
   self.selected = true
   self.tile_size_px = 48
end

function VisualAIBlockCard:set_selected(selected)
   self.selected = selected
end

function VisualAIBlockCard:_rewrap_text()
   local offset_x = 0
   if self.index then
      offset_x = 20
   end
   local _, wrapped = Draw.wrap_text(self.text, self.width - 40 - 100 - offset_x)
   self.wrapped = fun.iter(wrapped):map(function(i) return UiShadowedText:new(i, 14) end):to_list()
end

function VisualAIBlockCard:set_text(text)
   self.text = text
   self:_rewrap_text()
end

function VisualAIBlockCard:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.window:relayout(x + 5, y + 2.5, self.width - 10, self.height - 2.5)

   self:_rewrap_text()
end

function VisualAIBlockCard:draw()
   self.window:draw()

   local offset_x = 0
   if self.index then
      Draw.set_font(20)
      Draw.text_shadowed(self.index, self.x + 20, self.y + self.height / 2 - Draw.text_height() / 2)
      offset_x = 20
   end

   VisualAIPlanGrid.draw_tile(self.icon, self.selected and self.color or self.dark_color, self.selected,
                              self.x + 20 + offset_x, self.y + self.height / 2 - self.tile_size_px / 2, self.tile_size_px, 8)

   Draw.set_font(14)
   for i, text in ipairs(self.wrapped) do
      text:relayout(self.x + 24 + offset_x + self.tile_size_px + 5, self.y + 5 + i * Draw.text_height())
      text:draw()
   end

   if not self.selected then
      Draw.set_color(0, 0, 0, 64)
      Draw.filled_rect(self.window.x, self.window.y, self.window.width, self.window.height)
   end
end

function VisualAIBlockCard:update(dt)
end

return VisualAIBlockCard
