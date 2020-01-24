local Draw = require("api.Draw")
local SkipList = require("api.SkipList")
local IChipRenderable = require("api.gui.IChipRenderable")
local data = require("internal.data")

local Pcc = class.class("Pcc", IChipRenderable)

function Pcc:init(parts)
   self.parts = SkipList:new()

   -- { id = "elona.etc_10", z_order = 100 }
   for _, part in ipairs(parts) do
      local entry = data["base.pcc_part"]:ensure(part.id)
      assert(entry.image)
      self.parts:insert(part.z_order, {image = entry.image, color = part.color})
   end

   self.image = nil
   self.frame = 1
   self.dir = 1
   self.quads = {}
   self.full_size = false
   for i = 1, 16 do
      local x = math.floor((i-1) / 4)
      local y = (i-1) % 4
      self.quads[i] = love.graphics.newQuad(x * 32, y * 48, 32, 48, 128, 192)
   end
end

function Pcc:refresh()
   local canvas = love.graphics.newCanvas(128, 192)

   Draw.with_canvas(canvas, function()
                       for _, _, part in self.parts:iterate() do
                          local image = assert(love.graphics.newImage(part.image))
                          if part.color then
                             Draw.set_color(part.color)
                          else
                             Draw.set_color(255, 255, 255)
                          end
                          love.graphics.draw(image, 0, 0)
                          image:release()
                       end
   end)

   Draw.set_color(255, 255, 255)

   if self.image then
      self.image:release()
   end
   self.image = love.graphics.newImage(canvas:newImageData())

   canvas:release()
end

function Pcc:release()
   self.image:release()
end

function Pcc:on_scroll()
   self.frame = (self.frame + 1) % 16
end

function Pcc:draw(x, y)
   local width, height
   local offset_x = 0
   local offset_y = 0
   if self.full_size then
      offset_x = 6
      offset_y = 2
   else
      width = 24
      height = 40
      offset_x = 12
      offset_y = 4
   end

   Draw.image_region(self.image, self.quads[self.dir + (self.frame-1) * 4], x + offset_x, y + offset_y, width, height)
end

return Pcc
