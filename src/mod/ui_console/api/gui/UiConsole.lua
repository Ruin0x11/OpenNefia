local IUiElement = require("api.gui.IUiElement")
local Draw = require("api.Draw")

local UiConsole = class.class("UiConsole", IUiElement)

local COLOR_FG = 1
local COLOR_BG = 3

local PALETTE = {
   { 197,200,198 },
   { 234,234,234 },
   { 29,31,33 },
   { 0,0,0 },
   { 197,200,198 },
   { 197,200,198 },
   { 29,31,33 },
   { 0,0,0 },
   { 204,102,102 },
   { 213,78,83 },
   { 181,189,104 },
   { 185,202,74 },
   { 240,198,116 },
   { 231,197,71 },
   { 129,162,190 },
   { 122,166,218 },
   { 178,148,187 },
   { 195,151,216 },
   { 138,190,183 },
   { 112,192,177 },
   { 192,200,198 },
   { 234,234,234 },
}

function UiConsole:init(font_size)
   self.font_size = font_size

   self.width_chars = 0
   self.height_chars = 0
   self.canvas = nil
   self.dirty = "all"
   self.buffer = nil
   self.color_buffer = nil
   self.colors = {}
   self.tiles_dirty = {}
end

function UiConsole:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   Draw.set_font(self.font_size)
   self.char_width = Draw.text_width(" ") + 1
   self.char_height = Draw.text_height() + 1
   local width_chars = math.floor(self.width / self.char_width)
   local height_chars = math.floor(self.height / self.char_height)

   if self.width_chars ~= width_chars
      or self.height_chars ~= height_chars
   then
      self:resize(width_chars, height_chars)
   end

   self.canvas = Draw.create_canvas(self.width, self.height)
   self.dirty = "all"
end

function UiConsole:ensure_in_bounds(x, y)
   if x < 0 or y < 0 or x >= self.width_chars or y >= self.height_chars then
      error(("Position out of bounds: %d/%d"):format(x, y))
   end
   return self.width_chars * y + x + 1
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

function UiConsole:set_char(x, y, ch)
   local ind = self:ensure_in_bounds(x, y)
   assert(type(ch) == "string")
   ch = utf8.wide_sub(ch, 0, 1)
   self.buffer[ind].ch = ch
   self.buffer[ind].wide = utf8.wide_len(ch) == 2
   self.tiles_dirty[#self.tiles_dirty+1] = ind
   self.dirty = self.dirty or true
end

function UiConsole:put_char(x, y, ch, fg, bg)
   local ind = self:ensure_in_bounds(x, y)
   assert(type(ch) == "string")
   ch = utf8.wide_sub(ch, 0, 1)
   self.buffer[ind].ch = ch
   self.buffer[ind].wide = utf8.wide_len(ch) == 2
   self.buffer[ind].fg = fg
   self.buffer[ind].bg = bg
   self.tiles_dirty[#self.tiles_dirty+1] = ind
   self.dirty = self.dirty or true
end

function UiConsole:clear()
   self.buffer = {}
   for x = 0, self.width_chars-1 do
      for y = 0, self.height_chars-1 do
         local i = self.width_chars * y + x + 1
         self.buffer[i] = { ch = " ", bg = COLOR_BG, fg = COLOR_FG }
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
   local cw = self.char_width
   local ch = self.char_height
   local w = self.width_chars
   local h = self.height_chars

   local bg = COLOR_BG
   local function draw_bg(i)
      local x = (i-1) % w
      local y = math.floor((i-1) / w)
      local sx = x * cw
      local sy = y * ch

      local t = self.buffer[i]
      if bg ~= t.bg then
         Draw.set_color(PALETTE[t.bg])
         bg = t.bg
      end
      Draw.filled_rect(sx, sy, cw, ch)
   end

   if self.dirty == "all" then
      Draw.clear(PALETTE[bg])
      Draw.set_color(PALETTE[bg])
      for i = 1, w * h do
         draw_bg(i)
      end
   else
      Draw.set_color(PALETTE[bg])
      for _, i in ipairs(self.tiles_dirty) do
         draw_bg(i)
      end
   end

   local fg
   local function draw_fg(i)
      local x = (i-1) % w
      local y = math.floor((i-1) / w)
      local sx = x * cw
      local sy = y * ch

      local t = self.buffer[i]
      if fg ~= t.fg then
         Draw.set_color(PALETTE[t.fg])
         fg = t.fg
      end
      Draw.text(t.ch, sx, sy)
   end

   Draw.set_font(self.font_size)

   if self.dirty == "all" then
      for i = 1, w * h do
         draw_fg(i)
      end
   else
      for _, i in ipairs(self.tiles_dirty) do
         draw_fg(i)
      end
   end

   self.tiles_dirty = {}
   self.dirty = false
end

function UiConsole:draw()
   if self.dirty then
      Draw.with_canvas(self.canvas, function() self:_redraw() end)
   end
   Draw.set_color(255, 255, 255)
   Draw.image(self.canvas, self.x, self.y)
end

function UiConsole:update(dt)
end

return UiConsole
