local Log = require("api.Log")
local anim = require("internal.draw.anim")
local asset_drawable = require("internal.draw.asset_drawable")
local atlas_batch = require("internal.draw.atlas_batch")
local binpack = require("thirdparty.binpack")
local bmp_convert = require("internal.bmp_convert")

local atlas = class.class("atlas")

local function load_tile(spec, frame_id, offset_x, offset_y)
   local tile, quad

   -- spec has the format:
   --
   --     {
   --       image = "graphic/chip.png",
   --       count_x = 1
   --     }
   --
   -- or:
   --
   --     {
   --       source = "graphic/map0.bmp",
   --       x = 0,
   --       y = 0,
   --       width = 48,
   --       height = 48,
   --       count_x = 1,
   --       key_color = {0, 0, 0}
   --     }
   --
   -- or is an instance of asset_drawable

   if class.is_an(asset_drawable, spec) then
      tile = spec
      quad = nil
   elseif type(spec) == "table" then
      if spec.source then
         tile = bmp_convert.load_image(spec.source, spec.key_color)
         quad = love.graphics.newQuad((spec.x or 0) + offset_x, (spec.y or 0) + offset_y, spec.width, spec.height,
                                      tile:getWidth(), tile:getHeight())
      elseif spec.image then
         tile = bmp_convert.load_image(spec.image, spec.key_color)
         quad = love.graphics.newQuad(0, 0, tile:getWidth(), tile:getHeight(), tile:getWidth(), tile:getHeight())
      else
         error(("Unsupported tile type: %s"):format(spec))
      end
   else
      error(("Unsupported tile type: %s"):format(spec))
   end

   return tile, quad
end

function atlas:init(tile_width, tile_height)
   self.tile_width = tile_width
   self.tile_height = tile_height
   self.tiles = {}
   self.image = nil
   self.batch = nil
   self.binpack = nil
   self.image_width = nil
   self.image_height = nil
   self.anims = {}
   self.existing = {}
   self.rects = {}

   -- blank fallback in case of missing filepath.
   local fallback_data = love.image.newImageData(self.tile_width, self.tile_height)
   self.fallback = love.graphics.newImage(fallback_data)
end

function atlas:insert_tile(id, anim_id, frame_id, spec, load_tile_cb, offset_x, offset_y)
   offset_x = offset_x or 0
   offset_y = offset_y or 0

   local full_id = ("%s#%s:%d"):format(id, anim_id, frame_id)

   local tile, quad = load_tile(spec, frame_id, offset_x, offset_y)

   local _, tw, th
   if class.is_an(asset_drawable, tile) then
      tw = tile:get_width()
      th = tile:get_height()
   else
      _, _, tw, th = quad:getViewport()
   end

   -- NOTE: This would cause issues if the size of the tile changes during a hotload.
   local rect = self.rects[full_id]
   if rect == nil then
      rect = self.binpack:insert(tw, th)
   end
   assert(rect, inspect(spec))
   self.rects[full_id] = rect

   if class.is_an(asset_drawable, tile) then
      tile:draw(rect.x, rect.y)
   elseif load_tile_cb then
      load_tile_cb(tile, quad, rect.x, rect.y)
   else
      love.graphics.draw(tile, quad, rect.x, rect.y)
   end

   -- Create a new quad inside the atlas we're assembling pointing to
   -- the tile that was pasted in.
   local is_tall = th == self.tile_height * 2
   local inner_quad
   if is_tall then
      inner_quad = love.graphics.newQuad(rect.x,
                                   rect.y,
                                   self.tile_width,
                                   self.tile_height * 2,
                                   self.image_width,
                                   self.image_height)
   else
      inner_quad = love.graphics.newQuad(rect.x,
                                   rect.y,
                                   self.tile_width,
                                   self.tile_height,
                                   self.image_width,
                                   self.image_height)
   end

   local offset_y = 0
   if is_tall then
      offset_y = -self.tile_height
   end

   self.tiles[full_id] = { quad = inner_quad, offset_y = offset_y }

   if quad then
      quad:release()
   end
end

