local Draw = require("api.Draw")
local Input = require("api.Input")
local IPaged = require("api.gui.IPaged")
local ISettable = require("api.gui.ISettable")
local IUiLayer = require("api.gui.IUiLayer")

local UiPagedContainer = class.class("UiPagedContainer", {ISettable, IPaged, IUiLayer})

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
         size = 1
      end
      for i=1,size do
         page_handlers[index] = { layer = layer, page = i }
         index = index + 1
      end
   end
   return page_handlers
end

function UiPagedContainer:init(x, y, width, height, sublayers)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.sublayers = sublayers
   self.page = 1
   self.page_handlers = calculate_page_handlers(sublayers)
   self.page_max = #self.page_handlers
   self.page_size = 1

   self:set_data()
end

function UiPagedContainer:bind()
end

function UiPagedContainer:focus()
   self:current_sublayer():focus()
end

function UiPagedContainer:relayout(x, y, width, height)
   self:current_sublayer():relayout(x, y, width, height)
end

function UiPagedContainer:set_data(sublayers)
   self.sublayers = sublayers or self.sublayers

   for _, layer in pairs(sublayers) do
      class.assert_is_an(IUiLayer, layer)
      layer.x = self.x
      layer.y = self.y
      layer.width = self.width
      layer.height = self.height
   end

   self.page_max = #self.sublayers
   self.page_size = 1

   self:select_page(1)
end

function UiPagedContainer:update(dt)
   self:current_sublayer():update(dt)
end

function UiPagedContainer:draw()
   self:current_sublayer():draw()
end

function UiPagedContainer:current_sublayer()
   local inner = self.page_handlers[self.page]
   return inner.layer, inner.page
end

function UiPagedContainer:select_page(page)
   self.page = page or self.page

   local layer, inner_page = self:current_sublayer()
   layer:relayout(self.x, self.y, self.width, self.height)

   if class.is_an(IPaged, layer) then
      layer:select_page(inner_page)
   end
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

return UiPagedContainer
