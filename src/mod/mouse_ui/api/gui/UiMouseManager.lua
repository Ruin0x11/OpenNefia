local IMouseElementProvider = require("api.gui.IMouseElementProvider")
local IInput = require("api.gui.IInput")
local IMouseElement = require("api.gui.IMouseElement")
local InputHandler = require("api.gui.InputHandler")
local UiMouseButton = require("mod.mouse_ui.api.gui.UiMouseButton")

--- The purpose of this class is to unpress other mouse elements like
--- toolbars/menus when a mouse element is pressed.
---
--- It's difficult to do this without any knowledge of UI element parents. It
--- also isn't functionality that every mouse-based UI should be responsible
--- for re-implementing every time.
local UiMouseManager = class.class("UiMouseManager", {IInput, IMouseElementProvider})

UiMouseManager:delegate("input", IInput)

function UiMouseManager:init(elements, forwards)
   self.forwards = forwards or {}
   self.elements = elements or {}

   for _, element in ipairs(self.elements) do
      assert(class.is_an(IMouseElement, element) or class.is_an(IMouseElementProvider, element))
   end
   for _, forward in ipairs(self.forwards) do
      assert(class.is_an(IInput, forward))
   end

   self.input = InputHandler:new()
   self.input:bind_mouse(self:make_mousemap())
   self:_update_forwards()
end

function UiMouseManager:_update_forwards()
   self.input:forward_to(self.forwards)
end

function UiMouseManager:get_mouse_elements(recursive)
   local regions = {}
   for _, element in ipairs(self.elements) do
      if class.is_an(IMouseElement, element) then
         regions[#regions+1] = element
      end
      if recursive and class.is_an(IMouseElementProvider, element) then
         table.append(regions, element:get_mouse_elements(recursive))
      end
   end
   return regions
end

function UiMouseManager:make_mousemap()
   return {
      element = function(element, pressed)
         if pressed then
            self:unpress_unfocused_mouse_elements(element)
         else
            if class.is_an(UiMouseButton, element) then
               self:unpress_mouse_elements(element)
            end
         end
      end
   }
end

function UiMouseManager:unpress_mouse_elements()
   for _, other in self:iter_mouse_elements(true) do
      other:set_pressed(false)
   end
end

function UiMouseManager:unpress_unfocused_mouse_elements(element)
   local p = table.set {}
   while element do
      p[element] = true
      element = element:get_parent()
   end
   for _, other in self:iter_mouse_elements(true) do
      if not p[other] then
         other:set_pressed(false)
      end
   end
end

return UiMouseManager
