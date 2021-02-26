local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")
local IUiWidget = require("api.gui.IUiWidget")
local CircularBuffer = require("api.CircularBuffer")
local save = require("internal.global.save")
local config = require("internal.config")

local UiMessageWindow = class.class("UiMessageWindow", IUiWidget)

function UiMessageWindow:init()
   self.width = 800
   self.height = 72

   self.max_log = 200
   self.history = CircularBuffer:new(self.max_log)
   self.max_lines = 4
   self.each_line = CircularBuffer:new(self.max_lines)

   self.y_offset = 0
   self.current_width = 0
   self.padding = 0
   self.canvas = nil
   self.redraw = true
   self.is_new_turn = true
   self.checking_for_duplicate = false
   self.previous_text = nil

   self:recalc_lines()
end

function UiMessageWindow:default_widget_position(x, y, width, height)
   return x + 124, height - (72 + 16), width - 124, 72
end

function UiMessageWindow:default_widget_z_order()
   return 50000
end

function UiMessageWindow:relayout(x, y, width, height)
   if self.canvas == nil or width ~= self.width or height ~= self.height then
      self.canvas = Draw.create_canvas(width, height)
      self.redraw = true
   end

   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
   self.cutoff = { text = "" }
   self.first_index = 1
   self.the_width = 0

   Draw.set_font(14)
   self.padding = Draw.text_width(" ")
   self.max_lines = math.floor(self.height / Draw.text_height()) - 1
   self.y_offset = -(self.height % Draw.text_height())
   self.each_line = CircularBuffer:new(self.max_lines)

   self.i_message_window = self.t.base.message_window:make_instance()

   self:recalc_lines()
end

function UiMessageWindow:draw_one_text(text, color, x, y)
   local max_width, wrapped = Draw.wrap_text(text, self.width - self.padding - self.the_width)
   Draw.text(wrapped[1], x, y)
   self.the_width = self.the_width + Draw.text_width(wrapped[1])
   x = self.the_width

   if #wrapped > 1 then
      local rest = string.strip_prefix(text, wrapped[1])
      self.the_width = 0
      max_width, wrapped = Draw.wrap_text(rest, self.width - self.padding - self.the_width)
      for i=1,#wrapped do
         x = 0
         y = y + Draw.text_height()
         Draw.text(wrapped[i], x, y)
         self.the_width = self.the_width + Draw.text_width(wrapped[1])
         x = self.the_width
      end
   end

   return x, y
end

