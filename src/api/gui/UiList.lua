local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Input = require("api.Input")
local IUiList = require("api.gui.IUiList")
local ListModel = require("api.gui.ListModel")

local UiList = class("UiList", IUiList)
UiList:delegate("model", {
                   "changed",
                   "selected",
                   "items",
                   "selected_item",
                   "select",
                   "select_next",
                   "select_previous",
                   "can_select",
                   "get_item_text",
                   "set_data",
                   "choose"
})

local keys = "abcdefghijklmnopqr"

function UiList:init(x, y, items, item_height, item_offset_x, item_offset_y)
   self.x = x
   self.y = y
   self.model = ListModel:new(items)
   self.item_height = item_height or 19
   self.item_offset_x = item_offset_x or 0
   self.item_offset_y = item_offset_y or -2
   self.select_key = { image = Draw.load_image("graphic/temp/select_key.bmp") }
   self.list_bullet = { image = Draw.load_image("graphic/temp/list_bullet.bmp") }

   self:set_data()

   self.keys = {}
end

function UiList:bind()
   self.keys = {}
   self.keys["return"] = function(p)
      if p then
         self:choose()
      end
   end
   self.keys.up = function(p)
      if p then
         self:select_previous()
      end
   end
   self.keys.down = function(p)
      if p then
         self:select_next()
      end
   end

   for i=1,#keys do
      local key = keys:sub(i, i)
      self.keys[key] = function(p)
         if p then
            self:choose(i)
         end
      end
   end
end

function UiList:focus()
   Input.set_key_handler(self.keys)
end

function UiList:relayout()
end

function UiList:draw_select_key(i, item, key_name, x, y)
   Draw.image(self.select_key.image, x, y, nil, nil, {255, 255, 255})
   Draw.set_font(13)
   Draw.text_shadowed(key_name,
                      x + (self.select_key.image:getWidth() - Draw.text_width(key_name)) / 2 - 2,
                      y + (self.select_key.image:getHeight() - Draw.text_height()) / 2,
                      {250, 240, 230},
                      {50, 60, 80})
end

function UiList:draw_item_text(text, i, item, x, y, x_offset)
   local selected = i == self.selected

   x_offset = x_offset or 0
   if selected then
      local width = math.clamp(Draw.text_width(text) + 32 + x_offset, 10, 400)
      love.graphics.setBlendMode("alpha")
      Draw.filled_rect(x, y, width, 19, {127, 191, 255, 63})
      Draw.image(self.list_bullet.image, x + width - 20, y + 4, nil, nil, {255, 255, 255})
   end
   Draw.text(text, x + 4 + x_offset, y + 3, {0, 0, 0})
end

function UiList:draw_item(i, item, x, y)
   local key_name = keys:sub(i, i)

   self:draw_select_key(i, item, key_name, x, y)

   Draw.set_font(14) -- 14 - en * 2

   local text = self:get_item_text(item)
   self:draw_item_text(text, i, item, x + 26, y + 1)
end

function UiList:draw()
   for i, item in ipairs(self.items) do
      local x = self.x + self.item_offset_x
      local y = (i - 1) * self.item_height + self.y + self.item_offset_y
      self:draw_item(i, item, x, y)
   end
end

function UiList:update()
   self.chosen = false
   self.changed = false
end

return UiList
