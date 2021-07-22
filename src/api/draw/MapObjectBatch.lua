local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")

local MapObjectBatch = class.class("MapObjectBatch", IDrawable)

function MapObjectBatch:init(the_atlas)
   self.batch = Draw.make_chip_batch("chip")
   self.memory_idx = 0
   self.memory = {}
   self.objs = {}
end

function MapObjectBatch:add(map_object, x, y, width, height, color, centered, rotation)
   local memory
   self.memory_idx = self.memory_idx + 1
   if self.memory[self.memory_idx] == nil then
      self.memory[self.memory_idx] = {}
   end
   memory = self.memory[self.memory_idx]
   map_object:produce_memory(memory)

   local drawable_x = x
   local drawable_y = y
   if centered then
      local tw, th = self:tile_size(memory.image)
      drawable_x = x - tw / 2
      if th == 48 then
         drawable_y = y - th / 2
      end
   end

   self.objs[self.memory_idx] = {
      x = x,
      y = y,
      drawable_x = drawable_x,
      drawable_y = drawable_y,
      width = width,
      height = height,
      color = color,
      centered = centered,
      rotation = rotation
   }
end

function MapObjectBatch:get_width()
   return self.batch:get_width()
end

function MapObjectBatch:get_height()
   return self.batch:get_height()
end

function MapObjectBatch:tile_size(chip)
   return self.batch:tile_size(chip)
end

function MapObjectBatch:clear()
   self.batch:clear()
   self.memory_idx = 0
end

function MapObjectBatch:update(dt)
   for _, memory in ipairs(self.memory) do
      if memory.drawables and memory.drawables:len() > 0 then
         for _, drawable in memory.drawables:iter() do
            drawable:update(dt)
         end
      end

      if memory.drawables_after and memory.drawables_after:len() > 0 then
         for _, drawable in memory.drawables_after:iter() do
            drawable:update(dt)
         end
      end
   end
end

function MapObjectBatch:draw(x, y, w, h)
   x = x or 0
   y = y or 0

   local function draw_batch()
      self.batch:draw(x, y, w, h)
      self.batch:clear()
   end

   self.batch:clear()

   local in_drawable = false
   local pending = false
   for i = 1, self.memory_idx do
      local memory = self.memory[i]
      local obj = self.objs[i]

      if memory.drawables and memory.drawables:len() > 0 then
         if not in_drawable then
            draw_batch()
            pending = false
            in_drawable = true
         end

         for _, drawable in memory.drawables:iter() do
            if drawable:is_drawable_in_ui() then
               drawable:draw(x + obj.drawable_x, y + obj.drawable_y, obj.width, obj.height, obj.centered, obj.rotation)
            end
         end
      end

      if memory.image then
         in_drawable = false
         pending = true
         self.batch:add(memory.image, obj.x, obj.y, obj.width, obj.height, obj.color or memory.color, obj.centered, obj.rotation)
      end

      if memory.drawables_after and memory.drawables_after:len() > 0 then
         if not in_drawable then
            draw_batch()
            pending = false
            in_drawable = true
         end

         for _, drawable in memory.drawables_after:iter() do
            if drawable:is_drawable_in_ui() then
               drawable:draw(x + obj.drawable_x, y + obj.drawable_y, obj.width, obj.height, obj.centered, obj.rotation)
            end
         end
      end
   end

   if pending then
      draw_batch()
   end
end

function MapObjectBatch:release()
   self.batch:release()
end

return MapObjectBatch
