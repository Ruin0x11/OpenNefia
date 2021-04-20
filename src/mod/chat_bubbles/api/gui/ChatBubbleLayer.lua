local Draw = require("api.Draw")
local IDrawLayer = require("api.gui.IDrawLayer")
local Gui = require("api.Gui")
local easing = require("mod.damage_popups.lib.easing")
local global = require("mod.chat_bubbles.internal.global")
local Map = require("api.Map")

local ChatBubbleLayer = class.class("ChatBubbleLayer", IDrawLayer)

function ChatBubbleLayer:init()
   self.tw = nil
   self.th = nil
   self.icons = {}
end

function ChatBubbleLayer:default_z_order()
   return Gui.LAYER_Z_ORDER_USER
end

function ChatBubbleLayer:on_theme_switched(coords)
   self.coords = Draw.get_coords()
   self.tw, self.th = self.coords:get_size()
end

function ChatBubbleLayer:relayout()
end

function ChatBubbleLayer:reset()
   self.icons = {}
   global.chat_bubbles = {}
end

local max_frame = 200

function ChatBubbleLayer:update(map, dt, screen_updated)
   local dead = {}

   for uid, v in pairs(global.chat_bubbles) do
      v.frame = v.frame + dt * 50
      if v.frame > max_frame then
         dead[#dead+1] = uid
      end
   end

   if #dead > 0 then
      table.remove_keys(global.chat_bubbles, dead)
   end
end

function ChatBubbleLayer.draw_chat_bubble(x, y, text, tw, th, bubble_color, text_color, curve, edge)
   curve = math.floor(math.clamp(curve, 0, th / 2 - 2))

   edge = math.floor(math.clamp(edge, 0, th / 2))

   local kind = 1

   local vt = {}
   local p = function(x, y)
      vt[#vt+1] = x
      vt[#vt+1] = y
   end

   -- Draw.line(, x + curve, y)
   -- Draw.line(, x + tw - curve, y)
   -- Draw.line(, x + tw, y + curve)
   -- Draw.line(, x + tw, y + th - curve)
   p(x + curve, y)
   p(x + tw - curve, y)
   p(x + tw, y + curve)
   p(x + tw, y + th - curve)
   p(x + tw - curve, y + th)

   if kind == 0 then
      -- Draw.line(, x + tw - curve, y + th)
      p(x + curve, y + th)
   elseif kind == 1 then
      -- Draw.line(, x + tw - curve, y + th)
      -- Draw.line(, x + tw / 2, y + th)
      -- Draw.line(, x + tw / 2, y + th + edge)
      -- Draw.line(, x + tw / 2 - edge, y + th)
      p(x + tw / 2, y + th)
      p(x + tw / 2, y + th + edge)
      p(x + tw / 2 - edge, y + th)
      p(x + curve, y + th)
   elseif kind == 2 then
      -- Draw.line(, x + tw - curve, y + th)
      -- Draw.line(, x + curve + edge * 2, y + th)
      -- Draw.line(, x + curve + edge * 2, y + th + edge)
      -- Draw.line(, x + curve + edge, y + th)
      p(x + curve + edge * 2, y + th)
      p(x + curve + edge * 2, y + th + edge)
      p(x + curve + edge, y + th)
      p(x + curve, y + th)
   elseif kind == 3 then
      -- Draw.line(, x + tw - curve, y + th)
      -- Draw.line(, x + tw - curve - edge, y + th)
      -- Draw.line(, x + tw - curve - edge * 2, y + th + edge)
      -- Draw.line(, x + curve, y + th)
      p(x + tw - curve - edge, y + th)
      p(x + tw - curve - edge * 2, y + th + edge)
      p(x + tw - curve - edge * 2, y + th)
      p(x + tw - curve - edge * 2 + 1, y + th)
   end

   p(x + curve, y + th)
   p(x, y + th - curve)
   p(x, y + curve)
   p(x + curve, y)

   Draw.set_color(bubble_color)
   Draw.filled_polygon(vt)

   Draw.set_color(text_color)
   Draw.line_polygon(vt)
   Draw.text(text, x + 5, y + 5)
end

function ChatBubbleLayer:draw(draw_x, draw_y)
   local map = Map.current()
   if map == nil then
      return
   end

   for uid, v in pairs(global.chat_bubbles) do
      local obj = map:get_object(uid)
      if obj and obj:is_in_fov() then
         -- >>>>>>>> oomSEST/src/karioki.hsp:316 #deffunc fukidashi int __rrr, int __sss, int __ttt ...
         local x, y = self.coords:tile_to_screen(obj.x, obj.y)

         x = x + draw_x - math.floor(v.width / 2 - self.th / 2)
         y = y + draw_y - v.height - self.th / 2 + (obj:calc("y_offset") or 0)

         Draw.set_font(v.font)

         local curve = 5
         local edge = 10
         ChatBubbleLayer.draw_chat_bubble(x, y, v.text, v.width, v.height, v.bubble_color, v.text_color, curve, edge)
         -- <<<<<<<< oomSEST/src/karioki.hsp:363 	return ..
      end
   end
end

return ChatBubbleLayer
