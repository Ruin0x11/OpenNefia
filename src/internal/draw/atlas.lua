local anim = require("internal.draw.anim")
local asset_drawable = require("internal.draw.asset_drawable")
local binpack = require("thirdparty.binpack")
local Log = require("api.Log")

local atlas = class.class("atlas")

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

   -- blank fallback in case of missing filepath.
   local fallback_data = love.image.newImageData(self.tile_width, self.tile_height)
   self.fallback = love.graphics.newImage(fallback_data)
end

function atlas:insert_tile(id, frame_id, filepath_or_data, load_tile)
   local full_id = ("%s#%s"):format(id, frame_id)
   if self.tiles[full_id] then
      error(string.format("tile %s already loaded", full_id))
   end

   local tile
   local need_release
   if class.is_an(asset_drawable, filepath_or_data) then
      -- This image is an asset from a UI theme that's being used; do
      -- not release it.
      tile = filepath_or_data.image
      need_release = false
   else
      -- We're creating a temporary image that will only be used for
      -- blitting into the atlas; discard it after.
      tile = love.graphics.newImage(filepath_or_data)
      need_release = true
   end
   assert(tile, filepath_or_data)

   local rect = self.binpack:insert(tile:getWidth(), tile:getHeight())
   assert(rect, filepath_or_data)

   if load_tile then
      load_tile(tile, rect.x, rect.y)
   elseif self.coords then
      self.coords:load_tile(tile, rect.x, rect.y)
   else
      love.graphics.draw(tile, rect.x, rect.y)
   end

   local is_tall = tile:getHeight() == self.tile_height * 2
   local quad
   if is_tall then
      quad = love.graphics.newQuad(rect.x,
                                   rect.y,
                                   self.tile_width,
                                   self.tile_height * 2,
                                   self.image_width,
                                   self.image_height)
   else
      quad = love.graphics.newQuad(rect.x,
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

   self.tiles[full_id] = { quad = quad, offset_y = offset_y }

   if need_release then
      tile:release()
   end
end

function atlas:insert_anim(proto, images)
   local id = proto._id
   local anims = proto.anim
   if anims == nil then
      local frames = {}
      for i=1,table.count(images) do
         local frame_id = "default"
         if i > 1 then
            frame_id = "default_" .. i
         end
         if images[frame_id] then
            frames[#frames+1] = { id = frame_id, time = 0.25 }
         else
            break
         end
      end
      assert(#frames > 0)
      anims = {default = {frames = frames}}
   end

   if anims[1] then
      local frames = anims
      anims = {default = {frames = frames}}
   end
   for _, anim_data in pairs(anims) do
      for _, frame in ipairs(anim_data.frames) do
         frame.image = ("%s#%s"):format(id, frame.id)
      end
   end
   self.anims[id] = anims
end

function atlas:load_one(proto, draw_tile)
   local id = proto._id
   local images = proto.image

   if type(images) == "table"
      and (type(images[1]) == "string"
              or class.is_an(asset_drawable, images[1]))
   then
      local new_images = {}
      for i, image_file in ipairs(images) do
         local frame_id = "default"
         if i > 1 then
            frame_id = "default_" .. i
         end
         print(frame_id, image_file)
         new_images[frame_id] = image_file
      end
      images = new_images
   elseif type(images) == "string"
      or class.is_an(asset_drawable, images)
   then
      images = {default = images}
   end

   assert(type(images) == "table")
   assert(images.default, id .. " must have 'default' image")

   for frame_id, v in pairs(images) do
      self:insert_tile(id, frame_id, v, draw_tile)
   end

   self:insert_anim(proto, images)
end

function atlas:hotload(proto)
   -- TODO
   -- make atlas image into canvas
   -- if new prototype, attempt to fit sprite into atlas
   -- if existing, find location of sprite and overwrite it
   -- insert/update anim
   -- same logic as :load() except without wiping everything
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

   local cb = cb or function(self, proto) self:load_one(proto) end

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
   assert(anims)

   return anim:new(anims, tile_id)
end

function atlas:update_anim(the_anim, tile_id)
   local anims = self.anims[tile_id]
   assert(anims)

   the_anim:init(anims, tile_id)
end

function atlas:copy_tile_image(tile_id)
   local tile = self.tiles[tile_id]
   local image

   if tile then
      love.graphics.setColor(1, 1, 1) -- TODO allow change?

      local _, _, tw, th = tile.quad:getViewport()
      local canvas = love.graphics.newCanvas(tw, th)
      love.graphics.setCanvas(canvas)

      love.graphics.draw(self.image, tile.quad, 0, tile.y_offset)

      love.graphics.setCanvas()
      image = love.graphics.newImage(canvas:newImageData())
      canvas:release()
   else
      image = self.fallback
   end

   return asset_drawable:new(image)
end

return atlas
