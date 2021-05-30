local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local UiTheme = require("api.gui.UiTheme")
local UiMousePadding = require("mod.mouse_ui.api.gui.UiMousePadding")
local IMouseElement = require("api.gui.IMouseElement")

local UiMouseVBox = class.class("UiMouseVBox", IUiMouseElement)

function UiMouseVBox:init(opts)
   self.padding = opts.padding or UiMousePadding:new()
   self:set_children(opts.children)
end

function UiMouseVBox:get_mouse_elements(recursive)
   local regions = {}
   for _, child in ipairs(self.children) do
      if class.is_an(IMouseElement, child) then
         regions[#regions+1] = child
      end
      if recursive then
         table.append(regions, child:get_mouse_elements(recursive))
      end
   end
   return regions
end

function UiMouseVBox:set_children(children)
   for _, child in ipairs(children) do
      assert(class.is_an(IUiMouseElement, child))
      child._parent = self
   end
   self.children = children
end

function UiMouseVBox:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   local child_count = #self.children
   local element_height = self.height / child_count

   for i, child in ipairs(self.children) do
      child:relayout(self.x,
                     self.y + ((i-1) * element_height),
                     self.width,
                     element_height)
   end
end

function UiMouseVBox:draw()
   for _, child in ipairs(self.children) do
      child:draw()
   end
end

function UiMouseVBox:update(dt)
   for _, child in ipairs(self.children) do
      child:update(dt)
   end
end

return UiMouseVBox
