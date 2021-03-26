local TextHandler = require("api.gui.TextHandler")
local Ui = require("api.Ui")
local Gui = require("api.Gui")

local IInput = require("api.gui.IInput")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local UiTextEditor = require("mod.ui_console.api.gui.UiTextEditor")
local StyledConsoleRenderer = require("mod.ui_console.api.gui.StyledConsoleRenderer")

local TextEditorPrompt = class.class("TextEditorPrompt", IUiLayer)

TextEditorPrompt:delegate("input", IInput)

function TextEditorPrompt:init(text)
   text = text or ""

   self.editor = UiTextEditor:new(text, 16, StyledConsoleRenderer:new())

   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys(self:make_keymap())
   self.input:forward_to(self.editor)
   self.input:halt_input()
end

function TextEditorPrompt:make_keymap()
   return {
      escape = function() self.canceled = true end,
      text_canceled = function() self.canceled = true end,
   }
end

function TextEditorPrompt:on_query()
   Gui.play_sound("base.pop2")
end

function TextEditorPrompt:relayout(x, y, width, height)
   self.width = 400
   self.height = 500

   self.x, self.y, self.width, self.height = Ui.params_centered(self.width, self.height)
   self.editor:relayout(self.x, self.y, self.width, self.height)
end

function TextEditorPrompt:draw()
   self.editor:draw()
end

function TextEditorPrompt:update(dt)
   local canceled = self.canceled

   self.canceled = false
   self.editor:update(dt)

   if canceled then
      return self.editor:merge_lines(), nil
   end
end

return TextEditorPrompt
