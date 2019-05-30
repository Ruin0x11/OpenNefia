local IList = require("api.gui.IList")
local IPaged = require("api.gui.IPaged")
local ISettable = require("api.gui.ISettable")
local ListModel = require("api.gui.ListModel")

local PagedListModel = class("PagedListModel", {IList, IPaged, ISettable})
PagedListModel:delegate("model", {"items", "selected_item", "choose", "chosen", "changed", "select", "selected"})

function PagedListModel:init(items, page_size)
   self.items_ = items
   self.model = ListModel:new({})
   self.selected = 1
   self.page = 1
   self.page_size = page_size
   self.page_max = math.floor(#items / page_size)

   self:set_data()
end

function PagedListModel:update_selected_index()
   self.selected_ = self.page_size * self.page + self.model.selected
end

function PagedListModel:can_select(i)
   return true
end

function PagedListModel:get_item_text(i)
   return i
end

function PagedListModel:select_page(page)
   page = page or self.page

   local contents = {}
   for i=self.selected_, self.selected_ + self.page_size do
      if self.items_[i] == nil then
         break
      end
      contents[#contents + 1] = self.items_[i]
   end

   self.model:set_data(contents)

   self.page = page
   self:update_selected_index()
end

function PagedListModel:set_data(items)
   self.items_ = items or self.items_
   self.selected_ = 1
   self.page = 1
   self.page_max = math.floor(#self.items_ / self.page_size)

   self:select_page()
end

function PagedListModel:next_page()
   local page = self.page + 1
   if page > self.page_max then
      page = 1
   end
   self:select_page(page)
end

function PagedListModel:previous_page()
   local page = self.page - 1
   if page < 1 then
      page = self.page_max
   end
   self:select_page(page)
end

function PagedListModel:select_next()
   self.model:select_next()
   self:update_selected_index()
end

function PagedListModel:select_previous()
   self.model:select_previous()
   self:update_selected_index()
end

return PagedListModel
