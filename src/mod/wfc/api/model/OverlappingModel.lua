local IModel = require("mod.wfc.api.model.IModel")
local Model = require("mod.wfc.api.model.Model")
local Draw = require("api.Draw")
local Color = require("mod.elona_sys.api.Color")

local OverlappingModel = class.class("OverlappingModel", IModel)

local function rotate_pattern(p, N)
   local result = {}
   for i = 0, #p - 1 do
      local x = i % N
      local y = math.floor(i / N)
      result[i + 1] = assert(p[x * N + N - y])
   end
   return result
end

local function reflect_pattern(p, N)
   local result = {}
   for i = 0, #p - 1 do
      local x = i % N
      local y = math.floor(i / N)
      result[i + 1] = assert(p[y * N + N - x])
   end
   return result
end

local function agrees(N, p1, p2, dx, dy)
   local xmin = math.max(dx, 0)
   local xmax = dx < 0 and dx + N or N
   local ymin = math.max(dy, 0)
   local ymax = dy < 0 and dy + N or N

   for y = ymin, ymax - 1 do
      for x = xmin, xmax - 1 do
         if p1[y * N + x + 1] ~= p2[(y - dy) * N + x - dx + 1] then
            return false
         end
      end
   end

   return true
end

function OverlappingModel:init(image, N, width, height, periodic_input, periodic_output, symmetry, ground)
   local is_on_boundary = function(_, x, y)
      return self:is_on_boundary(x, y)
   end
   self.model = Model:new(width, height, is_on_boundary)

   self.N = N
   self.periodic = periodic_output

   local SMX, SMY = image:getDimensions()
   local sample = {}
   self.colors = {}

   image:mapPixel(function(x, y, r, g, b, a)
      local color = Color.to_number(Draw.color_to_bytes(r, g, b, a))
      local found = 0

      for i, v in ipairs(self.colors) do
         if v == color then
            found = i
            break
         end
      end

      if found == 0 then
         found = #self.colors + 1
         self.colors[found] = color
      end

      sample[y * SMX + x + 1] = found
      return r, g, b, a
   end)

   local W = (#self.colors) ^ (N * N)
   local weights = {}
   local ordering = {}

   for y = 0, (periodic_input and SMY or (SMY - N + 1)) - 1 do
      for x = 0, (periodic_input and SMX or (SMX - N + 1)) - 1 do
         local ps = {}
         local psb = {}
         for i = 0, N * N - 1 do
            local dx = i % N
            local dy = math.floor(i / N)
            psb[i + 1] = sample[((y + dy) % SMY) * SMX + (x + dx) % SMX + 1]
         end

         ps[1] = psb
         ps[2] = reflect_pattern(ps[1], N)
         ps[3] = rotate_pattern(ps[1], N)
         ps[4] = reflect_pattern(ps[3], N)
         ps[5] = rotate_pattern(ps[3], N)
         ps[6] = reflect_pattern(ps[5], N)
         ps[7] = rotate_pattern(ps[5], N)
         ps[8] = reflect_pattern(ps[7], N)

         for k = 1, symmetry do
            local ind = 0
            local power = 1

            for i = #ps[k], 1, -1 do
               ind = ind + (ps[k][i] - 1) * power
               power = power * #self.colors
            end

            if weights[ind] then
               weights[ind] = weights[ind] + 1
            else
               weights[ind] = 1
               ordering[#ordering + 1] = ind
            end
         end
      end
   end

   self.model.T = #ordering
   self.ground = (ground + self.model.T) % self.model.T
   self.patterns = {}

   for i, v in ipairs(ordering) do
      local residue = v
      local power = W
      local result = {}

      for j = 1, N * N do
         power = math.floor(power / #self.colors)
         local count = 0
         while residue >= power do
            residue = residue - power
            count = count + 1
         end

         result[j] = count % 255
      end

      self.patterns[i] = result
      self.model.weights[i] = weights[v]
   end

   for d = 1, 4 do
      local prop = {}
      self.model.propagator[d] = prop

      for t = 1, self.model.T do
         local list = {}

         for t2 = 1, self.model.T do
            if agrees(N, self.patterns[t], self.patterns[t2], Model.DX[d], Model.DY[d]) then
               list[#list + 1] = t2 - 1
            end
         end

         prop[t] = list
      end
   end
end

function OverlappingModel:is_on_boundary(x, y)
   -- !periodic && (x + N > width || y + N > height || x < 0 || y < 0)
   return not (self.periodic) and (x + self.N > self.model.width or y + self.N > self.model.height or x < 0 or y < 0)
end

function OverlappingModel:to_image_data(image)
   image = image or Draw.new_image_data(self.model.width, self.model.height)
   if image:getWidth() ~= self.model.width or image:getHeight() ~= self.model.height then
      error(("invalid image size (%d %d) (%d %d)"):format(image:getWidth(), image:getHeight(), self.model.width, self.model.height))
   end

   if not (self.map_pixel_observed) then
      self.map_pixel_observed = function(x, y)
         local dy = y < self.model.height - self.N + 1 and 0 or self.N - 1
         local dx = x < self.model.width - self.N + 1 and 0 or self.N - 1

         local c = self.colors[self.patterns[self.model.observed[(y - dy) * self.model.width + x - dx + 1]][dy * self.N + dx + 1] + 1]
         return Draw.color_from_bytes(Color.from_number(c))
      end
   end

   if not (self.map_pixel) then
      self.map_pixel = function(x, y)
         local contrib = 0
         local r, g, b = 0, 0, 0

         for di = 0, self.N * self.N - 1 do
            local dx = di % self.N
            local dy = math.floor(di / self.N)
            local sx = (x - dx) % self.model.width
            local sy = (y - dy) % self.model.height
            local s = sy * self.model.width + sx

            if self:is_on_boundary(sx, sy) == false then
               for t = 1, self.model.T do
                  if self.model.wave[s + 1][t] then
                     contrib = contrib + 1
                     local c = assert(self.colors[self.patterns[t][dy * self.N + dx + 1] + 1])
                     local ar, ag, ab = Draw.color_from_bytes(Color.from_number(c))
                     r = r + ar
                     g = g + ag
                     b = b + ab
                  end
               end
            end
         end

         -- print(r, g, b, contrib)
         return r / contrib, g / contrib, b / contrib, 1
      end
   end

   image:mapPixel(self:is_fully_observed() and self.map_pixel_observed or self.map_pixel)
   return image
end

function OverlappingModel:clear()
   self.model:clear()

   if self.ground ~= 0 then
      for x = 0, self.model.width - 1 do
         for t = 0, self.T - 1 do
            if t ~= self.ground then
               self.model:_ban(x + (self.model.height - 1) * self.model.width, t)
            end
         end

         for y = 0, self.model.height - 2 do
            self.model:_ban(x + y * self.model.width, self.ground)
         end
      end

      self.model:_propagate()
   end
end

function OverlappingModel:run(limit, step)
   return self.model:run(limit, step)
end

function OverlappingModel:is_fully_observed()
   return not not self.model.observed
end

return OverlappingModel
