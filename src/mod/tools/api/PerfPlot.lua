local Gui = require("api.Gui")
local Log = require("api.Log")
local CircularBuffer = require("api.CircularBuffer")
local Tools = require("mod.tools.api.Tools")
local PlotViewer = require("mod.plot.api.PlotViewer")
local IUiWidget = require("api.gui.IUiWidget")

local PerfPlot = class.class("PerfPlot", IUiWidget)

function PerfPlot:init()
   self.buffer_x = CircularBuffer:new(2)
   self.buffer_fps = CircularBuffer:new(2)
   self.buffer_ram = CircularBuffer:new(2)
   self.buffer_ram_diff = CircularBuffer:new(2)
   self.capturing = false
end

function PerfPlot:default_widget_position(x, y, width, height)
end

function PerfPlot:relayout(x, y, width, height)
end

function PerfPlot:_start(frames)
   frames = frames or 60 * 30
   self.time = 0
   self.buffer_x = CircularBuffer:new(frames)
   self.buffer_fps = CircularBuffer:new(frames)
   self.buffer_ram = CircularBuffer:new(frames)
   self.buffer_ram_diff = CircularBuffer:new(frames)
   self.capturing = true
end

function PerfPlot:_stop()
   self.capturing = false
end

local function to_list(circular_buffer)
   return fun.wrap(circular_buffer:iter()):to_list()
end

function PerfPlot:_show(...)
   local types = table.set {...}
   if select("#", ...) == 0 then
      types = table.set { "fps", "ram", "ram_diff" }
   end

   local plots = {}
   local x = to_list(self.buffer_x)

   if types["fps"] then
      local fps = to_list(self.buffer_fps)
      plots[#plots+1] = x
      plots[#plots+1] = fps
      plots[#plots+1] = ""
   end
   if types["ram"] then
      local ram = to_list(self.buffer_ram)
      plots[#plots+1] = x
      plots[#plots+1] = ram
      plots[#plots+1] = ""
   end
   if types["ram_diff"] then
      local ram_diff = to_list(self.buffer_ram_diff)
      plots[#plots+1] = x
      plots[#plots+1] = ram_diff
      plots[#plots+1] = ""
   end

   PlotViewer.plot(table.unpack(plots))
end

function PerfPlot:draw()
end

function PerfPlot:update(dt)
   if not self.capturing then
      return
   end
   self.time = self.time + dt

   local fps, ram, ram_diff = Tools.performance_stats()
   self.buffer_x:push(self.time)
   self.buffer_fps:push(fps)
   self.buffer_ram:push(ram)
   self.buffer_ram_diff:push(math.max(ram_diff, 0))
end

----------------------------------------

function PerfPlot.widget()
   return Gui.global_widget("tools.perf_plot"):widget()
end

function PerfPlot.start(frames)
   Log.info("Starting performance capture.")
   PerfPlot.widget():_start()
end

function PerfPlot.stop()
   Log.info("Stopping performance capture.")
   PerfPlot.widget():_stop()
end

function PerfPlot.show(...)
   PerfPlot.widget():_show(...)
end

return PerfPlot
