local Draw = require("api.Draw")
local IDrawLayer = require("api.gui.IDrawLayer")
local Rand = require("api.Rand")
local UiTheme = require("api.gui.UiTheme")
local Chara = require("api.Chara")
local Gui = require("api.Gui")

local CloudLayer = class.class("CloudLayer", IDrawLayer)

function CloudLayer:init()
   self.frame = 0.0
   self.scale = 0.0
   self.speed = 10
   self.cloud_count = 12
   self.clouds = {}
   self.coords = Draw.get_coords()

   self:init_clouds()
end

function CloudLayer:init_clouds()
   self.clouds = {}
   -- >>>>>>>> shade2/chips.hsp:188 *cloud_init ...
   for i = 1, self.cloud_count do
      local cloud_asset = Rand.choice { "base.cloud_1", "base.cloud_2" }
      self.clouds[#self.clouds+1] = {
         asset_id = cloud_asset,
         x = Rand.rnd(100) + (i-1) * 200 + 100000,
         y = Rand.rnd(100) + (i-1 / 5) * 200 + 100000
      }
   end
   -- <<<<<<<< shade2/chips.hsp:196 	return ..
end

function CloudLayer:on_theme_switched(coords)
   self.coords = Draw.get_coords()
   self.t = UiTheme.load(self)
end

function CloudLayer:relayout()
   self.coords = Draw.get_coords()
   self.t = UiTheme.load(self)
end

function CloudLayer:reset()
   self:init_clouds()
end

function CloudLayer:update(dt, screen_updated)
   self.frame = self.frame + dt / (config.base.screen_refresh * (16.66 / 1000))
   if not screen_updated then
      return
   end
end

function CloudLayer:draw(draw_x, draw_y)
   -- >>>>>>>> shade2/module.hsp:1079 	if mType=mTypeWorld{ ...
   local player = Chara.player()
   local cx = (player and player.x) or 0
   local cy = (player and player.y) or 0

   for i, cloud in ipairs(self.clouds) do
      Draw.set_blend_mode("subtract")

      Draw.set_color(255, 255, 255, 7 + (i-1) * 2)
      local x, y = self.coords:tile_to_screen(cloud.x - cx, cloud.y - cy)
      x = (x * 100 / (40 + (i-1) * 5)) + ((self.frame * self.speed) * 100 / (50 + (i-1) * 20))
      y = y * 100 / (40 + (i-1) * 5)

      local asset = self.t[cloud.asset_id]
      x = x % (Draw.get_width() + asset:get_width()) - asset:get_width()
      y = y % (Gui.message_window_y() + asset:get_height()) - asset:get_height()

      if y < Gui.message_window_y() then
         asset:draw(x, y)
      end

      Draw.set_blend_mode("alpha")
   end
   -- <<<<<<<< shade2/module.hsp:1091 		} ..
end

return CloudLayer
