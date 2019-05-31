local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")

local UiTextGroup = class("UiTextGroup", {IUiElement, ISettable})

function UiTextGroup:init(x, y, texts, color, rows, columns, item_width, item_height)
   self.x = x
   self.y = y
   self.texts = texts
   self.color = color or {20, 10, 0}
   self.rows = rows or 1
   self.columns = columns
   self.item_width = item_width or 190
   self.item_height = item_height or 15

   self:set_data()
end

function UiTextGroup:relayout()
end

function UiTextGroup:update()
end

function UiTextGroup:set_data(texts)
   self.texts = texts or self.texts
end

function UiTextGroup:draw()
   if self.rows == 1 and (self.columns or #self.texts) == #self.texts then
      for i, t in ipairs(self.texts) do
         Draw.text(t,
                   self.x,
                   self.y + (i - 1) * self.item_height,
                   self.color)
      end
   else
      for i, t in ipairs(self.texts) do
         Draw.text(t,
                   self.x + math.floor((i - 1) / self.rows)    * self.item_width,
                   self.y + (i - 1) % self.columns * self.item_height,
                   self.color)
      end
   end
end

return UiTextGroup
