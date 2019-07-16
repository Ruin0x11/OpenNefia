local Draw = require("api.Draw")
local IDrawLayer = require("api.gui.IDrawLayer")

local easing = require("mod.damage_popups.lib.easing")

local DamagePopupLayer = class.class("DamagePopupLayer", IDrawLayer)

function DamagePopupLayer:init()
   self.coords = Draw.get_coords()
   self.icons = {}
   self.w, self.h = self.coords:get_size()
   self.w = math.floor(self.w/2)
   self.h = math.floor(self.h/2)
end

function DamagePopupLayer:relayout()
end

function DamagePopupLayer:reset()
   self.icons = {}
end

local max_frame = 40

local g_popups = require("mod.damage_popups.g_popups")

function DamagePopupLayer:update(dt, screen_updated)
   local dead = {}

   for i, v in ipairs(g_popups) do
      v.frame = v.frame + dt * 50
      if v.frame > max_frame then
         dead[#dead+1] = i
      end
   end

   if #dead > 0 then
      g_popups = table.remove_indices(g_popups, dead)
   end
end

function DamagePopupLayer:draw(draw_x, draw_y)
   local sx, sy = self.coords:get_start_offset(draw_x, draw_y)
   for _, v in ipairs(g_popups) do
      local x, y = self.coords:tile_to_screen(v.x+1, v.y+1)
      local font_size = v.font

      Draw.set_font(font_size)
      x = x - math.floor(Draw.text_width(v.text)) - sx + self.w
      y = y - math.floor(Draw.text_height() / 2) - 2 * v.frame - sy + self.h
      Draw.text_shadowed(v.text, x, y, v.color)

      local cx, cy = self.coords:tile_to_screen(0, 0)
   end
end

return DamagePopupLayer
