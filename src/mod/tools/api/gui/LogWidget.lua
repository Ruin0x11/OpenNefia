local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local CircularBuffer = require("api.CircularBuffer")

local LogWidget = class.class("LogWidget", IUiWidget)

function LogWidget:init(message_duration, fade_duration)
   self.max_lines = 10
   self.padding = 10
   self.buffer = CircularBuffer:new(self.max_lines)
   self.show_source = true

   self.message_duration = message_duration or 10.0
   self.fade_duration = fade_duration or 3.0
end

function LogWidget:default_widget_position(x, y, width, height)
   return 0, math.floor(height / 2), math.floor(width / 2), math.floor(height / 4)
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
   self.y = y or math.floor(Draw.get_height() / 2)
end

-- TODO theme
local COLORS = {
   trace = { 185, 155, 215 },
   debug = { 155, 154, 153 },
   info  = { 255, 255, 255 },
   warn  = { 255, 255, 175 },
   error = { 255, 155, 155 }
}

local shadow_color = {0, 0, 0, 255}

function LogWidget:print(level, message, source, color)
   color = color or COLORS[level]

   local formatted = ("[%s][%s] %s"):format(level:sub(1, 1):upper(), source or "?", message)
   self:print_raw(formatted, color)
end

function LogWidget:print_raw(str, color)
   color = color or COLORS["info"]

   Draw.set_font(12)
   local success, err, wrapped = xpcall(function() return Draw.wrap_text(str, self.width) end, debug.traceback)
   if success then
      for _, line in ipairs(wrapped) do
         local text = Draw.make_text(line)
         self.buffer:push({color=color,text=text,time=self.message_duration})
      end
   else
      local text = Draw.make_text(str)
      self.buffer:push({color=color,text=text,time=self.message_duration})
   end
end

function LogWidget:draw()
   -- Draw.filled_rect(self.x, self.y, self.width, self.height, {17, 17, 65, 64})
   Draw.set_font(12)
   local line = 1
   for i=-self.buffer:len(), -2 do
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
