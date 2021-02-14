local Draw = require("api.Draw")
local IDrawLayer = require("api.gui.IDrawLayer")
local Chara = require("api.Chara")
local Map = require("api.Map")

local TargetOverlayLayer = class.class("TargetOverlayLayer", IDrawLayer)

function TargetOverlayLayer:init()
   self.frame = 0.0
   self.w = nil
   self.h = nil
   self.lines = {}
   self.see_all = false
end

function TargetOverlayLayer:on_theme_switched(coords)
   self.coords = Draw.get_coords()
   self.w, self.h = self.coords:get_size()
   self.w = math.floor(self.w/2)
   self.h = math.floor(self.h/2)
end

function TargetOverlayLayer:relayout()
end

function TargetOverlayLayer:reset()
   self.lines = {}
end

function TargetOverlayLayer:update(dt, screen_updated)
   self.frame = self.frame + dt
   if not screen_updated then
      return
   end

   local map = Map.current()

   self.lines = {}

   for _, chara in Chara.iter(map) do
      local target = chara:get_target()
      if target and (self.see_all or chara:is_in_fov()) then
         local offset = 0
         local color = { 255, 0, 0 }
         if chara:is_player() then
            color = { 0, 255, 0 }
            offset = 2
         elseif chara:is_in_player_party() then
            color = { 0, 0, 255 }
            offset = 4
         end

         local sx, sy = self.coords:tile_to_screen(chara.x + 1, chara.y + 1)
         local tx, ty = self.coords:tile_to_screen(target.x + 1, target.y + 1)

         local line = {
            sx = sx + offset,
            sy = sy + offset,
            tx = tx + offset,
            ty = ty + offset,
            color = color
         }
         self.lines[#self.lines+1] = line
      end
   end
end

function TargetOverlayLayer:draw(draw_x, draw_y)
   local start_x, start_y = self.coords:get_start_offset(draw_x, draw_y)
   for _, line in ipairs(self.lines) do
      local sx = line.sx + self.w + start_x - draw_x
      local sy = line.sy + self.h + start_y - draw_y
      local tx = line.tx + self.w + start_x - draw_x
      local ty = line.ty + self.h + start_y - draw_y
      line.color[4] = 255 - (math.floor(self.frame * 125) % 128)
      Draw.set_color(line.color)
      Draw.line(sx, sy, tx, ty)
      Draw.line_rect(tx - 4, ty - 4, 8, 8)
   end
end

return TargetOverlayLayer
