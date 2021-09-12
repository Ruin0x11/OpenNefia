local Draw = require("api.Draw")
local IDrawLayer = require("api.gui.IDrawLayer")
local Chara = require("api.Chara")
local Gui = require("api.Gui")

local TargetOverlayLayer = class.class("TargetOverlayLayer", IDrawLayer)

function TargetOverlayLayer:init()
   self.frame = 0.0
   self.w = nil
   self.h = nil
   self.lines = {}
   self.see_all = false
end

function TargetOverlayLayer:default_z_order()
   return Gui.LAYER_Z_ORDER_USER
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

local COLORS = {
   player = {0, 255, 0},
   ally = {0, 0, 255},
   enemy = {255, 0 ,0 }
}

function TargetOverlayLayer:update(map, dt, screen_updated)
   self.frame = self.frame + dt
end

function TargetOverlayLayer:update_lines()
   local i = 1

   for _, chara in Chara.iter() do
      local target = chara:get_target()
      if target and (self.see_all or chara:is_in_fov()) then
         local offset = 0
         local color = COLORS.enemy
         if chara:is_player() then
            color = COLORS.player
            offset = 2
         elseif chara:is_in_player_party() then
            color = COLORS.ally
            offset = 4
         end

         local sx, sy = chara:get_screen_pos()
         local tx, ty = target:get_screen_pos()

         local line = self.lines[i]
         if not line then
            self.lines[i] = {}
            line = self.lines[i]
         end
         line.sx = sx + offset
         line.sy = sy + offset
         line.tx = tx + offset
         line.ty = ty + offset
         line.color = color
         i = i + 1
      end
   end
   self.lines[i] = nil
end

function TargetOverlayLayer:draw(draw_x, draw_y)
   self:update_lines()

   for _, line in ipairs(self.lines) do
      local sx = line.sx + self.w + draw_x
      local sy = line.sy + self.h + draw_y
      local tx = line.tx + self.w + draw_x
      local ty = line.ty + self.h + draw_y
      line.color[4] = 255 - (math.floor(self.frame * 125) % 128)
      Draw.set_color(line.color)
      Draw.line(sx, sy, tx, ty)
      Draw.line_rect(tx - 4, ty - 4, 8, 8)
   end
end

return TargetOverlayLayer
