local Ui = require("api.Ui")
local IInput = require("api.gui.IInput")
local UiMouseManager = require("mod.mouse_ui.api.gui.UiMouseManager")
local InputHandler = require("api.gui.InputHandler")
local UiMousePadding = require("mod.mouse_ui.api.gui.UiMousePadding")

local IUiMouseElement = require("mod.mouse_ui.api.gui.IUiMouseElement")
local UiTheme = require("api.gui.UiTheme")

local UiMouseRoot = class.class("UiMouseRoot", {IInput, IUiMouseElement})

UiMouseRoot:delegate("input", IInput)

function UiMouseRoot:init(opts)
   self.mouse_manager = UiMouseManager:new()

   self.input = InputHandler:new()
   self.input:forward_to(self.mouse_manager)

   self.padding = opts.padding or UiMousePadding:new()
   self:set_child(opts.child)
end

function UiMouseRoot:set_child(child)
   if child ~= nil then
      assert(class.is_an(IUiMouseElement, child))
      child._parent = self
   end
   self.child = child

   self.mouse_manager:set_elements { self.child or nil }
end

function UiMouseRoot:get_mouse_elements(recursive)
   return self.mouse_manager:get_mouse_elements(recursive)
end

function UiMouseRoot:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   if self.child then
      self.child:relayout(self.padding:apply(self.x, self.y, self.width, self.height))
   end
end

function UiMouseRoot:draw()
   if self.child then
      self.child:draw()
   end
end

function UiMouseRoot:update(dt)
   if self.child then
      self.child:update(dt)
   end
end

return UiMouseRoot
