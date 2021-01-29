local EventTree = class.class("EventTree")

function EventTree:init()
   self.dirty = true
   self.cbs = {}
   self.cache = {}
   self.disabled = {}
   self.disabled_inds = {}
   self.name_to_ind = {}
end

function EventTree:serialize()
end

function EventTree:deserialize()
   self:init()
end

function EventTree:count()
   return #self.cbs
end

function EventTree:has_handler(name)
   return self.name_to_ind[name] ~= nil
end

function EventTree:replace(name, cb, priority)
   local ind = self.name_to_ind[name]
   if not (name or ind) then
      error("No such callback with name " .. tostring(name))
      return false
   end

   local found
   for _, v in ipairs(self.cbs) do
      if v.name == name then
         found = v
         break
      end
   end

   assert(found)

   found.priority = priority or found.priority
   found.cb = cb
   if ind ~= -1 then
      self.cache[ind] = cb
   end

   self.dirty = true

   return true
end

function EventTree:insert(priority, cb, name)
   if self.name_to_ind[name] then
      -- Caller should raise an error with more information that is
      -- not contained here, such as event ID.
      return false
   end

   assert(type(name) == "string")
   self.dirty = true
   self.cbs[#self.cbs+1] = { priority = priority, cb = cb, name = name }

   -- In order to check for existence, but before sorting
   self.name_to_ind[name] = -1

   return true
end

function EventTree:disable(name)
   self.disabled[name] = true

   if self.dirty then
      self:sort()
   else
      local ind = self.name_to_ind[name]
      if ind ~= nil then
         self.disabled_inds[ind] = true
      end
   end
end

function EventTree:enable(name)
   self.disabled[name] = nil

   if self.dirty then
      self:sort()
   else
      local ind = self.name_to_ind[name]
      if ind ~= nil then
         self.disabled_inds[ind] = nil
      end
   end
end

function EventTree:unregister(name)
   local ind = self.name_to_ind[name]
   if not ind then
      return
   end

   table.remove_by(self.cbs, function(v) return v.name == name end)

   self.disabled_inds[ind] = nil
   self.name_to_ind[name] = nil
   self.dirty = true
end

function EventTree:sort()
   table.sort(self.cbs, function(a, b) return a.priority < b.priority end)
   self.cache = {}
   for _, v in ipairs(self.cbs) do
      local i = #self.cache+1
      self.cache[i] = v.cb
      self.name_to_ind[v.name] = i
      if self.disabled[v.name] then
         self.disabled_inds[i] = true
      end
   end
   self.dirty = false
end

function EventTree:traverse(source, args, default)
   if self.dirty then
      self:sort()
   end

   -- local disabled = {}
   -- local disabled_inds = self.disabled_inds
   local cache = self.cache

   local result = default
   local new_result
   local status
   for i, cb in ipairs(cache) do
      new_result, status = cb(source, args, result)

      -- If the result returned is nil, do not set the final result to
      -- nil. This is to avoid having to return 'result' for event
      -- callbacks that return a significant return value, since
      -- leaving out a return will cause 'nil' to be returned instead.
      -- Requiring something to be returned in every callback meant it
      -- was easy for one event in the chain to forget to do this,
      -- causing errors, and it was difficult to remember which events
      -- required 'result' to be returned or not.
      if new_result ~= nil then
         result = new_result
      end

      if status == "blocked" then
         break
      end
   end

   return result
end

function EventTree:trigger(source, args, default)
   return self:traverse(source, args, default)
end

function EventTree:__call(source, args, default)
   return self:traverse(source, args, default)
end

function EventTree:print()
   if self.dirty then
      self:sort()
   end

   local arr = {}
   for _, v in ipairs(self.cbs) do
      local disabled = ""
      if self.disabled[v.name] then
         disabled = "Yes"
      end

      local first_line = string.split(v.name)[1]

      arr[#arr+1] = { first_line, v.priority, disabled }
   end

   return table.print(arr,
                      {
                         header = { "Name", "Priority", "Disabled" },
                         spacing = 2
                      }
   )
end

return EventTree
