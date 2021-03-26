local Draw = require("api.Draw")
local IUiConsoleRenderer = require("mod.ui_console.api.gui.IUiConsoleRenderer")
local TopicWindow = require("api.gui.TopicWindow")
local ConsoleConsts = require("mod.ui_console.api.gui.ConsoleConsts")

local StyledConsoleRenderer = class.class("StyledConsoleRenderer", IUiConsoleRenderer)

function StyledConsoleRenderer:init()
   self.topic_window = TopicWindow:new(1, 1)
   self.frames = 0
   self.cursor_x = nil
   self.cursor_y = nil
   self.padding = 8
end

function StyledConsoleRenderer:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.topic_window:relayout(self.x - self.padding,
                              self.y - self.padding,
                              self.width + self.padding,
                              self.height + self.padding)
end

function StyledConsoleRenderer:set_font_size(font_size)
   self.font_size = font_size

   Draw.set_font(self.font_size)
   self.char_width = Draw.text_width(" ") + 1
   self.char_height = Draw.text_height() + 1
   self.width_chars = math.floor(self.width / self.char_width)
   self.height_chars = math.floor(self.height / self.char_height)

   return self.width_chars, self.height_chars
end

function StyledConsoleRenderer:render_chars(buffer, tiles_dirty)
   local cw = self.char_width
   local ch = self.char_height
   local w = self.width_chars
   local h = self.height_chars

   self.cursor_x = nil
   self.cursor_y = nil

   local ATTR_CURSOR = ConsoleConsts.ATTR.CURSOR

   local function draw_fg(i)
      local x = (i-1) % w
      local y = math.floor((i-1) / w)
      local sx = x * cw
      local sy = y * ch

      local t = buffer[i]
      if bit.band(t.attr, ATTR_CURSOR) > 0 then
         self.cursor_x = x
         self.cursor_y = y
      end
      Draw.set_color(0, 0, 0, 0)
      Draw.filled_rect(sx, sy, cw, ch)
      if t.ch ~= " " then
         Draw.set_color(0, 0, 0)
         Draw.text(t.ch, sx+1, sy+1)
         Draw.set_color(255, 255, 255)
         Draw.text(t.ch, sx, sy)
      end
   end

   Draw.set_font(self.font_size)
   Draw.set_blend_mode("replace")

   if tiles_dirty == nil then
      for i = 1, w * h do
         draw_fg(i)
      end
   else
      for _, i in ipairs(tiles_dirty) do
         draw_fg(i)
      end
   end

   Draw.set_blend_mode("alpha")
end

function StyledConsoleRenderer:draw()
   self.topic_window:draw()

   if self.cursor_x and self.cursor_y then
      local sx = self.x + self.cursor_x * self.char_width
      local sy = self.y + self.cursor_y * self.char_height
      Draw.set_color(255, 255, 255, 255)
      Draw.line(sx, sy, sx, sy + self.char_height)
   end
end

function StyledConsoleRenderer:update(dt)
   self.frames = self.frames + (dt / (config.base.screen_refresh * (16.66 / 1000)))
   self.caret_alpha = math.sin(self.frames) * 128 + 128

   self.topic_window:update(dt)
end

return StyledConsoleRenderer
