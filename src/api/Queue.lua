local Queue = class.class("Queue")

function Queue:init()
   self._ordered = {}
   self._buffer = {}
end

function Queue:push(obj)
   self._buffer[#self._buffer+1] = obj
end

function Queue:pop()
   while #self._buffer > 0 do
      self._ordered[#self._ordered+1] = self._buffer[#self._buffer]
      self._buffer[#self._buffer] = nil
   end

   local obj = self._ordered[#self._ordered]
   self._ordered[#self._ordered] = nil
   return obj
end

function Queue:clear()
   self._ordered = {}
   self._buffer = {}
end

function Queue:len()
   return #self._ordered + #self._buffer
end

return Queue
