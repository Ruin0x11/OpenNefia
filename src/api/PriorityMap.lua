local PriorityMap = class.class("PriorityMap")

PriorityMap.DEFAULT_PRIORITY = 100000

function PriorityMap:init()
   self.map = {}
   self.priority = {}
   self.sorted_keys = {}
end

local function iter(state, index)
   local key = state.sorted_keys[index]
   if key == nil then
      return nil
   end
   return index + 1, state.map[key], key
end

function PriorityMap:iter()
   return iter, self, 1
end

function PriorityMap:len()
   return #self.sorted_keys
end

function PriorityMap:set(key, value, priority)
   if value == nil then
      self.map[key] = nil
      self.priority[key] = nil
   else
      self.map[key] = value
      self.priority[key] = priority or PriorityMap.DEFAULT_PRIORITY
   end
   self:_update_sorting()
end

function PriorityMap:get(key)
   return self.map[key]
end

function PriorityMap:_update_sorting()
   self.sorted_keys = table.keys(self.map)
   table.sort(self.sorted_keys, function(a, b) return self.priority[a] < self.priority[b] end)
end

return PriorityMap