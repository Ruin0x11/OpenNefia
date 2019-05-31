local Draw = require("api.Draw")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")
local KeyHandler = require("api.gui.KeyHandler")

local UiBuffList = class("UiBuffList", IUiList)

UiBuffList:delegate("list", {
                       "x",
                       "y",
                       "items",
                       "changed",
                       "selected",
                       "selected_item",
                       "select",
                       "select_next",
                       "select_previous",
                       "choose",
                       "can_select",
                       "relayout",
                       "set_data",
                       "get_item_text",
                       "chosen"
})

UiBuffList:delegate("keys", {"focus", "receive_key", "run_action", "forward_to"})

function UiBuffList:init(x, y)
   self.list = UiList:new(x, y, table.of("buff", 13))
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

   self.keys = KeyHandler:new()
   self.keys:forward_to(self.list, {"up", "down"})
end

function UiBuffList:draw_item(i, item, x, y)
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
      self:draw_item(i, self.items[i], x, y)
   end
end

function UiBuffList:update()
   self.keys:run_actions()

   self.list:update()
end

function UiBuffList:get_hint()
   return "hint" .. ": " .. "hint"
end

return UiBuffList
