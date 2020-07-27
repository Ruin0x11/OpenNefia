local Curve = require("mod.skill_tracker_ex.api.gui.Curve")

local ColorBand = class.class("ColorBand")

function ColorBand:init(colors)
   self.colors = colors or {}
   self.bands = {}
   for i = 1, 4 do
      local band = Curve:new()
      for _, pair in ipairs(colors) do
         local color = pair.color
         local time = pair.time
         assert(color and time)
         local component = color[i] or 255
         band:insert_keyframe({time = time, value = component})
      end
      self.bands[i] = band
   end
end

function ColorBand:evaluate(t)
   local c = {}
   for i = 1, 4 do
      c[i] = math.floor(self.bands[i]:evaluate(t))
   end
   return c
end

return ColorBand
