local IUiElement = require("api.gui.IUiElement")
local Draw = require("api.Draw")
local IUiConsoleRenderer = require("mod.ui_console.api.gui.IUiConsoleRenderer")
local ConsoleConsts = require("mod.ui_console.api.gui.ConsoleConsts")

local UiConsole = class.class("UiConsole", IUiElement)

function UiConsole:init(font_size, renderer)
   class.assert_is_an(IUiConsoleRenderer, renderer)

   self.font_size = font_size
   self._renderer = renderer

   self.width_chars = 0
   self.height_chars = 0
   self.canvas = nil
   self.dirty = "all"
   self.buffer = nil
   self.colors = {}
   self.tiles_dirty = {}
end

function UiConsole:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self._renderer:relayout(x, y, width, height)
   local width_chars, height_chars = self._renderer:set_font_size(self.font_size)

   if self.width_chars ~= width_chars
      or self.height_chars ~= height_chars
   then
      self:resize(width_chars, height_chars)
   end

   self.canvas = Draw.create_canvas(self.width, self.height)
   self.dirty = "all"
end

function UiConsole:get_index(x, y)
   if x < 0 or y < 0 or x >= self.width_chars or y >= self.height_chars then
      return nil
   end
   return self.width_chars * y + x + 1
end

function UiConsole:is_in_bounds(x, y)
   return not not self:get_index(x, y)
end

function UiConsole:ensure_in_bounds(x, y)
   local ind = self:get_index(x, y)
   if not ind then
      error(("Position out of bounds: %d/%d"):format(x, y))
   end
   return ind
end

function UiConsole:get_char(x, y)
   local ind = self:ensure_in_bounds(x, y)
   return self.buffer[ind].ch
end

function UiConsole:get_char_bg(x, y)
   local ind = self:ensure_in_bounds(x, y)
   return self.buffer[ind].bg
end

function UiConsole:get_char_fg(x, y)
   local ind = self:ensure_in_bounds(x, y)
   return self.buffer[ind].fg
end

function UiConsole:get_char_attr(x, y)
   local ind = self:ensure_in_bounds(x, y)
   return self.buffer[ind].attr
end

function UiConsole:set_char_attr(x, y, attr)
   local ind = self:ensure_in_bounds(x, y)
   self.buffer[ind].attr = attr
   self.tiles_dirty[#self.tiles_dirty+1] = ind
   self.dirty = self.dirty or true
end

function UiConsole:set_char(x, y, ch)
   local ind = self:get_index(x, y)
   if not ind then
      return
   end
   assert(type(ch) == "string")
   ch = utf8.wide_sub(ch, 0, 1)
   self.buffer[ind].ch = ch
   self.buffer[ind].wide = utf8.wide_len(ch) == 2
   self.tiles_dirty[#self.tiles_dirty+1] = ind
   self.dirty = self.dirty or true
end

function UiConsole:put_char(x, y, ch, fg, bg, attr)
   local ind = self:get_index(x, y)
   if not ind then
      return
   end
   assert(type(ch) == "string")
   ch = utf8.wide_sub(ch, 0, 1)
   self.buffer[ind].ch = ch
   self.buffer[ind].wide = utf8.wide_len(ch) == 2
   self.buffer[ind].fg = fg
   self.buffer[ind].bg = bg
   self.buffer[ind].attr = attr or 0
   self.tiles_dirty[#self.tiles_dirty+1] = ind
   self.dirty = self.dirty or true
end

function UiConsole:mark_region_dirty(x, y, w, h)
   for j = y, y+h do
      for i = x, x+w do
         if self:is_in_bounds(i, j) then
            local ind = self.width_chars * j + i + 1
            self.tiles_dirty[#self.tiles_dirty+1] = ind
         end
      end
   end
   self.dirty = self.dirty or true
end

function UiConsole:print_string(str, x, y, fg, bg)
   fg = fg or ConsoleConsts.COLOR.FG
   bg = bg or ConsoleConsts.COLOR.BG
   for _, ch in utf8.chars(str) do
      if not self:is_in_bounds(x, y) then
         break
      end
      self:put_char(x, y, ch, fg, bg)
      x = x + utf8.wide_len(ch)
   end
   return x, y
end

function UiConsole:clear()
   self.buffer = {}
   for x = 0, self.width_chars-1 do
      for y = 0, self.height_chars-1 do
         local i = self.width_chars * y + x + 1
         self.buffer[i] = { ch = " ", bg = ConsoleConsts.COLOR.BG, fg = ConsoleConsts.COLOR.FG, attr = ConsoleConsts.ATTR.NONE }
      end
   end
   self.dirty = "all"
end

function UiConsole:resize(width_chars, height_chars)
   self.width_chars = width_chars
   self.height_chars = height_chars
   self:clear()
end

function UiConsole:_redraw()
   local tiles_dirty
   if self.dirty == "all" then
      tiles_dirty = nil
   else
      tiles_dirty = self.tiles_dirty
   end

   self._renderer:render_chars(self.buffer, tiles_dirty)

   self.tiles_dirty = {}
   self.dirty = false
end

function UiConsole:draw()
   self._renderer:draw()

   if self.dirty then
      Draw.with_canvas(self.canvas, function() self:_redraw() end)
   end
   Draw.set_color(255, 255, 255)
   Draw.image(self.canvas, self.x, self.y)
end

function UiConsole:update(dt)
   self._renderer:update(dt)
end

return UiConsole
