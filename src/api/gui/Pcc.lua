local Draw = require("api.Draw")
local SkipList = require("api.SkipList")
local IChipRenderable = require("api.gui.IChipRenderable")
local bmp_convert = require("internal.bmp_convert")
local data = require("internal.data")
local Log = require("api.Log")

local Pcc = class.class("Pcc", IChipRenderable)

Pcc.COLORS = {
   { 255, 255, 255 },
   { 175, 255, 175 },
   { 255, 155, 155 },
   { 175, 175, 255 },
   { 255, 215, 175 },
   { 255, 255, 175 },
   { 155, 154, 153 },
   { 185, 155, 215 },
   { 155, 205, 205 },
   { 255, 195, 185 },
   { 235, 215, 155 },
   { 225, 215, 185 },
   { 105, 235, 105 },
   { 205, 205, 205 },
   { 255, 225, 225 },
   { 225, 225, 255 },
   { 225, 195, 255 },
   { 215, 255, 215 },
   { 210, 250, 160 },
}

Pcc.DEFAULT_Z_ORDER = {
   mantle = 1000,
   hairbk = 2000,
   ridebk = 3000,
   body = 4000,
   eye = 5000,
   pants = 6000,
   cloth = 7000,
   chest = 8000,
   leg = 9000,
   belt = 10000,
   glove = 11000,
   ride = 12000,
   mantlebk = 13000,
   hair = 14000,
   subhair = 15000,
   etc = 16000,
   boots = 17000,
}

function Pcc:init(parts)
   self.parts = SkipList:new()

   -- { id = "elona.etc_10", z_order = 100 }
   for _, part in ipairs(parts) do
      local entry = data["base.pcc_part"]:ensure(part.id)
      assert(entry.image)
      self.parts:insert(part.z_order or Pcc.DEFAULT_Z_ORDER[entry.kind] or 100000,
                        {
                           _id = entry._id,
                           kind = entry.kind,
                           image = entry.image,
                           key_color = entry.key_color,
                           color = part.color
                        })
   end

   self.dirty = true
   self.image = nil
   self.frame = 1
   self.dir = 1
   self.full_size = false

   self.quads = {}
end

function Pcc:deserialize()
   self.dirty = true
end

function Pcc:refresh()
   local canvas = love.graphics.newCanvas(128, 192)

   Draw.with_canvas(canvas, function()
                       for _, _, part in self.parts:iterate() do
                          local image = assert(bmp_convert.load_image(part.image, part.key_color))
                          if part.color then
                             Draw.set_color(part.color)
                          else
                             Draw.set_color(255, 255, 255)
                          end
                          love.graphics.draw(image, 0, 0)
                       end
   end)

   Draw.set_color(255, 255, 255)

   if self.image then
      self.image:release()
   end
   self.image = love.graphics.newImage(canvas:newImageData())
   self.image:setFilter("nearest", "nearest", 1)

   canvas:release()

   for i = 1, 16 do
      local x = math.floor((i-1) / 4)
      local y = (i-1) % 4
      self.quads[i] = love.graphics.newQuad(x * 32, y * 48, 32, 48, 128, 192)
   end

   self.dirty = false
end

function Pcc:release()
   self.image:release()
end

function Pcc:on_scroll()
   self.frame = (self.frame + 1) % 16
end

function Pcc:draw(x, y, scale_x, scale_y)
   if self.dirty then
      self:refresh()
   end

   local width, height, offset_x, offset_y
   scale_x = scale_x or 1.0
   scale_y = scale_y or 1.0

   if self.full_size then
      width = 32
      height = 48
      offset_x = 8
      offset_y = -4
   else
      width = 24
      height = 40
      offset_x = 12
      offset_y = 4
   end

   local index = self.dir + (self.frame - 1) * 4
   -- Log.info("frame %d", index)
   local quad = self.quads[index]
   if quad == nil then
      return
   end

   Draw.set_color(255, 255, 255)
   Draw.image_region(self.image, quad, x + offset_x, y + offset_y, width * scale_x, height * scale_y)
end

return Pcc
