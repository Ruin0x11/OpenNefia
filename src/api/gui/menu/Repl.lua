local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local circular_buffer = require("thirdparty.circular_buffer")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")
local LuaReplMode = require("api.gui.menu.LuaReplMode")
local UiList = require("api.gui.UiList")
local TextHandler = require("api.gui.TextHandler")

local Repl = class("Repl", IUiLayer)

Repl:delegate("input", IInput)

function Repl:init(env)
   self.text = ""
   self.env = env or {}
   self.result = ""
   self.size = 10000
   self.scrollback = circular_buffer:new(self.size)
   self.scrollback_index = 0
   self.history = {}
   self.history_index = 0

   self.mode = LuaReplMode:new(env)

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
         Gui.update_screen()
         self.input:halt_input()
      end,
      text_canceled = function() self.finished = true end,
      up = function()
         self:history_next()
      end,
      down = function()
         self:history_prev()
      end,
      pageup = function()
         self:scrollback_up()
      end,
      pagedown = function()
         self:scrollback_down()
      end
   }
   self.input:halt_input()
end

function Repl:history_prev()
   self.scrollback_index = 0
   self.history_index = math.max(self.history_index - 1, 0)
   self.text = self.history[self.history_index] or ""
end

function Repl:history_next()
   self.scrollback_index = 0
   self.history_index = math.min(self.history_index + 1, #self.history)
   self.text = self.history[self.history_index] or ""
end

function Repl:scrollback_up()
   self.scrollback_index = math.clamp(self.scrollback_index + math.floor(self.max_lines / 2), 0, math.max(self.scrollback:len() - self.max_lines, 0))
end

function Repl:scrollback_down()
   self.scrollback_index = math.clamp(self.scrollback_index - math.floor(self.max_lines / 2), 0, math.max(self.scrollback:len() - self.max_lines, 0))
end

function Repl:relayout(x, y, width, height)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height() / 3
   self.color = {17, 17, 65, 192}
   self.font_size = 15
   Draw.set_font(self.font_size)
   self.max_lines = math.floor((self.height - 5) / Draw.text_height()) - 1
end

function Repl:submit()
   local text = self.text
   self.text = ""
   self.scrollback_index = 0
   self.history_index = 0

   self.scrollback:push(self.mode.caret .. text)
   if string.nonempty(text) then
      table.insert(self.history, 1, text)
   end

   local success, result = self.mode:submit(text)

   local result_text
   if type(result) == "table" then
      result_text = inspect(result)
   else
      result_text = tostring(result)
   end

   for line in string.lines(result_text) do
      self.scrollback:push(line)
   end
end

function Repl:draw()
   Draw.filled_rect(self.x, self.y, self.width, self.height, self.color)

   Draw.set_font(self.font_size)
   Draw.set_color(255, 255, 255)
   Draw.text(self.mode.caret, self.x + 5, self.y + self.height - Draw.text_height() - 5)
   Draw.text(self.text, self.x + 5 + Draw.text_width(self.mode.caret), self.y + self.height - Draw.text_height() - 5)

   if self.scrollback_index > 0 then
      local scrollback_count = string.format("%d/%d",self.scrollback_index + self.max_lines, self.scrollback:len())
      Draw.text(scrollback_count, self.width - Draw.text_width(scrollback_count) - 5, self.y + self.height - Draw.text_height() - 5)
   end

   for i=1,self.max_lines do
      local t = self.scrollback[self.scrollback_index + i]
      if t == nil then
         break
      end
      Draw.text(t, self.x + 5, self.y + self.height - 5 - Draw.text_height() * (i+1))
   end
end

function Repl:update(dt)
   if self.finished then
      self.finished = false
      return true
   end
end

return Repl
