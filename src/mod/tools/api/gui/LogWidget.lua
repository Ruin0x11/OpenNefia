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
   return 0, y, math.floor(width / 2), math.floor(height / 3)
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

local COLORS = {
   trace = { 185, 155, 215 },
   debug = { 155, 154, 153 },
   info  = { 255, 255, 255 },
   warn  = { 255, 255, 175 },
   error = { 255, 155, 155 }
}

local shadow_color = {0, 0, 0, 255}

function LogWidget:print(level, message, source)
   Draw.set_font(12)
   local formatted = ("[%s][%s] %s"):format(level, source or "?", message)
   local success, err, wrapped = xpcall(function() return Draw.wrap_text(formatted, self.width) end, debug.traceback)
   if success then
      for _, line in ipairs(wrapped) do
         local text = Draw.make_text(line)
         self.buffer:push({color=COLORS[level],text=text,time=self.message_duration})
      end
   else
      local text = Draw.make_text(formatted)
      self.buffer:push({color=COLORS[level],text=text,time=self.message_duration})
   end
end

function LogWidget:draw()
   -- Draw.filled_rect(self.x, self.y, self.width, self.height, {17, 17, 65, 64})
   local line = 1
   for i=-self.buffer:len(), 0 do
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
