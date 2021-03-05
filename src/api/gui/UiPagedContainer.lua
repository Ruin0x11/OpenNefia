local IPaged = require("api.gui.IPaged")
local ISettable = require("api.gui.ISettable")
local IUiLayer = require("api.gui.IUiLayer")
local IUiElement = require("api.gui.IUiElement")

local UiPagedContainer = class.class("UiPagedContainer", {ISettable, IPaged, IUiElement})

-- @return a mapping from page number to the sublayer layer and its
-- inner page, if any.
local function calculate_page_handlers(sublayers)
   local page_handlers = {}
   local index = 1
   for _, layer in ipairs(sublayers) do
      local size
      if class.is_an(IPaged, layer) then
         size = layer.page_max
      else
         size = 0
      end
      for i=0,size do
         -- TODO: PagedListModel should be 1-indexed instead of 0-indexed
         page_handlers[index] = { layer = layer, page = i }
         index = index + 1
      end
   end
   return page_handlers, index - 1
end

function UiPagedContainer:init(sublayers)
   self.sublayers = sublayers
   self.page = 1
   self.page_handlers, self.page_max = calculate_page_handlers(sublayers)
   self.page_size = 1
   self.changed_page = true

   self:set_data()
end

function UiPagedContainer:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   for _, sublayer in ipairs(self.sublayers) do
      sublayer:relayout(self.x, self.y, self.width, self.height)
   end
end

function UiPagedContainer:set_data(sublayers)
   self.sublayers = sublayers or self.sublayers

   for _, layer in pairs(self.sublayers) do
      class.assert_is_an(IUiLayer, layer)
   end

   self.page_handlers, self.page_max = calculate_page_handlers(self.sublayers)
   self.page_size = 1

   self:select_page(1)
end

function UiPagedContainer:refresh_page_from_sublayer()
   local sublayer = self:current_sublayer()
   for i, v in ipairs(self.page_handlers) do
      if v.layer == sublayer and v.page == sublayer.page then
         self:select_page(i)
         break
      end
   end
end

function UiPagedContainer:current_sublayer()
   local inner = self.page_handlers[self.page]
   return inner.layer, inner.page
end

function UiPagedContainer:iter()
   return fun.iter(self.page_handlers)
end

function UiPagedContainer:select_page(page)
   self.page = page or self.page

   local layer, inner_page = self:current_sublayer()

   if class.is_an(IPaged, layer) then
      layer:select_page(inner_page)
   end

   self.changed_page = true
end

function UiPagedContainer:next_page()
   local page = self.page + 1
   if page > self.page_max then
      page = 1
   end
   self:select_page(page)
end

function UiPagedContainer:previous_page()
   local page = self.page - 1
   if page < 1 then
      page = self.page_max
   end
   self:select_page(page)
end

function UiPagedContainer:draw()
   self:current_sublayer():draw()
end

function UiPagedContainer:update(dt)
   self.changed_page = false
   return self:current_sublayer():update(dt)
end

return UiPagedContainer
