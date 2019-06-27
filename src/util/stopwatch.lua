local socket = require("socket")

local stopwatch = {}

function stopwatch:new()
   local o = setmetatable({}, { __index = stopwatch })
   o:init()
   return o
end

function stopwatch:init()
   self.time = socket.gettime()
   self.framerate = 60
end

function stopwatch:measure()
   local new = socket.gettime()
   local result = new - self.time
   self.time = new
   return result * 1000
end

local function msecs_to_frames(msecs, framerate)
   local msecs_per_frame = (1 / framerate) * 1000
   local frames = msecs / msecs_per_frame
   return frames
end

function stopwatch:p(text)
   if text then
      text = string.format("[%s]", text)
   else
      text = ""
   end

   local msecs = self:measure()
   print(string.format("%s %02.02fms (%02.02f frames)",
                       text,
                       msecs,
                       msecs_to_frames(msecs, self.framerate)))
end

return stopwatch
