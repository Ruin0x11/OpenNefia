local Draw = require("api.Draw")
local IUiWidget = require("api.gui.IUiWidget")
local DebugStatsHook = require("mod.tools.api.debug.DebugStatsHook")

local DebugStatsWidget = class.class("DebugStatsWidget", IUiWidget)

function DebugStatsWidget:init()
   self.max_lines = 10
   self.padding = 10
   self.texts = {}
end

function DebugStatsWidget:default_widget_position(x, y, width, height)
   return 300, 150, math.floor(width / 2), math.floor(height / 4)
end

function DebugStatsWidget:default_widget_z_order()
   return 100000000
end

function DebugStatsWidget:relayout(x, y, width, height)
   Draw.set_font(12)

   local max_lines = math.floor((height - self.padding * 2) / Draw.text_height())
   self.max_lines = max_lines

   self.width = width + self.padding * 2
   self.height = height
   self.x = x
   self.y = y or math.floor(Draw.get_height() / 2)
end

function DebugStatsWidget:draw()
   Draw.set_font(12)
   local x = self.x + self.padding
   local y = self.y + self.padding
   local text_h = Draw.text_height()

   for _, text in ipairs(self.texts) do
      Draw.text_shadowed(text, x, y)
      y = y + text_h
   end
end

function DebugStatsWidget:update(dt, map, screen_updated)
   table.clear(self.texts)
   local results = DebugStatsHook.get_results()

   Draw.set_font(12)
   local texts = {}
   for api_path, recordings in pairs(results) do
      for fn_name, rec in pairs(recordings) do
         texts[#texts+1] = {
            ("%s:%s:"):format(api_path, fn_name),
            ("%dh"):format(rec.hits),
            ("%02.02fms"):format(rec.time),
            ("%02.02fKBs"):format(rec.mem),
            ("%02.02fms/h"):format(rec.time / rec.hits),
            ("%02.02fKBs/h"):format(rec.mem / rec.mem_hits)
         }
      end
   end

   self.texts = table.print(texts)
end

return DebugStatsWidget
