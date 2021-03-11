local IModel = require("mod.wfc.api.model.IModel")
local Model = require("mod.wfc.api.model.Model")
local Draw = require("api.Draw")
local Color = require("mod.extlibs.api.Color")

local SimpleTiledModel = class.class("SimpleTiledModel", IModel)

local symmetry_table = {
   L = {
      cardinality = 4,
      a = function(i)
         return (i + 1) % 4
      end,
      b = function(i)
         return (i % 2 == 0) and (i + 1) or (i - 1)
      end
   },
   T = {
      cardinality = 4,
      a = function(i)
         return (i + 1) % 4
      end,
      b = function(i)
         return (i % 2 == 0) and i or (4 - i)
      end
   },
   I = {
      cardinality = 2,
      a = function(i)
         return 1 - i
      end,
      b = function(i)
         return i
      end
   },
   ["\\"] = {
      cardinality = 2,
      a = function(i)
         return 1 - i
      end,
      b = function(i)
         return 1 - i
      end
   },
   X = {
      cardinality = 1,
      a = function(i)
         return i
      end,
      b = function(i)
         return i
      end
   }
}

function SimpleTiledModel:__construct(data, subsetName, width, height, periodic, black)
   local is_on_boundary = function(_, x, y)
      return self:is_on_boundary(x, y)
   end
   self.model = Model:new(width, height, is_on_boundary)

   -- Data structure:
   --[[
    data = {
        size = tile_size or 16,
        unique = false or true,
        tiles = {
            {
                name = tile_name,
                symmetry = symmetry or "X",
                weight = weight or 1.0
            }
        },
        tile_image = {
            [name] = love.graphics.ImageData, ...
        }
        neighbors = {
            {left="", right=""},
            {left="", right=""},
            ...
            {left="", right=""}
        },
        subsets = {
            [name] = {
                "tile1", "tile2", ...
            }
        }
    }
    ]]

   self.periodic = not (not (periodic))
   self.black = not (not (black))
   self.tilesize = data.size or 16

   data.tile_image = {}
   for _, tile in ipairs(data.tiles) do
      if data.unique then
         for i = 0, symmetry_table[tile.symmetry].cardinality - 1 do
            local name
            if i == 0 and not data.unique then
               name = tile.name
            else
               name = tile.name .. " " .. i
            end
            assert(data.tile_image[name], ("missing tile '%s'"):format(name))
         end
      else
         assert(data.tile_image[tile.name], ("missing tile '%s'"):format(tile.name))
      end
   end

   local unique = not (not (data.unique))
   local subset = nil

   if subsetName ~= nil then
      local ss = assert(data.subsets[subsetName], ("subset '%s' not found"):format(subsetName))
      subset = {}
      for _, v in ipairs(ss) do
         subset[#subset+1] = v.name
         if v.symmetry then
            -- TODO
         end
      end
      subset = table.set(subset)
   end

   local function tile(f)
      local result = {}
      for i = 1, self.tilesize * self.tilesize do
         result[i] = f((i - 1) % self.tilesize, math.floor((i - 1) / self.tilesize))
      end
      assert(table.count(result) == #result)
      return result
   end

   local function rotate(a)
      return tile(function(x, y)
         return a[self.tilesize - y + x * self.tilesize]
      end)
   end

   self.tiles = {}
   self.tilenames = {}

   local action = {}
   local first_occurrence = {}

   for _, tileObject in ipairs(data.tiles) do
      local tilename = tileObject.name

      if subset == nil or subset[tilename] then
         local sym = symmetry_table[tileObject.symmetry or "X"] or symmetry_table.X;

         self.model.T = #action
         first_occurrence[tilename] = self.model.T

         for t = 0, sym.cardinality - 1 do
            local mapt = {}

            mapt[1] = t
            mapt[2] = sym.a(t)
            mapt[3] = sym.a(mapt[2])
            mapt[4] = sym.a(mapt[3])
            mapt[5] = sym.b(t)
            mapt[6] = sym.b(mapt[2])
            mapt[7] = sym.b(mapt[3])
            mapt[8] = sym.b(mapt[4])

            for s = 1, 8 do
               mapt[s] = mapt[s] + self.model.T
            end

            action[#action + 1] = mapt
         end

         if unique then
            for t = 0, sym.cardinality - 1 do
               local target = tilename .. " " .. t
               local imageData = assert(data.tile_image[target], "missing tileimage " .. target)

               self.tiles[#self.tiles + 1] = tile(function(x, y)
                  return Color.to_number(Draw.color_to_bytes(imageData:getPixel(x, y)))
               end)
               self.tilenames[#self.tilenames + 1] = target
            end
         else
            local imageData = assert(data.tile_image[tilename], "missing tileimage " .. tilename)

            self.tiles[#self.tiles + 1] = tile(function(x, y)
               return Color.to_number(Draw.color_to_bytes(imageData:getPixel(x, y)))
            end)
            self.tilenames[#self.tilenames + 1] = tilename .. " 0"

            for t = 1, sym.cardinality - 1 do
               self.tiles[#self.tiles + 1] = rotate(self.tiles[self.model.T + t])
               self.tilenames[#self.tilenames + 1] = tilename .. " " .. t
            end
         end

         for _ = 1, sym.cardinality do
            self.weights[#self.weights + 1] = tonumber(tileObject.weight) or 1
         end
      end
   end

   self.model.T = #action
   local temp_propagator = {}

   for d = 1, 4 do
      temp_propagator[d] = {}
      self.propagator[d] = {}

      for t = 1, self.model.T do
         temp_propagator[d][t] = {}
         self.propagator[d][t] = {}
         for u = 1, self.model.T do
            temp_propagator[d][t][u] = false
         end
      end
   end

   for _, neighbor in ipairs(data.neighbors) do
      local left = string.split(neighbor.left, " ")
      local right = string.split(neighbor.right, " ")

      if subset == nil or (subset[left[1]] and subset[right[1]]) then
         local L = action[first_occurrence[left[1]] + 1][#left == 1 and 1 or (left[2] + 1)]
         local D = action[L + 1][2]
         local R = action[first_occurrence[right[1]] + 1][#right == 1 and 1 or (right[2] + 1)]
         local U = action[R + 1][2]

         temp_propagator[1][R + 1][L + 1] = true
         temp_propagator[1][action[R + 1][7] + 1][action[L + 1][7] + 1] = true
         temp_propagator[1][action[L + 1][5] + 1][action[R + 1][5] + 1] = true
         temp_propagator[1][action[L + 1][3] + 1][action[R + 1][3] + 1] = true
         temp_propagator[2][U + 1][D + 1] = true
         temp_propagator[2][action[D + 1][7] + 1][action[U + 1][7] + 1] = true
         temp_propagator[2][action[U + 1][5] + 1][action[D + 1][5] + 1] = true
         temp_propagator[2][action[D + 1][3] + 1][action[U + 1][3] + 1] = true
      end
   end

   for t = 0, self.model.T * self.model.T - 1 do
      local t2 = math.floor(t / self.model.T) + 1
      local t1 = t % self.model.T + 1
      temp_propagator[3][t2][t1] = temp_propagator[1][t1][t2]
      temp_propagator[4][t2][t1] = temp_propagator[2][t1][t2]
   end

   local sparse_propagator = {}
   for d = 1, 4 do
      local sp = {}
      for i = 1, self.model.T do
         sp[i] = {}
      end
      sparse_propagator[d] = sp
   end

   for d = 1, 4 do
      for t1 = 1, self.model.T do
         local sp = sparse_propagator[d][t1]
         local tp = temp_propagator[d][t1]

         for t2 = 1, self.model.T do
            if tp[t2] then
               sp[#sp + 1] = t2 - 1
            end
         end

         local stt = {}
         for i = 1, #sp do
            stt[i] = 0
         end

         self.propagator[d][t1] = stt
         for st = 1, #sp do
            stt[st] = sp[st]
         end
      end
   end
end

function SimpleTiledModel:is_on_boundary(x, y)
   return not (self.periodic) and (x < 0 or y < 0 or x >= self.model.FMX or y >= self.model.FMY)
end

function SimpleTiledModel:to_image_data(image)
   image = image or Draw.new_image_data(self.model.FMX * self.tilesize, self.model.FMY * self.tilesize)
   if image:getWidth() ~= self.model.width or image:getHeight() ~= self.model.height then
      error(("invalid image size (%d %d) (%d %d)"):format(image:getWidth(), image:getHeight(), self.model.width, self.model.height))
   end

   if not (self.map_pixel_observed) then
      self.map_pixel_observed = function(x, y)
         local px = math.floor(x / self.tilesize)
         local py = math.floor(y / self.tilesize)
         local tile = self.tiles[self.model.observed[px + py * self.model.FMX + 1]]
         local tx = x % self.tilesize
         local ty = y % self.tilesize
         return Draw.color_from_bytes(Color.from_number(tile[ty * self.tilesize + tx + 1]))
      end
   end

   if not (self.map_pixel) then
      self.map_pixel = function(x, y)
         return 0.5, 0.5, 0.5, 1
      end
   end

   image:mapPixel((self:is_fully_observed() and self.map_pixel_observed) or self.map_pixel)
   return image
end

function SimpleTiledModel:run(limit, step)
   return self.model:run(limit, step)
end

function SimpleTiledModel:is_fully_observed()
   return not not self.model.observed
end

return SimpleTiledModel
