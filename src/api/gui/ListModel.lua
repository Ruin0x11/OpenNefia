local ListModel = class("ListModel", {IList, ISettable})

function ListModel:init(items)
   self.items = items
   self.selected = 1
   self.chosen = false
   self.changed = true
end

function ListModel:set_data(items)
   self.items = items or self.items
   self:select()
end

function ListModel:select(i)
   if not self:can_select(i) then return end

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
end

function ListModel:select_next()
   self:select(self.selected + 1)
end

function ListModel:select_previous()
   self:select(self.selected - 1)
end

function ListModel:selected_item()
   return self.items[self.selected]
end

function ListModel:get_item_text(item)
   return item
end

function ListModel:can_select(i)
   return true
end

function ListModel:choose(i)
   self:select(i)
   self.chosen = true
end

return ListModel