function UiMessageWindow:push_text(text, color)
   -- NOTE: The global font has to be set now for the text width
   -- calculation to be correct.
   Draw.set_font(14) -- 14 - en * 2
   color = color or {255, 255, 255}

   if self.each_line:len() == 0 then
      self:newline()
   end

   local first = self.each_line:get(1)
   local work = ""

   -- HACK: love2d's text wrapping doesn't work with CJK, because it
   -- uses the last position of an ASCII halfwidth character to do
   -- wrapping. But this solution is really inefficient...
   for _, s in utf8.chars(text) do
      -- TODO: handle halfwidth text wrapping (English)
      local width = Draw.text_width(s)
      if first.width + width > self.width - self.padding then
         first.text[#first.text+1] = {color = color, text = work, width = first.width}
         self:newline()
         first = self.each_line:get(1)
         work = ""
      end

      work = work .. s
      first.width = first.width + width
   end

   first.text[#first.text+1] = {color = color, text = work, width = Draw.text_width(work)}
end

function UiMessageWindow:draw_one_line(x, y, line)
   for _, item in ipairs(line.text) do
      -- love.graphics.print() accepts arguments like
      --   {color, text, color, text...}
      Draw.set_color(item.color or {255, 255, 255})
      Draw.text(item.text, x, y)
      x = x + item.width
   end
end

-- Find the index of the first text fragment that will fully appear in
-- the message window and the partially wrapped text of the text
-- fragment before it.
--
-- /This line is off-screen. Previous  \
-- +-----|-----------------|-----------+
-- |text.|This is the text.|Other text.|
-- +-----|-----------------|-----------+
--  ^^^^^|^^^^^^^^^^^^^^^^^|
--    \              \
--     \____cutoff    \______index_of_first_text
--
--
-- BUG: This will not respect newlines, so the minute prefix ([10])
-- will not display properly if the window is resized.
function UiMessageWindow:calc_start_offset()
   -- NOTE: The global font has to be set now for the text width
   -- calculation to be correct.
   Draw.set_font(14)

   local width_remain = self.width - self.padding
   local lines = 0
   local cutoff = ""
   local index_of_first_text = self.history:len()
   local found

   -- start from the most recent text fragment and wrap text backwards
   -- (bottom of message window to top) until the wrapped line
   -- overflows into the offscreen portion of the message window. The
   -- overflowed text that can fit into the visible message window
   -- area is the text to print at the beginning of the message
   -- window.
   for i=1,self.history:len() do
      local t = self.history:get(i)
      local text = t.text
      cutoff = text

      if t.newline then
         lines = lines + 1
         found = text
         width_remain = self.width - self.padding
         if lines > 3 then
            index_of_first_text = i
            cutoff = found
            break
         end
      else
         local tw = Draw.text_width(text)
         while tw > width_remain do
            -- Amount of width (in pixels) the text goes over by.
            local diff = tw - width_remain

            width_remain = self.width - self.padding - tw

            local max_width, wrapped = Draw.wrap_text(t.text, diff)

            -- Text that fit in the previous line before wrapping.
            local first = wrapped[1]

            -- The text that overflowed into the next line.
            local rest = wrapped[2]

            lines = lines + 1
            text = first
            found = rest
            tw = Draw.text_width(text)
            if lines > 3 then
               break
            end
         end
         width_remain = width_remain - tw
         if lines > 3 then
            index_of_first_text = i
            cutoff = found
            break
         end
      end
   end

   return cutoff, index_of_first_text
end

function UiMessageWindow:recalc_lines()
   if self.history:len() == 0 then
      return
   end

   local cutoff, index_of_first_text = self:calc_start_offset()

   self.each_line = CircularBuffer:new(self.max_lines)

   for i=index_of_first_text,1,-1 do
      local t = self.history:get(i)
      if t.newline then
         self:newline()
      else
         self:push_text(t.text, t.color)
      end
   end
end

function UiMessageWindow:prevent_next_duplicate()
   self.checking_for_duplicate = true
end

function UiMessageWindow:clear()
   self.history = CircularBuffer:new(self.max_log)
   self.each_line = CircularBuffer:new(self.max_lines)
   self.redraw = true
end

function UiMessageWindow:redraw_window()
   Draw.clear(0, 0, 0)
   Draw.set_color(255, 255, 255)

   -- TODO asset_drawable:get_region_viewport("body")
   local _, _, _, window_height = self.i_message_window.quads["body"]:getViewport()
   self.i_message_window:draw_bar(0, 0, self.width)
   for i = 2, math.ceil(self.height / window_height) do
      self.i_message_window:draw_bar(0, (i - 1) * window_height, self.width, "body")
   end

   self.the_width = 0

   Draw.set_font(14) -- 14 - en * 2
   local x = 6
   local y = 5 + (self.each_line:len() - 1) * Draw.text_height()
   for i=1,self.each_line:len() do
      local line = self.each_line:get(i)
      self:draw_one_line(x, y, line)
      y = y - Draw.text_height()
   end
end

function UiMessageWindow:do_newline()
   local first = self.history:get(-2)
   if first and first.newline then
      return
   end
   self.history:push({ newline = true, text = "", color = {255, 255, 255} })
   self:newline()
end

function UiMessageWindow:newline(text)
   text = text or ""

   Draw.set_font(14)
   self.add_width = 2
   local width = Draw.text_width(text)
   self.each_line:push({text = {{color = {255, 255, 255}, text = text, width = width}}, width = width})
end

function UiMessageWindow:new_turn()
   self.is_new_turn = true
end

function UiMessageWindow:message(text, color)
   if color and not (color[1] and color[2] and color[3]) then
      error(("Invalid color '%s'"):format(inspect(color)))
   end

   text = tostring(text)

   if self.checking_for_duplicate then
      self.checking_for_duplicate = false
      if text == self.previous_text then
         return
      end
   end

   self.previous_text = text

   if self.is_new_turn then
      self.is_new_turn = false
      if config.base.add_timestamps then
         local minute = save.base.date.minute
         text = string.format("[%d] %s", minute, text)
      else
         text = string.format("  %s", text)
      end
      self:do_newline()
   end

   self.history:push({text = text, color = color})
   self:push_text(text, color)
   self.redraw = true
end

function UiMessageWindow:draw()
   if self.redraw then
      Draw.with_canvas(self.canvas, function() self:redraw_window() end)
      self.redraw = false
   end

   Draw.set_color(255, 255, 255)
   Draw.image(self.canvas, self.x, self.y)
end

function UiMessageWindow:update(dt)
end

return UiMessageWindow
