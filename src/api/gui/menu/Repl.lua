local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local circular_buffer = require("thirdparty.circular_buffer")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local TextHandler = require("api.gui.TextHandler")

local Repl = class("Repl", IUiLayer)

Repl:delegate("input", IInput)

function Repl:init(env)
   self.text = ""
   self.caret = "> "
   self.env = env or {}
   self.result = ""
   self.size = 200
   self.scrollback = circular_buffer:new(self.size)
   self.history = {}
   self.history_index = 0

   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys {
      text_entered = function(t)
         self.text = self.text .. t
      end,
      backspace = function()
         self.text = utf8.pop(self.text)
      end,
      text_submitted = function()
         self:submit()
         Gui.redraw_screen()
         self.input:halt_input()
      end,
      text_canceled = function() self.finished = true end,
      up = function()
         self:history_next()
      end,
      down = function()
         self:history_prev()
      end
   }
   self.input:halt_input()
end

function Repl:history_prev()
   print("prev")
   self.history_index = math.max(self.history_index - 1, 0)
   self.text = self.history[self.history_index] or ""
end

function Repl:history_next()
   print("next")
   self.history_index = math.min(self.history_index + 1, #self.history)
   self.text = self.history[self.history_index] or ""
end

function Repl:relayout(x, y, width, height)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height() / 3
   self.color = {17, 17, 65, 192}
   self.font_size = 15
   Draw.set_font(self.font_size)
   self.max_lines = (self.height - 5) / Draw.text_height() - 1
end

function Repl:submit()
   local text = self.text
   self.text = ""
   self.history_index = 0

   self.scrollback:push(self.caret .. text)
   if string.nonempty(text) then
      table.insert(self.history, text)
   end

   local chunk, err = loadstring("return " .. text)

   if chunk == nil then
      chunk, err = loadstring(text)

      if chunk == nil then
         self.scrollback:push(err)
         return
      end
   end
   -- setfenv(chunk, self.env)
   local success, result = pcall(chunk)

   for line in string.lines(tostring(result)) do
      self.scrollback:push(line)
   end
end

function Repl:draw()
   Draw.filled_rect(self.x, self.y, self.width, self.height, self.color)

   Draw.set_font(self.font_size)
   Draw.set_color(255, 255, 255)
   Draw.text(self.caret, self.x + 5, self.y + self.height - Draw.text_height() - 5)
   Draw.text(self.text, self.x + 5 + Draw.text_width(self.caret), self.y + self.height - Draw.text_height() - 5)

   for i=1,self.max_lines do
      local t = self.scrollback[i]
      if t == nil then
         break
      end
      Draw.text(t, self.x + 5, self.y + self.height - 5 - Draw.text_height() * (i+1))
   end
end

function Repl:update(dt)
   if self.finished then
      return true
   end
end

return Repl
