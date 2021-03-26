local Draw = require("api.Draw")
local IUiConsoleRenderer = require("mod.ui_console.api.gui.IUiConsoleRenderer")
local ConsoleConsts = require("mod.ui_console.api.gui.ConsoleConsts")

local DefaultConsoleRenderer = class.class("DefaultConsoleRenderer", IUiConsoleRenderer)

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

function DefaultConsoleRenderer:init()
   self.default_bg = 3
end

function DefaultConsoleRenderer:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
end

function DefaultConsoleRenderer:set_font_size(font_size)
   self.font_size = font_size

   Draw.set_font(self.font_size)
   self.char_width = Draw.text_width(" ") + 1
   self.char_height = Draw.text_height() + 1
   self.width_chars = math.floor(self.width / self.char_width)
   self.height_chars = math.floor(self.height / self.char_height)

   return self.width_chars, self.height_chars
end

function DefaultConsoleRenderer:render_chars(buffer, tiles_dirty)
   local cw = self.char_width
   local ch = self.char_height
   local w = self.width_chars
   local h = self.height_chars

   local ATTR_CURSOR = ConsoleConsts.ATTR.CURSOR

   local bg = self.default_bg
   local function draw_bg(i)
      local x = (i-1) % w
      local y = math.floor((i-1) / w)
      local sx = x * cw
      local sy = y * ch

      local t = buffer[i]
      local tbg = t.bg
      if bit.band(t.attr, ATTR_CURSOR) > 0 then
         tbg = t.fg
      end
      if bg ~= tbg then
         Draw.set_color(PALETTE[tbg])
         bg = tbg
      end
      Draw.filled_rect(sx, sy, cw, ch)
   end

   if tiles_dirty == nil then
      Draw.clear(PALETTE[bg])
      Draw.set_color(PALETTE[bg])
      for i = 1, w * h do
         draw_bg(i)
      end
   else
      Draw.set_color(PALETTE[bg])
      for _, i in ipairs(tiles_dirty) do
         draw_bg(i)
      end
   end

   local fg
   local function draw_fg(i)
      local x = (i-1) % w
      local y = math.floor((i-1) / w)
      local sx = x * cw
      local sy = y * ch

      local t = buffer[i]
      local tfg = t.fg
      if bit.band(t.attr, ATTR_CURSOR) > 0 then
         tfg = t.bg
      end
      if fg ~= tfg then
         Draw.set_color(PALETTE[tfg])
         fg = tfg
      end
      Draw.text(t.ch, sx, sy)
   end

   Draw.set_font(self.font_size)

   if tiles_dirty == nil then
      for i = 1, w * h do
         draw_fg(i)
      end
   else
      for _, i in ipairs(tiles_dirty) do
         draw_fg(i)
      end
   end
end

function DefaultConsoleRenderer:draw()
end

function DefaultConsoleRenderer:update()
end

return DefaultConsoleRenderer
