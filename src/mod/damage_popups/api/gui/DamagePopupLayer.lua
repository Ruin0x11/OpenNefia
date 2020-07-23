local Draw = require("api.Draw")
local IDrawLayer = require("api.gui.IDrawLayer")

local easing = require("mod.damage_popups.lib.easing")

local DamagePopupLayer = class.class("DamagePopupLayer", IDrawLayer)

function DamagePopupLayer:init()
   self.w = nil
   self.h = nil
   self.icons = {}
end

function DamagePopupLayer:on_theme_switched(coords)
   self.coords = Draw.get_coords()
   self.w, self.h = self.coords:get_size()
   self.w = math.floor(self.w/2)
   self.h = math.floor(self.h/2)
end

function DamagePopupLayer:relayout()
end

function DamagePopupLayer:reset()
   self.icons = {}
   save.damage_popups.popups = { count = 0 }
end

local max_frame = 40

function DamagePopupLayer:update(dt, screen_updated)
   local dead = {}
   local popups = save.damage_popups.popups or {}

   for i, v in ipairs(popups) do
      v.frame = v.frame + dt * 50
      local alpha = math.min(easing.outQuint(1 - (v.frame / max_frame), 0, 1, 1) * 255, 255)
      v.color[4] = alpha
      v.shadow_color[4] = alpha
      if v.frame > max_frame then
         dead[#dead+1] = i
      end
   end

   if #dead > 0 then
      popups.count = popups.count - #dead
      table.remove_indices(popups, dead)
   end
end

function DamagePopupLayer:draw(draw_x, draw_y)
   local popups = save.damage_popups.popups or {}
   local sx, sy = self.coords:get_start_offset(draw_x, draw_y)
   for _, v in ipairs(popups) do
      local x, y = self.coords:tile_to_screen(v.x+1, v.y+1)
      local font_size = v.font

      Draw.set_font(font_size)
      x = x - draw_x - math.floor(Draw.text_width(v.text)) + sx + self.w
      y = y - draw_y - math.floor(Draw.text_height() / 2) - 2 * (v.frame + 30) + sy + self.h
      Draw.text_shadowed(v.text, x, y, v.color, v.shadow_color)
   end
end

return DamagePopupLayer
