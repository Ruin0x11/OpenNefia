local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local CircularBuffer = require("api.CircularBuffer")

local LogWidget = class.class("LogWidget", IUiWidget)

function LogWidget:init()
   self.max_lines = 10
   self.padding = 10
   self.buffer = CircularBuffer:new(self.max_lines)
   self.show_source = true

   self.message_duration = 10.0
   self.fade_duration = 3.0
end

function LogWidget:default_widget_position(x, y, width, height)
   return 0, y, math.floor(width / 2), math.floor(height / 2)
end

function LogWidget:relayout(x, y, width, height)
   Draw.set_font(12)
   local max_lines = math.floor((height - self.padding * 2) / Draw.text_height())
   if self.max_lines ~= max_lines then
      self.max_lines = max_lines
      self.buffer = CircularBuffer:new(self.max_lines)
   end
   self.width = width + self.padding * 2
   self.height = height
   self.x = x
   self.y = math.floor(Draw.get_height() / 2) - math.floor(self.height / 2)
end

local function cut_string(str, width)
   local remain, wrapped = Draw.wrap_text(str, width)
   return wrapped[1]
end

local COLORS = {
   trace = { 185, 155, 215 },
   debug = { 155, 154, 153 },
   info  = { 255, 255, 255 },
   warn  = { 255, 255, 175 },
   error = { 255, 155, 155 }
}

local shadow_color = {0, 0, 0, 255}

function LogWidget:print(level, message)
   local formatted = ("[%s] %s"):format(level, message)
   formatted = cut_string(formatted, self.width)
   local text = Draw.make_text(formatted)
   self.buffer:push({color=COLORS[level],text=text,time=self.message_duration})
end

function LogWidget:draw()
   Draw.set_font(12)
   -- Draw.filled_rect(self.x, self.y, self.width, self.height, {17, 17, 65, 64})
   local line = 1
   for i=1, self.max_lines do
      local entry = self.buffer:get(i)
      if entry == nil then
         break
      end

      if entry.time >= 0 then
         local alpha = 255
         if entry.time < self.fade_duration then
            --print(entry.time, self.fade_duration)
            alpha = 255 * (1 - (-(-self.fade_duration + entry.time) / self.fade_duration))
         end

         local color = entry.color
         color[4] = alpha
         shadow_color[4] = alpha

         local source = ""
         if self.show_source then
         end
         Draw.text_shadowed(entry.text, self.x + self.padding, self.y + self.padding + (line - 1) * Draw.text_height(), color, shadow_color)
         line = line + 1
      end
   end
end

function LogWidget:update(dt)
   for i=1, self.max_lines do
      local entry = self.buffer:get(i)
      if entry == nil then
         break
      end

      if entry.time >= 0 then
         entry.time = entry.time - dt
      end
   end
end

return LogWidget
