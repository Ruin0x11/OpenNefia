local Draw = require("api.Draw")
local Input = require("api.Input")
local UiList = require("api.gui.UiList")
local IUiPagedList = require("api.gui.IUiPagedList")
local IUiList = require("api.gui.IUiList")

local UiPagedList = class("UiPagedList", IUiPagedList)

UiPagedList:delegate("list", {"x",
                              "y",
                              "relayout",
                              "update",
                              "draw",
                              "changed",
                              "get_item_text",
                              "choose",
                              "draw_item",
                              "select",
                              "draw_select_key",
                              "selected_item"})

function UiPagedList:init(list, page_size)
   assert_is_an(IUiList, list)
   self.items = list.items
   self.selected = 0
   self.page = 0
   self.page_size = page_size
   self.page_max = math.floor(#list.items / page_size)

   self.keys = {}

   self.list = list

   -- self.keys.redirect(self.list, {"up", "down", "return"})

   self:set_data()
end

function UiPagedList:bind()
end

function UiPagedList:focus()
   Input.set_key_handler(self.keys)
end

function UiPagedList:update_selected_index()
   self.selected = self.page_size * self.page + self.list.selected
end

function UiPagedList:can_select(i)
   return true
end

function UiPagedList:select_page(page)
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

function UiPagedList:set_data(items)
   self.items = items or self.items
   self.selected = 1
   self.page = 1
   self.page_max = math.floor(#self.items / self.page_size)

   self:select_page()
end

function UiPagedList:next_page()
   local page = self.page + 1
   if page > self.page_max then
      page = 1
   end
   self:select_page(page)
end

function UiPagedList:previous_page()
   local page = self.page - 1
   if page < 1 then
      page = self.page_max
   end
   self:select_page(page)
end

function UiPagedList:select_next()
   self.list:select_next()
   self:update_selected_index()
end

function UiPagedList:select_previous()
   self.list:select_previous()
   self:update_selected_index()
end

function UiPagedList:selected_item()
   return self.items[self.selected]
end

return UiPagedList
