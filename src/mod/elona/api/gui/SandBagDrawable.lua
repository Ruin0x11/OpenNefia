local IComparable = require("api.IComparable")
local IDrawable = require("api.gui.IDrawable")
local Draw = require("api.Draw")

local SandBagDrawable = class.class("SandBagDrawable", { IDrawable, IComparable })

function SandBagDrawable:init(chip_id, color)
   self.dirty = true
   self.batch = nil
   self.chip_id = chip_id or "elona.item_sand_bag"
   self.color = color or {255, 255, 255}

   local proto = data["base.chip"]:ensure(self.chip_id)
   self.y_offset = proto.y_offset or 0
end

function SandBagDrawable:serialize()
   self.batch = nil
end

function SandBagDrawable:deserialize()
   self.dirty = true
end

function SandBagDrawable:update(dt)
end

function SandBagDrawable:draw(x, y, w, h, centered, rot)
   if self.dirty then
      self.batch = Draw.make_chip_batch("chip")
      self.dirty = false
   end

   -- >>>>>>>> shade2/module.hsp:576 	:if %%1=528:gmode 2:pos 0,960:gcopy selItem,0,768, ...
   if self.chip_id and self.chip_id ~= "" then
      Draw.set_color(255, 255, 255, 255)
      self.batch:clear()
      self.batch:add(self.chip_id, x, y + self.y_offset, nil, nil, self.color)
      self.batch:draw()
   end
   -- <<<<<<<< shade2/module.hsp:576 	:if %%1=528:gmode 2:pos 0,960:gcopy selItem,0,768, ..
end

function SandBagDrawable:compare(other)
   if self.chip_id ~= other.chip_id then
      return false
   end

   if self.color and other.color then
      return table.deepcompare(self.color, other.color)
   end

   return self.color == nil and other.color == nil
end

return SandBagDrawable
