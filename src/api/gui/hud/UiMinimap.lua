local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local Draw = require("api.Draw")

local UiMinimap = class.class("UiMinimap", IUiWidget)

function UiMinimap:init()
   self.tw = 0
   self.th = 0
   self.tile_batch = nil
   self.player = nil
end

function UiMinimap:default_widget_position(x, y, width, height)
   return 1, height - (16 + 72), 120, 16 + 72
end

function UiMinimap:default_widget_refresh(player)
   self.player = player
   self:refresh_visible()
end

function UiMinimap:default_widget_z_order()
   return 70000
end

function UiMinimap:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
   self.tile_batch = Draw.make_chip_batch("tile")
   self:refresh_visible()
end

local Map

local SUBTRACT_COLOR = { 155, 155, 155 }

function UiMinimap:refresh_visible(map)
   if not self.tile_batch then
      return
   end

   Map = Map or require("api.Map")
   map = map or Map.current()
   if map == nil then
      return
   end

   self.tw = math.ceil(self.width / map:width())
   self.th = math.ceil(self.height / map:height())

   self.tile_batch:clear()

   -- >>>>>>>> shade2/screen.hsp:1270 *rader_preDraw ..
   for _, x, y, tile in map:iter_tiles() do
      if map:is_memorized(x, y) then
         local color
         if tile.is_solid then
            -- TODO Use subtractive blending, since the original code uses
            -- `gfdec2` on top of impassible tiles. Essentially, draw another
            -- sprite batch for blending purposes only with squares of either
            -- black or {100, 100, 100} if the tile is not accessable. Then draw
            -- the sprite batch with alpha blending, turn on subtractive
            -- blending, then draw the blending sprite batch on top of the first
            -- sprite batch.
            color = SUBTRACT_COLOR
         end
         self.tile_batch:add(tile._id, math.ceil(x * self.tw), math.ceil(y * self.th), self.tw, self.th, color)
      end
   end
   -- <<<<<<<< shade2/screen.hsp:1290 	return ..
end

function UiMinimap:draw()
   -- TODO correct offsets
   Draw.set_color(255, 255, 255)
   self.t.base.hud_minimap:draw(self.x, self.y+1)
   self.tile_batch:draw(self.x, self.y+3, self.width, self.height)
   Draw.set_blend_mode("add")
   Draw.set_color(10, 10, 10)
   Draw.filled_rect(self.x, self.y+1, self.width, self.height)
   Draw.set_blend_mode("alpha")

   -- >>>>>>>> shade2/screen.hsp:1141 	screenDrawHack=4 ..
   if self.player then
      local x = math.clamp(self.player.x * self.tw, 2, self.width - 8)
      local y = math.clamp(self.player.y * self.th, 2, self.height - 8)
      Draw.set_color(255, 255, 255)
      self.t.base.minimap_marker_player:draw(self.x + x, self.y + y)
   end
   -- <<<<<<<< shade2/screen.hsp:1148 	pos inf_raderX+sx,inf_raderY+sy:gcopy SelInf,15,3 ..
end

function UiMinimap:update(dt)
end

return UiMinimap
