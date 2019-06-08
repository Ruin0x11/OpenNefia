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
   history = table.merge(history, table.of({text="doodsあ"}, 300), true)

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
end

function UiMessageWindow:draw()
   Draw.set_color(255, 255, 255)

   if not self.redraw then
      Draw.image(self.canvas, self.x, self.y)
      return
   end

   love.graphics.setCanvas(self.canvas)
   love.graphics.clear()
   love.graphics.setBlendMode("alpha")

   self.t.message_window:draw_bar(0, 0, self.width)

   local width = 0
   local x = 0
   local y = 0
   for i=1,self.history:len() do
      local width_remain = self.width - width
      local t = self.history[i]
      print("line " .. t.text)
      local text = {}
      local work = t.text
      local max_width, wrapped = Draw.wrap_text(t.text, width_remain)
      Draw.text(wrapped[1], x, y)
      width = width + Draw.text_width(wrapped[1])
      x = width
      if #wrapped > 1 and wrapped[2] ~= "\n" then
         for i=2,#wrapped do
            x = 0
            y = y + Draw.text_height()
            Draw.text(wrapped[i], x, y)
            width = width + Draw.text_width(wrapped[1])
            x = width
         end
      end
   end

   love.graphics.setCanvas()

   self.redraw = false

   Draw.set_color(255, 255, 255)
   Draw.image(self.canvas, self.x, self.y)
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

   -- HACK
   table.insert(self.history, 1, text)
end

function UiMessageWindow:update()
end

return UiMessageWindow