function atlas:insert_anim(proto, images)
   local id = proto._id
   local anims = {} -- proto.anim

   -- anims = { default = { frames = {{image = "default#1", time = 0.25}} } }

   for anim_id, spec in pairs(images) do
      local frames = {}
      for frame_id=1,spec.count_x do
         local full_id = ("%s#%s:%d"):format(id, anim_id, frame_id)
         frames[frame_id] = { image = full_id, time = 0.25 }
      end
      anims[anim_id] = { frames = frames }
   end

   self.anims[id] = anims
end

local function get_images(image)
   local images
   -- proto.image can have the following formats:
   --
   -- - a string, pointing to a bare image file
   --   + creates animation "default" with one frame
   --
   --     "graphic/chip.png"
   --
   if type(image) == "string" then
      images = {
         default = {
            image = image,
            count_x = 1
         }
      }

   -- - a table, with an image file, frame count and key color
   --   + if count_x/count_y > 1, more than one frame is generated
   --   + creates animation "default" with frames numbered 1, 2, 3, etc.
   --
   --     {
   --       image = "graphic/chip.bmp",
   --       count_x = 1,
   --       key_color = {0, 0, 0}
   --     }
   --
   elseif type(image) == "table" then
      if image.image then
         images = {
            default = image
         }

   -- - a table, pointing to a region on a texture atlas
   --   + if count_x/count_y > 1, more than one frame is generated
   --   + creates animation "default" with frames numbered 1, 2, 3, etc.
   --
   --     {
   --       height = 48,
   --       source = "graphic/map0.bmp",
   --       width = 48,
   --       count_x = 1,
   --       x = 0,
   --       y = 0,
   --       key_color = {0, 0, 0}
   --     }
   --
      elseif image.source then
         images = {
            default = image
         }

   -- - a map of animation names to any of the above.
   --
   --     {
   --       default = "graphic/chip.bmp",
   --       anim1 = { image = "graphic/chip1.bmp", count_x = 2 }
   --     }
   --
      elseif image.default then
         -- TODO
      else
         error("unsupported image type " .. inspect(image))
      end
   else
      error("unsupported image type " .. inspect(image))
   end

   return images
end

--- @tparam proto base.chip
--- @tparam[opt] function draw_tile
function atlas:load_one(proto, draw_tile)
   local id = proto._id
   local images = get_images(proto.image)

   for anim_id, spec in pairs(images) do
      spec.count_x = spec.count_x or 1
      for i = 1, spec.count_x do
         local offset_x = (i-1)*(spec.width or 0)
         self:insert_tile(id, anim_id, i, spec, draw_tile, offset_x, 0)
      end
   end

   self:insert_anim(proto, images)

   self.existing[proto._id] = true
end

function atlas:load(protos, coords, cb)
   assert(self.tile_count_x == nil)
   -- self.coords = coords -- TODO

   self.tiles = {}

   local count = #protos
   self.tile_count_x = 48
   self.tile_count_y = math.ceil(count / 48 + 1) * 2 -- account for tall tiles

   self.image_width = self.tile_width * self.tile_count_x
   self.image_height = self.tile_height * self.tile_count_y
   self.binpack = binpack:new(self.image_width, self.image_height)

   local canvas = love.graphics.newCanvas(self.image_width, self.image_height)

   love.graphics.setCanvas(canvas)
   love.graphics.setBlendMode("alpha")
   love.graphics.setColor(1, 1, 1, 1)

   cb = cb or function(self, proto) self:load_one(proto) end

   for _, proto in ipairs(protos) do
      cb(self, proto)
   end

   Log.info("%d/%d tiles filled.", count, self.tile_count_x * self.tile_count_y)

   love.graphics.setCanvas()

   self.image = love.graphics.newImage(canvas:newImageData())
   canvas:release()

   self.batch = love.graphics.newSpriteBatch(self.image)
end

function atlas:make_anim(tile_id)
   if tile_id == nil then
      return nil
   end

   local anims = self.anims[tile_id]
   if not anims then
      Log.warn("Missing animation for '%s'", tile_id)
      return
   end

   return anim:new(anims, tile_id)
end

function atlas:update_anim(the_anim, tile_id)
   local anims = self.anims[tile_id]
   if not anims then
      Log.warn("Missing animation for '%s' (update)", tile_id)
      return
   end

   the_anim:init(anims, tile_id)
end

function atlas:make_batch()
   return atlas_batch:new(self)
end

return atlas
