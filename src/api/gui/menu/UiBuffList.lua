local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local ListModel = require("api.gui.ListModel")

local UiBuffList = class("UiBuffList", IUiList)

UiBuffList:delegate("model", {
                       "items",
                       "changed",
                       "selected",
                       "selected_item",
                       "select",
                       "select_next",
                       "select_previous",
                       "choose",
                       "can_select",
                       "set_data",
                       "get_item_text",
                       "chosen",
                       "on_choose",
                       "can_choose",
                       "on_select"
})

UiBuffList:delegate("input", IInput)

function UiBuffList:init()
   self.model = ListModel:new(table.of("buff", 13))
   self.rows = 3
   self.columns = 3
   self.item_width = 32
   self.item_height = 32

   self.buff_icon = Draw.load_image("graphic/temp/buff_icon.png")
   self.buff_icon_none = Draw.load_image("graphic/temp/charasheet_buff.png")
   self.quad = {}
   for i=1,19 do
      self.quad[i] = love.graphics.newQuad((i-1) * 32, 0, 32, 32, self.buff_icon:getWidth(), self.buff_icon:getHeight())
   end

   self.input = InputHandler:new()
   self.input:bind_keys {
      up = function() self:select_previous() end,
      down = function() self:select_next() end,
   }
end

function UiBuffList:relayout(x, y)
   self.x = x
   self.y = y
end

function UiBuffList:draw_item(item, i, x, y)
   local has_buff = i % 2 == 0
   if has_buff then
      Draw.image_region(self.buff_icon, self.quad[3], x, y, nil, nil, {255, 255, 255, 255})
      if self.selected == i then
         Draw.filled_rect(x, y, 32, 32, {200, 200, 225, 63})
      end
   else
      Draw.image(self.buff_icon_none, x, y, nil, nil, {255, 255, 255, 120})
   end
end

function UiBuffList:draw()
   for i=1,15 do
      local x = self.x + math.floor((i-1) / 3) * (self.item_width + 8)
      local y = self.y + (i-1) % 3 * self.item_height
      self:draw_item(self.items[i], i, x, y)
   end
end

function UiBuffList:update()
end

function UiBuffList:get_hint()
   return "hint:"
end

return UiBuffList
