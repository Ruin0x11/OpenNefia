local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local UiTheme = require("api.gui.UiTheme")
local IMouseElement = require("api.gui.IMouseElement")
local UiMouseStyle = require("mod.mouse_ui.api.UiMouseStyle")

local UiMouseHBox = class.class("UiMouseHBox", IUiMouseElement)

function UiMouseHBox:init(opts)
   self.min_width = opts.width or 1
   self.min_height = opts.height or 1
   self.padding = opts.padding or UiMouseStyle.default_padding()
   self:set_children(opts.children)
end

function UiMouseHBox:get_mouse_elements(recursive)
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

function UiMouseHBox:set_children(children)
   for _, child in ipairs(children) do
      assert(class.is_an(IUiMouseElement, child))
      child._parent = self
   end
   self.children = children
end

function UiMouseHBox:get_minimum_width()
   return math.max(self.min_width, fun.iter(self.children):map(IUiMouseElement.get_minimum_width):sum())
end

function UiMouseHBox:get_minimum_height()
   return self.min_height
end

function UiMouseHBox:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   local child_count = #self.children
   local element_width = self.width / child_count

   for i, child in ipairs(self.children) do
      child:relayout(
         self.padding:apply(
            self.x + ((i-1) * element_width),
            self.y,
            element_width,
            self.height)
      )
   end
end

function UiMouseHBox:draw()
   for _, child in ipairs(self.children) do
      child:draw()
   end
end

function UiMouseHBox:update(dt)
   for _, child in ipairs(self.children) do
      child:update(dt)
   end
end

return UiMouseHBox
