local Draw = require("api.Draw")
local TextHandler = require("api.gui.TextHandler")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTextEditor = require("mod.ui_console.api.gui.UiTextEditor")
local DefaultConsoleRenderer = require("mod.ui_console.api.gui.DefaultConsoleRenderer")

local TextEditorLayer = class.class("TextEditorLayer", IUiLayer)

TextEditorLayer:delegate("input", IInput)

function TextEditorLayer:init(text)
   text = text or ""

   self.editor = UiTextEditor:new(text, 14, DefaultConsoleRenderer:new())

   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys(self:make_keymap())
   self.input:forward_to(self.editor)
   self.input:halt_input()
end

function TextEditorLayer:make_keymap()
   return {
      escape = function() self.canceled = true end,
      text_canceled = function() self.canceled = true end,
   }
end

function TextEditorLayer:relayout(x, y, width, height)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.editor:relayout(self.x, self.y, self.width, self.height)
end

function TextEditorLayer:draw()
   self.editor:draw()
end

function TextEditorLayer:update(dt)
   local canceled = self.canceled

   self.canceled = false
   self.editor:update(dt)

   if canceled then
      return self.editor:merge_lines(), nil
   end
end

return TextEditorLayer
