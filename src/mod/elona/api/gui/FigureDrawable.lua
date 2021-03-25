local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")

local FigureDrawable = class.class("FigureDrawable", IDrawable)

function FigureDrawable:init(chip_id, color)
   self.batch = nil
   self.dirty = true
   self.chip_id = chip_id
   self.color = color or { 255, 255, 255 }
   self.color[4] = 150
end

function FigureDrawable:serialize()
   self.batch = nil
end

function FigureDrawable:deserialize()
   self.dirty = true
end

function FigureDrawable:update(dt)
end

function FigureDrawable:draw(x, y, w, h, centered, rot)
   if self.dirty then
      self.batch = Draw.make_chip_batch("chip")
      self.dirty = false
   end

   local width, height = self.batch:tile_size(self.chip_id)

   -- >>>>>>>> shade2/module.hsp:577 	:if %%1=531:pos 8,1058-chipCh(%%2):gcopy selChr,chi ...
   if self.chip_id and self.chip_id ~= "" then
      Draw.set_color(255, 255, 255, 255)
      self.batch:clear()
      self.batch:add(self.chip_id, x+8, y+2, width-16, height-8, self.color)
      self.batch:draw()
   end
   -- <<<<<<<< shade2/module.hsp:577 	:if %%1=531:pos 8,1058-chipCh(%%2):gcopy selChr,chi ..
end

return FigureDrawable
