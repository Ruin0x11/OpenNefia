local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Map = require("api.Map")
local UiTheme = require("api.gui.UiTheme")
local IDrawLayer = require("api.gui.IDrawLayer")

local EmotionIconLayer = class("EmotionIconLayer", IDrawLayer)

function EmotionIconLayer:init()
   self.icons = {}
   self.reupdate = true
end

function EmotionIconLayer:relayout()
   self.t = UiTheme.load(self)
end

function EmotionIconLayer:reset()
   self.icons = {}
   self.reupdate = true
end

function EmotionIconLayer:update(dt, screen_updated)
   if not (screen_updated or self.reupdate) then return end

   for _, c in Map.iter_charas() do
      if Chara.is_alive(c) and Map.is_in_fov(c.x, c.y) then
         if c.emotion_icon ~= nil then
            self.icons[c.uid] = { id = c.emotion_icon, x = c.x, y = c.y }
         end
      else
         self.icons[c.uid] = nil
      end
   end

   self.reupdate = false
end

function EmotionIconLayer:draw(draw_x, draw_y)
   Draw.set_color(255, 255, 255)
   for k, v in pairs(self.icons) do
      local i = self.t[v.id]
      if i ~= nil then
         i:draw(v.x * 48 + 4 + 16 - draw_x, v.y * 48 - 16 - draw_y)
      end
   end
end

return EmotionIconLayer
