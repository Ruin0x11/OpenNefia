local IComparable = require("api.IComparable")
local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")

local FigurineDrawable = class.class("FigurineDrawable", { IDrawable, IComparable })

function FigurineDrawable:init(chip_id, color)
   self.batch = nil
   self.dirty = true
   self.chip_id = chip_id
   self.color = color or { 255, 255, 255 }
   self.color[4] = 150
end

function FigurineDrawable:serialize()
   self.batch = nil
end

function FigurineDrawable:deserialize()
   self.dirty = true
end

function FigurineDrawable:update(dt)
end

function FigurineDrawable:draw(x, y, w, h, centered, rot)
   if self.dirty then
      self.batch = Draw.make_chip_batch("chip")
      self.dirty = false
   end

   -- >>>>>>>> shade2/module.hsp:577 	:if %%1=531:pos 8,1058-chipCh(%%2):gcopy selChr,chi ...
   if self.chip_id and self.chip_id ~= "" then
      local width, height = self.batch:tile_size(self.chip_id)
      Draw.set_color(255, 255, 255, 255)
      self.batch:clear()
      self.batch:add(self.chip_id, x+8, y+2 - (height-48), width-16, height-8, self.color)
      self.batch:draw()
   end
   -- <<<<<<<< shade2/module.hsp:577 	:if %%1=531:pos 8,1058-chipCh(%%2):gcopy selChr,chi ..
end

function FigurineDrawable:compare(other)
   if self.chip_id ~= other.chip_id then
      return false
   end

   if self.color and other.color then
      return table.deepcompare(self.color, other.color)
   end

   return self.color == nil and other.color == nil
end

return FigurineDrawable
