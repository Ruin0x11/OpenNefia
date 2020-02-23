local IList = require("api.gui.IList")
local ISettable = require("api.gui.ISettable")

local ListModel = class.class("ListModel", {IList, ISettable})

function ListModel:init(items)
   self.items = items
   self.selected = 1
   self.chosen = false
   self.changed = true

   self:set_data()
end

function ListModel:set_data(items)
   self.items = items or self.items
   local old_selected = self.selected
   self:select()
   self.selected = math.min(old_selected, #self.items)
   self.selected = math.max(self.selected, 1)
end

function ListModel:get(i)
   return self.items[i]
end

function ListModel:iter()
   return fun.iter(self.items)
end

function ListModel:len()
   return #self.items
end

function ListModel:select(i)
   if not self:can_select(self.items[i], i) then return end

   self.changed = self.selected ~= i

   self.selected = i or self.selected
   if self.selected > #self.items then
      self.selected = 1
   elseif self.selected < 1 then
      self.selected = #self.items
      if self.selected < 1 then
         self.selected = 1
      end
   end

   self:on_select(self:selected_item(), i)
end

function ListModel:select_next(delta)
   self:select(self.selected + (delta or 1))
end

function ListModel:select_previous(delta)
   self:select_next(-(delta or 1))
end

function ListModel:selected_item()
   return self.items[self.selected]
end

function ListModel:get_item_text(item, i)
   return item
end

function ListModel:can_select(item, i)
   return true
end

function ListModel:can_choose(item, i)
   return true
end

function ListModel:choose(i)
   i = i or self.selected
   if i < 1 or i > #self.items then return false end
   if not self:can_choose(self.items[i], i) then return false end
   self:select(i)
   self.chosen = true
   self:on_choose(self:selected_item(), i)
end

function ListModel:on_choose(item, i)
end

function ListModel:on_select(item, i)
end

return ListModel
