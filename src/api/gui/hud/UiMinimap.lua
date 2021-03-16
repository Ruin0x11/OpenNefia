local IUiWidget = require("api.gui.IUiWidget")
local UiTheme = require("api.gui.UiTheme")
local Draw = require("api.Draw")

local UiMinimap = class.class("UiMinimap", IUiWidget)

function UiMinimap:init()
   self.tw = 0
   self.th = 0
   self.tile_batch = nil
   self.blocked_batch = nil
   self.player = nil
end

function UiMinimap:default_widget_position(x, y, width, height)
   return 1, height - (16 + 72), 120, 16 + 72
end

function UiMinimap:default_widget_refresh(player)
   self.player = player
end

function UiMinimap:default_widget_z_order()
   return 70000
end

function UiMinimap:relayout(x, y, width, height)
   local Map = require("api.Map")
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)
   self.tile_batch = Draw.make_chip_batch("tile")
   self.blocked_batch = Draw.make_chip_batch("chip")
   self:refresh_visible(Map.current())
end

local SUBTRACT_COLOR = { 100, 100, 100 }

function UiMinimap:update(dt, map, screen_updated)
   if not screen_updated then
      return
   end
   self:refresh_visible(map)
end

function UiMinimap:refresh_visible(map)
   if not self.tile_batch then
      return
   end

   if map == nil then
      return
   end

   local mw = map:width()
   local mh = map:height()
   self.tw = self.width / mw
   self.th = self.height / mh

   self.tile_batch:clear()

   -- >>>>>>>> shade2/screen.hsp:1270 *rader_preDraw ..
   for ind = 1, mw * mh do
      local x = (ind-1) % mw
      local y = math.floor((ind-1) / mw)
      local memory = map._memory["base.map_tile"]
      if memory and memory[ind] and memory[ind][1] then
         local tile = memory[ind][1]

         local sx, sy, sw, sh = math.ceil(x * self.tw), math.ceil(y * self.th), math.ceil(self.tw), math.ceil(self.th)

         self.tile_batch:add(tile._id, sx, sy, sw, sh)

         if tile.is_solid then
            -- Decrement color on top of impassable tiles.
            self.blocked_batch:add("base.white", sx, sy, sw, sh, SUBTRACT_COLOR)
         end
      end
   end
   -- <<<<<<<< shade2/screen.hsp:1290 	return ..
end

function UiMinimap:draw()
   -- TODO correct offsets
   Draw.set_color(255, 255, 255)
   self.t.base.hud_minimap:draw(self.x, self.y+1)

   self.tile_batch:draw(self.x, self.y+3, self.width, self.height)

   Draw.set_blend_mode("subtract")
   self.blocked_batch:draw(self.x, self.y+3, self.width, self.height)

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

return UiMinimap
