local queue = class.class("queue")

function queue:init()
   self._ordered = {}
   self._buffer = {}
end

function queue:push(obj)
   self._buffer[#self._buffer+1] = obj
end

function queue:pop()
   while #self._buffer > 0 do
      self._ordered[#self._ordered+1] = self._buffer[#self._buffer]
      self._buffer[#self._buffer] = nil
   end

   local obj = self._ordered[#self._ordered]
   self._ordered[#self._ordered] = nil
   return obj
end

return queue
