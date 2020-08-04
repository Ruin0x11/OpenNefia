local Rand = require("api.Rand")

local WeightedSampler = class.class("WeightedSampler")

function WeightedSampler:init()
   self.sum = 0
   self.candidates = {}
end

function WeightedSampler:clear()
   self.sum = 0
   self.candidates = {}
end

function WeightedSampler:add(item, weight)
   self.sum = self.sum + weight
   table.insert(self.candidates, { item, self.sum })
end

function WeightedSampler:len()
   return #self.candidates
end

function WeightedSampler:sample()
   if self.sum == 0 or #self.candidates == 0 then
      return nil
   end

   local n = Rand.rnd_huge(self.sum)

   for _, cand in ipairs(self.candidates) do
      if cand[2] > n then
         return cand[1]
      end
   end

   return nil
end

return WeightedSampler
