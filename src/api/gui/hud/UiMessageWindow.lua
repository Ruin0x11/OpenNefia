local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")
local circular_buffer = require("thirdparty.circular_buffer")

local UiMessageWindow = class("UiMessageWindow", IUiElement)

function UiMessageWindow:init()
   local history = {
      { color = {100, 42, 200}, text = "I am testinger nanodesu" },
      { icon = "heart" },
      { icon = "note" },
      {text = "dood"},
      {text = " doods"},
      {text = " doodity"},
   }
   history = table.merge(history, table.of(function(i) return {text="あいうえおかきくけこさしすせそたちつてと" .. tostring(i) .. " "} end, 300), true)

   self.max_log = 200
   self.history = circular_buffer:new(self.max_log)
   for _, v in ipairs(history) do
      self.history:push(v)
   end

   self.current_width = 0
   self.canvas = nil
   self.redraw = true
end

function UiMessageWindow:relayout(x, y, width, height)
   if self.canvas == nil or width ~= self.width or height ~= self.height then
      self.canvas = love.graphics.newCanvas(width, height)
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
end

function UiMessageWindow:calc_start_offset()
   local width_remain = self.width
   local lines = 0
   local cutoff
   local index_of_next_text
   local found

   -- start from the most recent text fragment and wrap text backwards
   -- until the wrapped line overflows the start of the text box. The
   -- second part of the overflow is the text to print at the
   -- beginning of the message window.
   for i=1,self.history:len() do
      local t = self.history[i]
      local text = t.text
      cutoff = text
      local tw = Draw.text_width(text)
      while tw > width_remain do
         local diff = tw - width_remain
         width_remain = self.width - tw
         local max_width, wrapped = Draw.wrap_text(t.text, diff)
         local first = wrapped[1]
         local rest = wrapped[2]
         _p("wrap",t.text,wrapped)
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
         index_of_next_text = i
         cutoff = found
         _p("get",index_of_next_text, cutoff)
         break
      end
   end

   return cutoff, index_of_next_text
end

function UiMessageWindow:draw_one_text(text, color, x, y)
   local max_width, wrapped = Draw.wrap_text(text, self.width - self.the_width)
   _p(text, max_width, wrapped)
   Draw.text(wrapped[1], x, y)
   self.the_width = self.the_width + Draw.text_width(wrapped[1])
   x = self.the_width
   local width_remain = self.width - self.the_width

   if #wrapped > 1 then
      local rest = string.strip_prefix(text, wrapped[1])
      self.the_width = 0
      max_width, wrapped = Draw.wrap_text(rest, self.width - self.the_width)
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

function UiMessageWindow:draw()
   Draw.set_color(255, 255, 255)

   Draw.image(self.canvas, self.x, self.y)
   if not self.redraw then
      return
   end

   local cutoff, index_of_next_text = self:calc_start_offset()

   love.graphics.setCanvas(self.canvas)
   love.graphics.clear()
   love.graphics.setBlendMode("alpha")

   self.t.message_window:draw_bar(0, 0, self.width)

   self.the_width = 0

   Draw.set_font(14) -- 14 - en * 2
   local x = 0
   local y = 5
   x, y = self:draw_one_text(cutoff, {255, 255, 255}, x, y)
   print(index_of_next_text,cutoff)
   for i=-index_of_next_text,-1-1 do
      local t = self.history[i]
      print(i,t.text)
      x, y = self:draw_one_text(t.text, t.color, x, y)
   end

   love.graphics.setCanvas()

   self.redraw = false
end

function UiMessageWindow:newline()
   self.current_width = 0
end

function UiMessageWindow:message(text, color)
   text = tostring(text)

   local new_turn = false
   if new_turn then
   end
   local add_timestamps = true
   if add_timestamps then
      local minute = require("game.field").data.date.minute
      text = string.format("[%d] %s", minute, text)
   else
      self.current_width = 2
   end

   self.history:push({text = text, color = color})
   self.redraw = true
end

function UiMessageWindow:update()
end

return UiMessageWindow
