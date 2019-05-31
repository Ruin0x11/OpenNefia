local Draw = require("api.Draw")
local I18N = require("api.I18N")
local Input = require("api.Input")
local IUiList = require("api.gui.IUiList")
local ListModel = require("api.gui.ListModel")
local KeyHandler = require("api.gui.KeyHandler")
local IList = require("api.gui.IList")
local IPaged = require("api.gui.IPaged")
local PagedListModel = require("api.gui.PagedListModel")

local UiList = class("UiList", IUiList)
UiList:delegate("model", {
                   "changed",
                   "selected",
                   "chosen",
                   "items",
                   "selected_item",
                   "select",
                   "select_next",
                   "select_previous",
                   "can_select",
                   "get_item_text",
                   "set_data",
                   "choose",

                   "select_page",
                   "next_page",
                   "previous_page",
                   "page",
                   "page_max",
                   "page_size",
})
UiList:delegate("keys", {"focus", "receive_key", "forward_to", "run_action"})

local keys = "abcdefghijklmnopqr"

function UiList:init(x, y, items, item_height, item_offset_x, item_offset_y)
   self.x = x
   self.y = y
   if is_an(IList, items) then
      self.model = items
   else
      self.model = ListModel:new(items)
   end
   self.item_height = item_height or 19
   self.item_offset_x = item_offset_x or 0
   self.item_offset_y = item_offset_y or -2
   self.select_key = { image = Draw.load_image("graphic/temp/select_key.bmp") }
   self.list_bullet = { image = Draw.load_image("graphic/temp/list_bullet.bmp") }

   self:set_data()

   local thing = {}
   for i=1,#keys do
      local key = keys:sub(i, i)
      thing[key] = function()
         print("Alright. " .. key)
         self:choose(i)
      end
   end
   thing.up = function() print("Prev."); self:select_previous() end
   thing.down = function() print("Next."); self:select_next() end
   thing["return"] = function() print("I'm choosing."); self:choose() end

   if is_an(IPaged, self.model) then
      thing.left = function() print("Page Prev."); self:next_page() end
      thing.right = function() print("Page Next."); self:previous_page() end
   end

   self.keys = KeyHandler:new()
   self.keys:bind_actions(thing)
end

function UiList:new_paged(x, y, items, page_max, item_height, item_offset_x, item_offset_y)
   return UiList:new(x, y, PagedListModel:new(items, page_max), item_height, item_offset_x, item_offset_y)
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
      Draw.filled_rect(x, y - 2, width, 19, {127, 191, 255, 63})
      Draw.image(self.list_bullet.image, x + width - 20, y + 2, nil, nil, {255, 255, 255})
   end
   Draw.text(text, x + 4 + x_offset, y + 1, {0, 0, 0})
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
   self.keys:run_actions()

   self.changed = false
end

return UiList
