local Draw = require("api.Draw")
local TextHandler = require("api.gui.TextHandler")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiConsole = require("mod.ui_console.api.gui.UiConsole")

local TerminalLayer = class.class("TerminalLayer", IUiLayer)

TerminalLayer:delegate("input", IInput)

function TerminalLayer:init()
   self.con = UiConsole:new(14)

   self.cursor_x = 0
   self.cursor_y = 0
   self.frames = 0

   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys(self:make_keymap())
   self.input:halt_input()
end

function TerminalLayer:make_keymap()
   return {
      escape = function() self.canceled = true end,
      north = function() self:move_cursor(0, -1) end,
      south = function() self:move_cursor(0, 1) end,
      west = function() self:move_cursor(-1, 0) end,
      east = function() self:move_cursor(1, 0) end,
      text_entered = function(t)
         self:put_char(t)
      end,
      raw_backspace = function()
         self:rub_char()
      end,
      text_submitted = function()
         self:newline()
      end,
      text_canceled = function() self.canceled = true end,
   }
end

function TerminalLayer:relayout(x, y, width, height)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height()
   self.con:relayout(self.x, self.y, self.width, self.height)
   self.cursor_x = math.clamp(self.cursor_x, 0, self.con.width_chars-1)
   self.cursor_y = math.clamp(self.cursor_y, 0, self.con.height_chars-1)
end

function TerminalLayer:move_cursor(dx, dy)
   local ch = self.con:get_char(self.cursor_x, self.cursor_y)
   self.con:put_char(self.cursor_x, self.cursor_y, ch, 1, 3)

   self.cursor_x = math.clamp(self.cursor_x + dx, 0, self.con.width_chars-1)
   self.cursor_y = math.clamp(self.cursor_y + dy, 0, self.con.height_chars-1)

   ch = self.con:get_char(self.cursor_x, self.cursor_y)
   self.con:put_char(self.cursor_x, self.cursor_y, ch, 1, 3)

   self.frames = 0
end

function TerminalLayer:put_char(t)
   self.con:put_char(self.cursor_x, self.cursor_y, t, 1, 3)
   self:move_cursor(1, 0)
end

function TerminalLayer:rub_char()
   self:move_cursor(-1, 0)
   self.con:put_char(self.cursor_x, self.cursor_y, " ", 1, 3)
end

function TerminalLayer:newline()
   self:move_cursor(-self.cursor_x, 1)
end

function TerminalLayer:draw()
   self.con:draw()
end

function TerminalLayer:update(dt)
   self.frames = self.frames + dt / (config.base.screen_refresh * (16.66 / 1000))

   local fg, bg
   if math.floor(self.frames * 2) % 2 == 0 then
      fg = 3
      bg = 1
   else
      fg = 1
      bg = 3
   end

   local ch = self.con:get_char(self.cursor_x, self.cursor_y)
   self.con:put_char(self.cursor_x, self.cursor_y, ch, fg, bg)

   local canceled = self.canceled

   self.canceled = false
   self.con:update(dt)

   if canceled then
      return nil, "canceled"
   end
end

return TerminalLayer
