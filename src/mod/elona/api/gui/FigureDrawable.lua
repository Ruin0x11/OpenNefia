local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")
local Gui = require("api.Gui")

local FigureDrawable = class.class("FigureDrawable", IDrawable)

function FigureDrawable:init(chip_id, color)
   local coords = Draw.get_coords()
   self.tw, self.th = coords:get_size()
   self.batch = Draw.make_chip_batch("chip")
   self.chip_id = chip_id
   self.color = color or { 255, 255, 255 }
   self.color[4] = 150
end

function FigureDrawable:update(dt)
end

function FigureDrawable:draw(x, y, w, h, centered, rot)
   -- >>>>>>>> shade2/module.hsp:577 	:if %%1=531:pos 8,1058-chipCh(%%2):gcopy selChr,chi ...
   if self.chip_id and self.chip_id ~= "" then
      Draw.set_color(255, 255, 255, 255)
      self.batch:clear()
      self.batch:add(self.chip_id, x, y, nil, nil, self.color)
      self.batch:draw()
   end
   -- <<<<<<<< shade2/module.hsp:577 	:if %%1=531:pos 8,1058-chipCh(%%2):gcopy selChr,chi ..
end

return FigureDrawable
