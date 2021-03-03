local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local UiTheme = require("api.gui.UiTheme")

local Scroll = class.class("Scroll", IUiElement)

function Scroll:init(shadow)
   self.shadow = shadow or false
end

function Scroll:draw()
   Draw.image(self.batch, 0, 0)
end

function Scroll:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load()

   local x_inner = width + x - width % 8 - 64
   local y_inner = height + y - height % 8 - 64

   y_inner = math.max(y_inner, y + 14)

   local parts = {}

   if not self.shadow then
      parts[#parts+1] = { "top_left", x, y }
   end
   parts[#parts+1] = { "top_right", x_inner, y }
   parts[#parts+1] = { "bottom_left", x, y_inner }
   parts[#parts+1] = { "bottom_right", x_inner, y_inner }

   for dx=8, width / 8 - 8 - 1 do
      local tile = (dx - 8) % 18 + 1
      if not self.shadow then
         parts[#parts+1] = { "top_mid_" .. tile, dx * 8 + x, y }
      end
      parts[#parts+1] = { "bottom_mid_" .. tile, dx * 8 + x, y_inner }
   end

   for dy=0, height / 8 - 14 do
      local tile_y = dy % 12 + 1
      if not self.shadow then
         parts[#parts+1] = { "mid_left_" .. tile_y, x, dy * 8 + y + 48 }

         for dx=1, width / 8 - 15 do
            local tile_x = (dx - 8) % 18 + 1
            parts[#parts+1] = { "mid_mid_" .. tile_y .. "_" .. tile_x, dx * 8 + x + 56, dy * 8 + y + 48 }
         end
      end
      parts[#parts+1] = { "mid_right_" .. tile_y, x_inner, dy * 8 + y + 48 }
   end

   self.i_scroll = self.t.base.ie_scroll:make_instance()
   self.batch = self.i_scroll:make_batch(parts)
end

function Scroll:update()
end

return Scroll
