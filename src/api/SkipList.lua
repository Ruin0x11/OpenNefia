-- Modified from https://github.com/markandgo/skip-list.

--[[
   zlib License:

   Copyright (c) 2014 Minh Ngo

   This software is provided 'as-is', without any express or implied
   warranty. In no event will the authors be held liable for any damages
   arising from the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
--]]

local min,floor,log,random = math.min,math.floor,math.log,math.random

local function logb(n,base)
   return log(n) / log(base)
end

-- Probability that a node appears in a higher level
local p = 0.5

local SkipList = class.class("SkipList")

function SkipList:clear()
   self.head   = {}
   self._levels= 1
   self._count = 0
   self._size  = 2^self._levels
end

-- comp: < or > (Duplicate keys are inserted at the beginning)
-- comp: <= or >= (Duplicate keys are inserted at the end)
function SkipList:init(initial_size,comp)
   initial_size= initial_size or 100

   local levels= floor( logb(initial_size,1/p) )

   self.head = {}
   self._levels = levels
   self._count = 0
   self._size = 2^levels
   self.comp = comp or function(key1,key2) return key1 <= key2 end
end

function SkipList:length()
   return self._count
end

-- Return the key, value, and node
-- If value is omitted, return any matching key and value
function SkipList:find(key,value)
   local node = self.head
   local comp = self.comp
   -- Start search at the highest level
   for level = self._levels,1,-1 do
      while node[level] do
         local old = node
         node      = node[level]
         local c1  = comp(node.key,key)
         local c2  = not comp(key,node.key)
         --[[
            If both comparisons are true, then move to the next node
            If one of them is true, a matching key was found!
            If both are false, stay on the same node
         ]]
         if c1 ~= c2 then
            -- Search for key-value pair if there is value argument
            if value then
               -- Search "left" and "right" sides for matching value
               local prev = node
               while prev do
                  if prev.key == key and prev.value == value then
                     return prev.key,prev.value,prev
                  end
                  prev = prev[-1]
               end
               local next = node[1]
               while next do
                  if next.key == key and next.value == value then
                     return next.key,next.value,next
                  end
                  next = next[1]
               end
               return
            end
            return node.key,node.value,node
         elseif c1 == false then
            node = old
            break
         end
      end
   end
end

function SkipList:insert(key,value)
   -- http://stackoverflow.com/questions/12067045/random-level-function-in-skip-list
   -- Using a uniform distribution, we find the number of levels
   -- by using the cdf of a geometric distribution
   -- cdf(k)   = 1 - ( 1 - p )^k
   -- levels-1 = log(1-cdf)/log(1-p)
   local levels = floor( log(1-random())/log(1-p) ) + 1
   levels       = min(levels,self._levels)
   local comp   = self.comp

   local new_node = {key = key, value = value}

   local node = self.head
   -- Search for the biggest node <= to our key on each level
   for level = self._levels,1,-1 do
      while node[level] and comp(node[level].key,key) do
         node = node[level]
      end
      -- Connect the nodes to the new node
      if level <= levels then
         new_node[-level] = node
         new_node[level]  = node[level]
         node[level]      = new_node
         if new_node[level] then
            local next_node   = new_node[level]
            next_node[-level] = new_node
         end
      end
   end

   -- Increment counter and dynamically increase the size
   -- of the skip list if necessary
   self._count = self._count + 1
   if self._count > self._size then
      self._levels = self._levels + 1
      self._size   = self._size*2
   end
end

function SkipList:_delete(node)
   local level = 1
   while node[-level] do
      local next = node[level]
      local prev = node[-level]
      prev[level]= next
      if next then next[-level] = prev end
      level = level + 1
   end
   self._count = self._count - 1
end

-- Return the key,value if successful
-- If value is omitted, delete any matching key
function SkipList:delete(key,value)
   local k,v,node = self:find(key,value)
   if not node then return end
   self:_delete(node)
   return k,v
end

-- Return the first key,value
function SkipList:pop()
   local node  = self.head[1]
   if not node then return end
   self:_delete(node)
   return node.key,node.value
end

-- Check but do not remove the first key,value
function SkipList:peek()
   local node = self.head[1]
   if not node then return end
   return node.key,node.value
end

-- Iterate in order or reverse
-- Return the key,value
function SkipList:iterate(mode)
   mode = mode or 'normal'
   if not (mode == 'normal' or mode == 'reverse') then
      error('Invalid mode')
   end

   local node,incr = self.head[1],1

   if mode == 'reverse' then
      -- Search for the node at the end
      for level = self._levels,1,-1 do
         while node[level] do
            node = node[level]
         end
      end
      incr = -1
   end

   local function iter(state, node)
      if node == nil or node == "stop" then
         return nil
      end
      local next_node = node[state.incr]
      if next_node == nil then
         local k,v= node.key,node.value
         -- Move to the next node
         return "stop", k, v
      else
         local k,v= node.key,node.value
         -- Move to the next node
         return next_node, k, v
      end
   end

   return iter, {incr=incr}, node
end

-- Check the integrity of the skip list
-- Return true if it passes else error!
function SkipList:check()
   local level = 0
   local comp  = self.comp
   while self.head[level+1] do
      level      = level + 1
      local prev = self.head
      local node = self.head[level]
      while node do
         if prev ~= node[-level] then
            local template = 'Node with key %d at level %d has invalid back reference!'
            error( template:format(node.key,level) )
         end
         if node[level] then
            local next_node= node[level]
            local c1       = comp(node.key,next_node.key)
            local c2       = not comp(next_node.key,node.key)
            if not (c1 or c2) then
               local template = 'Skip list is out of order on level %d: key %s is before %s!'
               error(template:format(level,tostring(node.key),tostring(node[level].key)))
            end
            if next_node == node then
               error('Node self reference!')
            end
         end

         -- If the node has a link at this level, it must also have a
         -- link at the lower level
         if level > 1 then
            for direction = -1,1,2 do
               if node[direction*level] and not node[direction*(level-1)] then
                  error(string.format('Missing node link at level %d',level-1))
               end
            end
         end

         prev = node
         node = node[level]
      end
   end
   do
      local template = 'Node level %d exceeds maximum: %d'
      assert(level <= self._levels,template:format(#self.head,self._levels))
   end
   return true
end

return SkipList
