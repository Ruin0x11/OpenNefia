local IDrawLayer = require("api.gui.IDrawLayer")
local UiTheme = require("api.gui.UiTheme")
local Draw = require("api.Draw")
local config = require("internal.config")
local Map = require("api.Map")
local Gui = require("api.Gui")

local effect_map_layer = class.class("effect_map_layer", IDrawLayer)

function effect_map_layer:init(width, height, coords)
   self.efmap = {}
   self.coords = coords
end

function effect_map_layer:default_z_order()
   return Gui.LAYER_Z_ORDER_TILEMAP + 20000
end

function effect_map_layer:on_theme_switched(coords)
   self.coords = coords
   self.efmap = {}
end

function effect_map_layer:relayout()
   self.t = UiTheme.load(self)
end

function effect_map_layer:reset()
   self.efmap = {}
end

function effect_map_layer:add(asset_id, tx, ty, max_frames, rotation, kind)
   local asset = self.t[asset_id]
   if asset == nil then
      error(("Asset '%s' doesn't exist."):format(asset_id))
   end

   kind = kind or "anime"
   if kind ~= "anime" and kind ~= "fade" then
      error(("Invalid effect map kind '%s'"):format(kind))
   end

   rotation = rotation or 0
   local alpha

   if kind == "anime" then
      max_frames = math.clamp(max_frames or #asset.quads, 0, #asset.quads)
      alpha = 150
   else
      max_frames = math.max(max_frames or 10, 0)
      alpha = max_frames * 12 + 30
   end

   local tw, th = self.coords:get_size()
   local sx, sy = self.coords:tile_to_screen(tx, ty)
   sx = sx + tw / 2
   sy = sy + th / 2
   local map = Map.current()
   local show = map:is_in_fov(tx, ty)

   self.efmap[#self.efmap+1] = {
      asset = asset,
      dt = 0,
      x = sx,
      y = sy,
      tx = tx,
      ty = ty,
      show = show,
      asset_frame = 1,
      frame = 1,
      max_frames = max_frames,
      rotation = rotation,
      kind = kind,
      alpha = alpha
   }
end

function effect_map_layer:step_all(frames)
   local size = #self.efmap
   local i = 1
   while i <= size do
      local ef = self.efmap[i]
      local get = false
      ef.dt = ef.dt + frames

      while ef.dt > 0 do
         ef.dt = ef.dt - 1.0
         ef.frame = ef.frame + 1
         if ef.kind == "anime" then
            ef.asset_frame = ef.frame
         elseif ef.kind == "fade" then
            ef.alpha = (ef.max_frames - ef.frame + 1) * 12 + 30
         end
         if ef.frame > ef.max_frames then
            self.efmap[i] = self.efmap[size]
            self.efmap[size] = nil
            size = size - 1
            get = true
            break
         end
      end
      if not get then
         i = i + 1
      end
   end
end

function effect_map_layer:update(map, dt, screen_updated)
   local frames = dt / (config.base.screen_refresh * (16.66 / 1000))

   self:step_all(frames)

   if not screen_updated then
      return
   end

   for _, ef in ipairs(self.efmap) do
      ef.show = map:is_in_fov(ef.tx, ef.ty)
   end
end

function effect_map_layer:draw(draw_x, draw_y, offx, offy)
   for _, ef in ipairs(self.efmap) do
      if ef.show then
         Draw.set_color(255, 255, 255, ef.alpha)
         ef.asset:draw_region(ef.asset_frame, draw_x + ef.x, draw_y + ef.y, nil, nil, nil, true, ef.rotation)
      end
   end
end

return effect_map_layer
