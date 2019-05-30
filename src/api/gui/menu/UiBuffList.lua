local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")

local UiBuffList = class("UiBuffList", IUiList)

UiBuffList:delegate("inner", {
                       "x",
                       "y",
                       "items",
                       "changed",
                       "selected",
                       "selected_item",
                       "select",
                       "select_next",
                       "select_previous",
                       "can_select",
                       "update",
                       "relayout",
                       "focus",
                       "set_data"
})

function UiBuffList:init(x, y)
   self.inner = UiList:new(x, y, table.of("buff", 13))
   self.rows = 3
   self.columns = 3
   self.item_width = 32
   self.item_height = 32

   self.buff_icon = Draw.load_image("graphic/temp/buff_icon.png")
   self.quad = {}
   for i=1,19 do
      self.quad[i] = love.graphics.newQuad(i * 32, 0, 32, 32, self.buff_icon:getWidth(), self.buff_icon:getHeight())
   end
end

function UiBuffList:draw_item(i, item, x, y)
   local has_buff = false
   if has_buff then
      Draw.image_region(self.buff_icon, self.quad[3], x, y, {255, 255, 255})
      Draw.filled_rect(x, y, 32, 32, {200, 200, 225, 63})
   else
      Draw.image_region(self.buff_icon, self.quad[1], x, y, {255, 255, 255, 120})
   end
end

function UiBuffList:draw()
   for i=1,15 do
      local x = self.x + math.floor((i-1) / 3) * (self.item_width + 8)
      local y = self.y + (i-1) % 3 * self.item_height
      self:draw_item(i, self.items[i], x, y)
   end
end

function UiBuffList:get_hint()
   return "hint" .. ": " .. "hint"
end

return UiBuffList
