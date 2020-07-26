local Rand = require("api.Rand")

local Model = class.class("Model")

Model.DX = {-1, 0, 1, 0}
Model.DY = {0, 1, 0, -1}
Model.opposite = {2, 3, 0, 1}

local function random(a, r)
   local sum = 0
   for i = 1, #a do
      sum = sum + a[i]
   end

   for i = 1, #a do
      a[i] = a[i] / sum
   end

   local i = 1
   local x = 0

   while i <= #a do
      x = x + a[i]
      if r <= x then
         return i - 1
      end
      i = i + 1
   end

   return 0
end

function Model:init(width, height, is_on_boundary, rng)
   self.wave = nil

   self.propagator = {}
   self.compatible = {}
   self.observed = nil -- 1-based indexing value

   self.stack = {}
   self.stacksize = 0

   self.rng = rng or { rnd_float = function(_) return Rand.rnd_float() end }
   self.width = width
   self.height = height
   self.T = 0

   self.weights = {}
   self.weight_log_weights = {}

   self.sums_of_ones = {}
   self.sum_of_weights = 0
   self.sum_of_weight_log_weights = 0
   self.starting_entropy = 0
   self.sums_of_weights = {}
   self.sums_of_weight_log_weights = {}
   self.entropies = {}

   self.is_on_boundary = is_on_boundary
end

function Model:_reset()
   local waveLen = self.width * self.height
   self.wave = {}

   for i = 1, waveLen do
      local t = {}
      local compat = {}
      for j = 1, self.T do
         t[j] = false
         compat[j] = {0, 0, 0, 0}
      end

      self.compatible[i] = compat
      self.wave[i] = t
      self.sums_of_ones[i] = 0
      self.sums_of_weights[i] = 0
      self.sums_of_weight_log_weights[i] = 0
      self.entropies[i] = 0
   end

   for i = 1, self.T do
      self.weight_log_weights[i] = self.weights[i] * math.log(self.weights[i])
      self.sum_of_weights = self.sum_of_weights + self.weights[i]
      self.sum_of_weight_log_weights = self.sum_of_weight_log_weights + self.weight_log_weights[i]
   end

   self.starting_entropy = math.log(self.sum_of_weights) - self.sum_of_weight_log_weights / self.sum_of_weights

   for i = 1, waveLen * self.T do
      self.stack[i] = {0, 0}
   end
end

function Model:_observe()
   local min = 1e3
   local argmin = -1

   for i = 1, #self.wave do
      if self:is_on_boundary((i - 1) % self.width, math.floor((i - 1) / self.width)) == false then
         local amount = self.sums_of_ones[i]
         if amount == 0 then
            return false
         end

         local entropy = self.entropies[i]
         if amount > 1 and entropy <= min then
            local noise = 1e-6 * self.rng:rnd_float()

            if entropy + noise < min then
               min = entropy + noise
               argmin = i
            end
         end
      end
   end

   -- print("OBSERVE " .. #self.wave)
   if argmin == -1 then
      self.observed = {}

      for i = 1, #self.wave do
         self.observed[i] = 0
      end

      for i = 1, #self.wave do
         for t = 1, self.T do
            if self.wave[i][t] then
               self.observed[i] = t
               break
            end
         end
      end

      return true
   end

   local distribution = {}
   for i = 1, self.T do
      distribution[i] = self.wave[argmin][i] and self.weights[i] or 0
   end

   local r = random(distribution, self.rng:rnd_float()) + 1

   local w = self.wave[argmin]
   for t = 1, self.T do
      if w[t] ~= (t == r) then
         self:_ban(argmin - 1, t - 1)
      end
   end

   return nil
end

function Model:_propagate()
   -- print("PROPAGATE")
   while self.stacksize > 0 do
      local e1 = self.stack[self.stacksize]
      local e11, e12 = e1[1], e1[2]
      self.stacksize = self.stacksize - 1

      local i1 = e11
      local x1 = i1 % self.width
      local y1 = math.floor(i1 / self.width)

      for d = 1, 4 do
         local dx = Model.DX[d]
         local dy = Model.DY[d]
         local x2 = x1 + dx
         local y2 = y1 + dy

         if self:is_on_boundary(x2, y2) == false then
            x2 = x2 % self.width
            y2 = y2 % self.height

            local i2 = x2 + y2 * self.width
            local p = self.propagator[d][e12 + 1]
            local compat = self.compatible[i2 + 1]

            for l = 1, #p do
               local t2 = p[l]
               local comp = compat[t2 + 1]

               comp[d] = comp[d] - 1
               if comp[d] == 0 then
                  self:_ban(i2, t2)
               end
            end
         end
      end
   end
end

function Model:_ban(i, t)
   -- print("banned", i, t)
   self.wave[i + 1][t + 1] = false

   local comp = self.compatible[i + 1][t + 1]
   for d = 1, 4 do
      comp[d] = 0
   end

   self.stacksize = self.stacksize + 1
   if self.stack[self.stacksize] then
      local p = self.stack[self.stacksize]
      p[1], p[2] = i, t
   else
      self.stack[self.stacksize] = {i, t}
   end

   self.sums_of_ones[i + 1] = self.sums_of_ones[i + 1] - 1
   self.sums_of_weights[i + 1] = self.sums_of_weights[i + 1] - self.weights[t + 1]
   self.sums_of_weight_log_weights[i + 1] = self.sums_of_weight_log_weights[i + 1] - self.weight_log_weights[t + 1]

   local sum = self.sums_of_weights[i + 1]
   self.entropies[i + 1] = math.log(sum) - self.sums_of_weight_log_weights[i + 1] / sum
end

function Model:clear()
   for i = 1, #self.wave do
      for t = 1, self.T do
         self.wave[i][t] = true
         for d = 1, 4 do
            self.compatible[i][t][d] = #self.propagator[Model.opposite[d] + 1][t]
         end
      end

      self.sums_of_ones[i] = #self.weights
      self.sums_of_weights[i] = self.sum_of_weights
      self.sums_of_weight_log_weights[i] = self.sum_of_weight_log_weights
      self.entropies[i] = self.starting_entropy
   end
end

function Model:run(limit, step)
   limit = limit or math.huge

   if self.wave == nil then
      self:_reset()

      if step then
         self:clear()
      end
   end

   if not (step) then
      self:clear()
   end

   for _ = 1, limit do
      local result = self:_observe()
      if result ~= nil then
         return result
      end

      self:_propagate()
   end

   return not (step)
end

return Model
