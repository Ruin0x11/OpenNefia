local Draw = require("api.Draw")
local TextHandler = require("api.gui.TextHandler")
local ConsoleConsts = require("mod.ui_console.api.gui.ConsoleConsts")

local IInput = require("api.gui.IInput")
local IUiElement = require("api.gui.IUiElement")
local InputHandler = require("api.gui.InputHandler")
local UiConsole = require("mod.ui_console.api.gui.UiConsole")

local UiTextEditor = class.class("UiTextEditor", {IUiElement, IInput})

UiTextEditor:delegate("input", IInput)

function UiTextEditor:init(text, font_size, renderer)
   text = text or ""

   self.con = UiConsole:new(font_size or 14, renderer)

   self.cursor_x = 0
   self.cursor_y = 0
   self.offset_x = 0
   self.offset_y = 0
   self.frames = 0
   self.dirty = true

   self.lines = fun.wrap(fun.dup(string.lines(text))):to_list()
   if #self.lines == 0 then
      self.lines[1] = ""
   end

   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys(self:make_keymap())
   self.input:halt_input()
end

function UiTextEditor:make_keymap()
   return {
      north = function() self:move_cursor(0, -1) end,
      south = function() self:move_cursor(0, 1) end,
      west = function() self:move_cursor(-1, 0) end,
      east = function() self:move_cursor(1, 0) end,
      repl_page_up = function()
         self:move_cursor(-self.cursor_x, -self.cursor_y)
      end,
      repl_page_down = function()
         local dx = 0
         if self.cursor_y+1 == #self.lines then
            dx = #self.lines[#self.lines] - self.cursor_x
         end
         self:move_cursor(dx, #self.lines-self.cursor_y-1)
      end,
      repl_first_char = function()
         self:move_cursor(-self.cursor_x, 0)
      end,
      repl_last_char = function()
         self:move_cursor(#self:current_line() - self.cursor_x, 0)
      end,
      text_entered = function(t)
         self:put_char(t)
      end,
      raw_backspace = function()
         self:rub_char()
      end,
      text_submitted = function()
         self:newline()
      end,
   }
end

function UiTextEditor:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.con:relayout(self.x, self.y, self.width, self.height)
   self.dirty = true
end

function UiTextEditor:current_line()
   return self.lines[self.cursor_y+1]
end

function UiTextEditor:move_cursor(dx, dy)
   if self.con:is_in_bounds(self.cursor_x, self.cursor_y) then
      local ch = self.con:get_char(self.cursor_x, self.cursor_y)
      self.con:put_char(self.cursor_x, self.cursor_y, ch, 1, 3)
   end

   local move_to_beginning
   local move_to_end
   if self.cursor_y + dy < 0 then
      move_to_beginning = true
   elseif self.cursor_y + dy > #self.lines - 1 then
      move_to_end = true
   end
   self.cursor_y = math.clamp(self.cursor_y + dy, 0, #self.lines-1)

   local line = self:current_line()
   if move_to_beginning then
      dx = -self.cursor_x
   elseif move_to_end then
      dx = utf8.wide_len(line) - self.cursor_x
   end
   self.cursor_x = math.clamp(self.cursor_x + dx, 0, utf8.wide_len(line))

   if self.con:is_in_bounds(self.cursor_x, self.cursor_y) then
      local ch = self.con:get_char(self.cursor_x, self.cursor_y)
      self.con:put_char(self.cursor_x, self.cursor_y, ch, 1, 3)
   end

   self.frames = 0
end

function UiTextEditor:put_char(t)
   local line = self:current_line()

   if self.cursor_x == #line then
      line = line .. t
   elseif self.cursor_x == 0 then
      line = t .. line
   else
      local a, b = string.split_at_pos(line, self.cursor_x)
      line = a .. t .. b
   end

   self.lines[self.cursor_y+1] = line
   self:move_cursor(utf8.len(t), 0)
   self.dirty = true
end

function UiTextEditor:rub_char()
   if self.cursor_x == 0 and self.cursor_y == 0 then
      return
   end

   if self.cursor_x == 0 then
      -- join lines
      local old_line = table.remove(self.lines, self.cursor_y + 1)
      self.dirty = true
      self.cursor_y = self.cursor_y - 1
      local line = self.lines[self.cursor_y+1]
      local dx = #line - self.cursor_x
      self.lines[self.cursor_y+1] = line .. old_line
      self:move_cursor(dx, 0)
      for x = 0, self.con.width_chars do
         self.con:put_char(x, #self.lines, " ", 1, 3)
      end
      return
   end

   local line = self:current_line()

   local dx = -1
   if self.cursor_x == #line then
      local ch
      line, ch = utf8.pop(line)
      dx = ch and -utf8.wide_len(ch)
   elseif self.cursor_x == 1 then
      line = utf8.sub(line, 2)
   else
      local a, b = string.split_at_pos(line, self.cursor_x)
      local ch = utf8.sub(a, utf8.len(a))
      a = utf8.sub(a, 1, utf8.len(a)-1)
      line = a .. b
      dx = ch and -utf8.wide_len(ch)
   end

   self.lines[self.cursor_y+1] = line
   self:move_cursor(dx, 0)
   self.dirty = true
end

function UiTextEditor:newline()
   local line = self:current_line()
   local new_line
   if self.cursor_x == #line then
      new_line = ""
   elseif self.cursor_x == 1 then
      new_line = utf8.sub(line, 2)
      line = utf8.sub(line, 0, 1)
   else
      local a, b = string.split_at_pos(line, self.cursor_x)
      line = a
      new_line = b
   end

   self.lines[self.cursor_y+1] = line
   table.insert(self.lines, self.cursor_y+1+1, new_line)
   self:move_cursor(-self.cursor_x, 1)
   self.dirty = true
end

function UiTextEditor:redraw_lines()
   for y, line in ipairs(self.lines) do
      local nx, ny = self.con:print_string(line, 0, y-1)
      for x = nx, self.con.width_chars do
         self.con:set_char(x, ny, " ")
      end
   end
end

function UiTextEditor:merge_lines()
   return table.concat(self.lines, "\n")
end

function UiTextEditor:draw()
   if self.dirty then
      self:redraw_lines()
      self.dirty = false
   end
   self.con:draw()
end

function UiTextEditor:update(dt)
   self.frames = self.frames + dt / (config.base.screen_refresh * (16.66 / 1000))

   if self.con:is_in_bounds(self.cursor_x, self.cursor_y) then
      local attr = self.con:get_char_attr(self.cursor_x, self.cursor_y)
      if math.floor(self.frames * 2) % 2 == 0 then
         attr = bit.bor(ConsoleConsts.ATTR.CURSOR, attr)
      else
         attr = bit.band(bit.bnot(ConsoleConsts.ATTR.CURSOR), attr)
      end
      self.con:set_char_attr(self.cursor_x, self.cursor_y, attr)
   end

   self.con:update(dt)
end

return UiTextEditor
