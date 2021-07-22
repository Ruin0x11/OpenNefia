local Ui = require("api.Ui")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiTheme = require("api.gui.UiTheme")
local UiMousePanel = require("mod.mouse_ui.api.gui.UiMousePanel")
local UiMouseButton = require("mod.mouse_ui.api.gui.UiMouseButton")
local UiMouseRoot = require("mod.mouse_ui.api.gui.UiMouseRoot")
local UiMouseHBox = require("mod.mouse_ui.api.gui.UiMouseHBox")
local UiMouseVBox = require("mod.mouse_ui.api.gui.UiMouseVBox")
local UiMousePadding = require("mod.mouse_ui.api.gui.UiMousePadding")
local UiMouseSlider = require("mod.mouse_ui.api.gui.UiMouseSlider")
local UiMouseText = require("mod.mouse_ui.api.gui.UiMouseText")

local MapEditorNewPanel = class.class("MapEditorNewPanel", IUiLayer)

MapEditorNewPanel:delegate("input", IInput)

function MapEditorNewPanel:init()
   self.text_width = UiMouseText:new {}
   self.text_height = UiMouseText:new {}

   self.slider_width = UiMouseSlider:new {
      value = 20,
      min_value = 1,
      max_value = 100,
      on_changed = function(v) self.text_width:set_text(tostring(v)) end
   }
   self.slider_height = UiMouseSlider:new {
      value = 20,
      min_value = 1,
      max_value = 100,
      on_changed = function(v) self.text_height:set_text(tostring(v)) end
   }

   self.root = UiMouseRoot:new {
      child = UiMousePanel:new {
         padding = UiMousePadding:new_all(4),
         child = UiMouseVBox:new {
            children = {
               UiMouseHBox:new {
                  children = {
                     self.slider_width,
                     UiMouseVBox:new {
                        children = {
                           UiMouseText:new { text = "Width" },
                           self.text_width
                        }
                     }
                  }
               },
               UiMouseHBox:new {
                  children = {
                     self.slider_height,
                     UiMouseVBox:new {
                        children = {
                           UiMouseText:new { text = "Height" },
                           self.text_height
                        }
                     }
                  }
               },
               UiMouseHBox:new {
                  children = {
                     UiMouseButton:new { text = "OK", callback = function() self.finished = true end },
                     UiMouseButton:new { text = "Cancel", callback = function() self.canceled = true end }
                  }
               }
            }
         }
      }
   }

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
   self.input:bind_mouse(self:make_mousemap())
   self.input:bind_mouse_elements(self:get_mouse_elements(true))
   self.input:forward_to(self.root)
end

function MapEditorNewPanel:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
   }
end

function MapEditorNewPanel:make_mousemap()
   return {}
end

function MapEditorNewPanel:get_mouse_elements(recursive)
   return self.root:get_mouse_elements(recursive)
end

function MapEditorNewPanel:relayout(x, y, width, height)
   self.width = 600
   self.height = 400

   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.t = UiTheme.load(self)

   self.root:relayout(self.x, self.y, self.width, self.height)
end

function MapEditorNewPanel:draw()
   self.root:draw()
end

function MapEditorNewPanel:update(dt)
   local canceled = self.canceled
   local finished = self.finished

   self.canceled = false
   self.finished = false
   self.root:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if finished then
      return { width = self.slider_width:get_value(), height = self.slider_height:get_value() }, nil
   end
end

return MapEditorNewPanel
