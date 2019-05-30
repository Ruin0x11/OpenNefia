local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local UiTextGroup = class("UiTextGroup", IUiElement)

function UiTextGroup:init(x, y, list, color, rows, columns, item_width, item_height)
   self.x = x
   self.y = y
   self.list = list
   self.color = color or {20, 10, 0}
   self.rows = rows or 1
   self.columns = columns or 1
   self.item_width = item_width or 190
   self.item_height = item_height or 15
end

function UiTextGroup:relayout()
end

function UiTextGroup:update()
end

function UiTextGroup:draw()
   if self.rows == 1 and self.columns == 1 then
      for i, t in ipairs(self.list) do
         Draw.text(t,
                   self.x,
                   self.y + (i - 1) * self.item_height,
                   self.text_color)
      end
   else
      for i, t in ipairs(self.list) do
         Draw.text(t,
                   self.x + (i - 1) / self.rows    * self.item_width,
                   self.y + (i - 1) % self.columns * self.item_height,
                   self.text_color)
      end
   end
end

return UiTextGroup
