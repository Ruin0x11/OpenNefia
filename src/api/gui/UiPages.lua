local Draw = require("api.Draw")
local Input = require("api.Input")
local UiList = require("api.gui.UiList")
local IUiPages = require("api.gui.IUiPages")

local UiPages = class("UiPages", IUiPages)

UiPages:delegate("list", {"draw",
                          "x",
                          "y",
                          "relayout",
                          "update",
                          "changed",
                          "selected_item"})

function UiPages:init(x, y, items, page_size, item_height, item_offset_x, item_offset_y)
      self.items = items
      self.selected = 0
      self.page = 0
      self.page_size = page_size
      self.page_max = math.floor(#items / page_size)

      self.keys = {}

      self.list = UiList:new(x, y, {}, item_height, item_offset_x, item_offset_y)

      -- self.keys.redirect(self.list, {"up", "down", "return"})

      self:set_data()
end

function UiPages:focus()
   Input.set_key_handler(self.keys)
end

function UiPages:update_selected_index()
   self.selected = self.page_size * self.page + self.list.selected
end

function UiPages:select_page(page)
   page = page or self.page

   local contents = {}
   for i=self.selected, self.selected+self.page_size do
      if self.items[i] == nil then
         break
      end
      contents[#contents + 1] = self.items[i]
   end

   self.list:set_data(contents)

   self.page = page
   self:update_selected_index()
end

function UiPages:set_data(items)
   self.items = items or self.items
   self.selected = 1
   self.page = 1
   self.page_max = math.floor(#self.items / self.page_size)

   self:select_page()
end

function UiPages:next_page()
   local page = self.page + 1
   if page > self.page_max then
      self.page = 1
   end
   self:select_page()
end

function UiPages:previous_page()
   local page = self.page - 1
   if page < 1 then
      self.page = self.page_max
   end
   self:select_page()
end

function UiPages:select_next()
   self.list:select_next()
   self:update_selected_index()
end

function UiPages:select_previous()
   self.list:select_previous()
   self:update_selected_index()
end

function UiPages:selected_item()
   return self.items[self.selected]
end

return UiPages
