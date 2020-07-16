--[[

edges["a"] = {
   {
       [10] = 120
   }
}
edges["b"]
edges["c"]

--]]

local dawg_node = class.class("dawg_node")

function dawg_node:__tostring()
   local t = {}
   if self.final then
      t[#t+1] = "1"
   else
      t[#t+1] = "0"
   end
   for k, n in pairs(self.edges) do
      t[#t+1] = k
      t[#t+1] = tostring(n.id)
   end
   return table.concat(t, "_")
end

function dawg_node:__eq(other)
   return tostring(self) == tostring(other)
end

local next_id = 0
function dawg_node:init()
   self.id = next_id
   self.edges = {}
   self.final = nil
   self.count = nil

   next_id = next_id + 1
end

function dawg_node:num_reachable()
   if self.count then
      return self.count
   end

   local count = 0
   if self.final then
      count = count + 1
   end
   for _, n in pairs(self.edges) do
      count = count + n:num_reachable()
   end
   self.count = count
   return count
end

return dawg_node
