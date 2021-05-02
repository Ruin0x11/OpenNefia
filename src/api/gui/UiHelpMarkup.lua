local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local ISettable = require("api.gui.ISettable")
local UiTheme = require("api.gui.UiTheme")

local UiHelpMarkup = class.class("UiHelpMarkup", {IUiElement, ISettable})

function UiHelpMarkup:init(text, font_size, shadow, color)
   self.shadow = shadow
   self.color = color

   self.text = ""
   self.parsed = {}
   self.dirty = true

   self:set_data(text)
end

function UiHelpMarkup:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
   self.dirty = true
end

function UiHelpMarkup:set_data(str)
   assert(type(str) == "string")
   self.text = str
   self.dirty = true
end

function UiHelpMarkup:set_color(color)
   self.color = color
   self.dirty = true
end

function UiHelpMarkup:set_shadow(shadow)
   self.shadow = shadow
   self.dirty = true
end

local ENDINGS = table.set {"。", "、", "」", "』", "！", "？", "…"}
local TAGS = {
   emp1   = { font_style = "underline", color = {50, 50, 255} },
   emp2   = { font_style = "bold", color = {40, 130, 40} },
   title1 = { font_delta = -2, font_style = "bold", color = {100, 50, 50} },
   def    = { font_delta = 0, font_style = "none", color = "base" },
   p      = { y_delta = 24, reset_x = true },
   br     = { y_delta = 16, reset_x = true },
   b      = { font_style = "bold" },
   green  = { color = {20, 120, 20} },
   red    = { color = {120, 20, 20} },
   col    = { color = "base" }
}

function UiHelpMarkup.parse_elona_markup(text, width, color, font_size)
   color = color or {0, 0, 0}
   font_size = font_size or 14 -- 14 - en * 2

   local last_x = 0
   local last_y = 0
   local x = 0
   local y = 0
   local i = 1
   local base_color = color
   local base_font_size = font_size
   local font_style = nil
   local current_text = ""
   local result = {}

   local function push_result(nx, ny)
      if current_text ~= "" then
         Draw.set_font(font_size, font_style)
         result[#result+1] = {
            text = Draw.make_text(current_text),
            x = last_x,
            y = last_y,
            font_style = font_style,
            font_size = font_size,
            color = color
         }
      end
      current_text = ""
      last_x = nx
      last_y = ny
   end

   Draw.set_font(font_size)

   local c = utf8.sub(text, i, i)

   while c ~= "" do
      local wait_to_break_line = false
      local append = true

      if ENDINGS[c] then
         wait_to_break_line = true
      elseif c == "<" then
         -- Parse a markup tag. (This isn't HTML.)
         push_result(x, y)
         append = false

         -- `i` is a UTF-8 codepoint position, and we translate to byte position.
         local byte = utf8.offset(text,i)

         -- This is a byte position.
         local close_index = string.find(text, ">", byte)
         if close_index == nil then
            return nil, ("missing '>' to close '<' at position %d"):format(i)
         end

         local tag_name = string.sub(text, byte+1, close_index-1)
         local tag = TAGS[tag_name]
         if tag ~= nil then
            if tag.color then
               if tag.color == "base" then
                  color = base_color
               else
                  color = tag.color
               end
            end
            if tag.y_delta then
               y = y + tag.y_delta
            end
            if tag.reset_x then
               current_text = current_text .. "\n"
               x = 0
            end
            if tag.font_delta then
               font_size = base_font_size + tag.font_delta
            end
            if tag.font_style then
               if tag.font_style == "none" then
                  font_style = nil
               else
                  font_style = tag.font_style
               end
            end

            -- Set font to ensure text width calculation stays accurate
            Draw.set_font(font_size)
         end

         -- Convert from byte position to UTF-8 codepoint position
         i = utf8.codepoint_pos(text, close_index)
      elseif c == "^" then
         -- Treat the next character literally.
         i = i + 1
         c = utf8.sub(text, i, i)
      elseif c == "\r" then
         append = false
      elseif c == "\n" then
         append = false
         x = 0
         y = y + Draw.text_height() + 2
         push_result(x, y)
      end

      if append then
         current_text = current_text .. c
         if not wait_to_break_line and x > width then
            x = 0
            y = y + Draw.text_height() + 2
            push_result(x, y)
         end

         x = x + Draw.text_width(c)
      end

      i = i + 1
      c = utf8.sub(text, i, i)
   end

   push_result(x, y)

   return result
end

function UiHelpMarkup.draw_elona_markup(markup, x, y, shadow_color)
   for _, item in ipairs(markup) do
      Draw.set_font(item.font_size, item.font_style)
      if shadow_color then
         Draw.text(item.text, x + item.x + 1, y + item.y + 1, shadow_color)
      end
      Draw.set_color(item.color)
      Draw.text(item.text, x + item.x, y + item.y)
   end
end

function UiHelpMarkup:draw()
   if self.dirty then
      self.parsed = UiHelpMarkup.parse_elona_markup(self.text, self.width, self.color, self.font_size)
      self.dirty = false
   end
   local shadow_color
   if self.shadow then
      shadow_color = self.t.elona.help_markup_text_shadow_color
   end
   UiHelpMarkup.draw_elona_markup(self.parsed, self.x, self.y, shadow_color)
end

function UiHelpMarkup:update(dt)
end

return UiHelpMarkup
