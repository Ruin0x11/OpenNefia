local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")

local CardDrawable = class.class("CardDrawable", IDrawable)

function CardDrawable:init(chip_id, color)
   local coords = Draw.get_coords()
   self.tw, self.th = coords:get_size()
   self.dirty = true
   self.batch = nil
   self.chip_id = chip_id
   self.color = color
end

function CardDrawable:deserialize()
   self.dirty = true
end

function CardDrawable:update(dt)
end

function CardDrawable:draw(x, y, w, h, centered, rot)
   if self.dirty then
      self.batch = Draw.make_chip_batch("chip")
      self.dirty = false
   end

   -- >>>>>>>> shade2/module.hsp:576 	:if %%1=528:gmode 2:pos 0,960:gcopy selItem,0,768, ...
   if self.chip_id and self.chip_id ~= "" then
      Draw.set_color(255, 255, 255, 255)
      self.batch:clear()
      self.batch:add(self.chip_id, x + 6, y + 14, 22, 20, self.color)
      self.batch:draw()
   end
   -- <<<<<<<< shade2/module.hsp:576 	:if %%1=528:gmode 2:pos 0,960:gcopy selItem,0,768, ..
end

return CardDrawable
