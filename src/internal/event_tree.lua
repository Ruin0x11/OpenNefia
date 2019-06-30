local event_tree = class.class("event_tree")

function event_tree:init()
   self.dirty = true
   self.cbs = {}
   self.cache = {}
   self.disabled = {}
   self.disabled_inds = {}
   self.name_to_ind = {}
end

function event_tree:count()
   return #self.cbs
end

function event_tree:has_handler(name)
   return self.name_to_ind[name] ~= nil
end

function event_tree:insert(priority, cb, name)
   if self.name_to_ind[name] then
      return false
   end

   assert(type(name) == "string")
   self.dirty = true
   self.cbs[#self.cbs+1] = { priority = priority, cb = cb, name = name }

   -- In order to check for existence, but before sorting
   self.name_to_ind[name] = -1

   return true
end

function event_tree:disable(name)
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

function event_tree:enable(name)
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

function event_tree:unregister(name)
   local ind = self.name_to_ind[name]
   if not ind then
      return
   end

   table.remove_by(self.cbs, function(v) return v.name == name end)

   self.disabled_inds[ind] = nil
   self.name_to_ind[name] = nil
   self.dirty = true
end

function event_tree:sort()
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

function event_tree:traverse(f, args)
   if self.dirty then
      self:sort()
   end

   local disabled = {}
   local disabled_inds = self.disabled_inds

   for i, cb in ipairs(self.cache) do
      if not self.disabled_inds[i] or disabled[i] then
         local result = cb(args)

         if type(result) == "table" then
            args = table.merge(args, result)
         end

         if args.blocked then
            return false
         end

         if args.disabled then
            for _, name in ipairs(args.disabled) do
               local ind = self.name_to_ind[name]
               if ind ~= nil then
                  disabled[ind] = true
               end
            end
         end
      end
   end

   return true
end

function event_tree:print()
   if self.dirty then
      self:sort()
   end

   local arr = {}
   for _, v in ipairs(self.cbs) do
      local disabled = ""
      if self.disabled[v.name] then
         disabled = "Yes"
      end

      arr[#arr+1] = { v.name, v.priority, disabled }
   end

   return table.print(arr,
                      {
                         header = { "Name", "Priority", "Disabled" },
                         spacing = 2
                      }
   )
end

return event_tree
