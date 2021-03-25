local Draw = require("api.Draw")

local asset_instance = class.class("asset_instance")

-- @tparam asset_drawable asset
-- @tparam uint[opt] width Defaults to asset width.
-- @tparam uint[opt] height Defaults to asset height.
function asset_instance:init(asset, width, height)
   assert(class.is_an(require("internal.draw.asset_drawable"), asset))
   self.asset = asset
   self.quads = {}

   self.bar_width = nil
   self.bar_quad = love.graphics.newQuad(1, 1, 1, 1,
                                         self.asset:get_width(),
                                         self.asset:get_height())
   self.bar_quad_remainder = love.graphics.newQuad(1, 1, 1, 1,
                                         self.asset:get_width(),
                                         self.asset:get_height())
   self.bar_region = nil

   self:resize(width, height)
end

-- Resizes this asset instance and recomputes the necessary quads.
-- @tparam uint[opt] width Defaults to asset width.
-- @tparam uint[opt] height Defaults to asset height.
function asset_instance:resize(width, height)
   self.width = width or self.asset:get_width()
   self.height = height or self.asset:get_height()

   -- Get the list of regions. These are a set of tuples that contain
   -- the dimensions to create the quads in.
   local regions = self.asset.regions
   if type(regions) == "function" then
      regions = regions(self.width, self.height)
   end
   regions = regions or {}

   -- Clear old quads.
   for k, quad in pairs(self.quads) do
      if not regions[k] then
         quad:release()
      end
   end

   local iw = self.asset.image:getWidth()
   local ih = self.asset.image:getHeight()

   local count_x = self.asset.count_x or 1
   local count_y = self.asset.count_y or 1
   if count_x ~= 1 or count_y ~= 1 then
      local w = iw / count_x
      local h = ih / count_y

      local q = 1
      for j=1,count_y do
         for i=1,count_x do
            self.quads[q] = love.graphics.newQuad(w * (i - 1),
                                                  h * (j - 1),
                                                  w, h, iw, ih)
            q = q + 1
         end
      end
   end

   -- Allocate the actual userdata quads from the region list.
   for k, v in pairs(regions) do
      if self.quads[k] == nil then
         self.quads[k] = love.graphics.newQuad(v[1], v[2], v[3], v[4],
                                               self.asset:get_width(),
                                               self.asset:get_height())
      else
         self.quads[k]:setViewport(v[1], v[2], v[3], v[4])
      end
   end
end

-- Given `parts`, a list of region IDs and coordinates, creates a
-- sprite batch which draws them in a single draw call.
--
-- The contents of `parts` look like this:
--
--  { "right_mid", x + width - 16, i * 16 + y + 16 }
--
-- The first entry is the region ID, second is X, third is Y. The
-- regions are generated from the theme data - they can be a map of
-- region to image location or a function that generates them
-- dynamically from a width and height.
-- @tparam {{string,int,int},...} parts
-- @treturn love.graphics.SpriteBatch
function asset_instance:make_batch(parts)
   local batch = love.graphics.newSpriteBatch(self.asset.image, self.asset:get_width() * self.asset:get_height())
   batch:clear()

   for _, part in ipairs(parts) do
      local region_id = part[1]
      local x = part[2]
      local y = part[3]

      batch:add(self.quads[region_id], x, y)
   end

   batch:flush()

   return batch
end

function asset_instance:get_width()
   return self.width or self.asset:get_width()
end

function asset_instance:get_height()
   return self.height or self.asset:get_height()
end

function asset_instance:draw(x, y, width, height, color, centered, rotation)
   Draw.image(self.asset.image, x, y, width, height, color, centered, rotation)
end

function asset_instance:draw_region(quad, x, y, width, height, color, centered, rotation)
   if not self.quads[quad] then
      error(string.format("Quad ID '%s' not found", tostring(quad)))
   end
   Draw.image_region(self.asset.image, self.quads[quad], x, y, width, height, color, centered, rotation)
end

function asset_instance:draw_stretched(x, y, tx, ty, color, centered, rotation)
   Draw.image_stretched(self.asset.image, x, y, tx, ty, color, centered, rotation)
end

function asset_instance:draw_region_stretched(quad, x, y, tx, ty, color, centered, rotation)
   if not self.quads[quad] then
      error(string.format("Quad ID '%s' not found", tostring(quad)))
   end
   Draw.image_region_stretched(self.asset.image, self.quads[quad], x, y, tx, ty, color, centered, rotation)
end
local Log = require("api.Log")

function asset_instance:draw_bar(x, y, width, region)
   local iw = self.asset:get_width()
   local ih = self.asset:get_height()

   local last_width = width
   local last_region = region
   if self.bar_width ~= last_width or self.bar_region ~= last_region then
      self.bar_width = last_width
      self.bar_region = last_region
      if self.bar_region then
         local q = assert(self.quads[self.bar_region])
         local tx, ty, tw, th = q:getViewport()
         self.bar_quad:setViewport(tx, ty, iw, ih)
         self.bar_quad_remainder:setViewport(tx, ty, last_width, th)
      else
         self.bar_quad:setViewport(0, 0, iw, ih)
         self.bar_quad_remainder:setViewport(0, 0, iw % last_width, ih)
      end
   end

   local step = math.ceil(width / iw)
   for i=0,step-1 do
      if i == step - 1 then
         Draw.image_region(self.asset.image, self.bar_quad, i * iw + x, y)
      else
         Draw.image_region(self.asset.image, self.bar_quad_remainder, i * iw + x, y)
      end
   end
end

function asset_instance:draw_percentage_bar(x, y, width, draw_width, draw_height)
   local iw = self.asset:get_width()
   local ih = self.asset:get_height()

   local last_width = width
   if self.bar_width ~= last_width then
      self.bar_width = last_width
      self.bar_quad:setViewport(iw - width, 0, last_width, ih)
   end

   Draw.image_region(self.asset.image, self.bar_quad, x, y, draw_width, draw_height)
end

function asset_instance:release()
   for _, quad in pairs(self.quads) do
      quad:release()
   end
end

return asset_instance
