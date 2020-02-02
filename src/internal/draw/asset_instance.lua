local Draw = require("api.Draw")

local asset_instance = class.class("asset_instance")

function asset_instance:init(asset, width, height)
   assert(class.is_an(require("internal.draw.asset_drawable"), asset))
   self.asset = asset
   self.quads = {}

   self:resize(width, height)
end

function asset_instance:resize(width, height)
   self.width = width or self.asset:get_width()
   self.height = height or self.asset:get_height()

   -- Get the list of regions. These are a set of tuples that contain
   -- the dimensions to create the quads in.
   local regions = self.asset.regions
   if type(regions) == "function" then
      regions = regions(self.width, self.height)
   end

   -- Allocate the actual userdata quads from the region list.
   self.quads = {}
   for k, v in pairs(regions) do
      self.quads[k] = love.graphics.newQuad(v[1], v[2], v[3], v[4],
                                            self.asset:get_width(),
                                            self.asset:get_height())
   end
end

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

function asset_instance:release()
   for _, quad in pairs(self.quads) do
      quad:release()
   end
end

return asset_instance
