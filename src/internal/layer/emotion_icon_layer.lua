local Map = require("api.Map")
local IDrawLayer = require("api.gui.IDrawLayer")
local Draw = require("api.Draw")
local UiTheme = require("api.gui.UiTheme")
local Gui = require("api.Gui")
local Chara = require("api.Chara")

local emotion_icon_layer = class.class("emotion_icon_layer", IDrawLayer)

function emotion_icon_layer:init(width, height, coords)
   self.coords = Draw.get_coords()
   local tw, th = coords:get_size()

   self.asset = nil
   self.batch = nil
   self.tile_width = tw
   self.tile_height = th
   self.parts = {}
end

function emotion_icon_layer:relayout()
   self.asset = UiTheme.load().base.emotion_icons:make_instance()
end

function emotion_icon_layer:reset()
   self.parts = {}
end

local EMOTION_ICONS = {
	["elona.happy"] = 6,
	["elona.silent"] = 7,
	["elona.skull"] = 8,
	["elona.bleed"] = 9,
	["elona.blind"] = 10,
	["elona.confuse"] = 11,
	["elona.dim"] = 12,
	["elona.fear"] = 13,
	["elona.sleep"] = 14,
	["elona.paralyze"] = 15,
	["elona.eat"] = 16,
	["elona.heart"] = 17,
	["elona.angry"] = 18,
	["elona.item"] = 19,
	["elona.notice"] = 20,
	["elona.question"] = 21,
	["elona.quest_target"] = 22,
	["elona.quest_client"] = 23,
	["elona.insane"] = 24,
	["elona.party"] = 25,
}

function emotion_icon_layer:update(dt, screen_updated)
   if not screen_updated then return end

   self.parts = {}

   local map = Map.current()
   assert(map ~= nil)

   for _, c in Chara.iter(map) do
      local id
      local emo = c:calc("emotion_icon")
      if emo then
         id = EMOTION_ICONS[emo] + 1
      end

      if id then
         local x, y = Gui.tile_to_screen(c.x, c.y)
         local memory = c:produce_memory()
         self.parts[#self.parts+1] = { id, x + 4 + 16, y - (memory.offset_y or 0) - 16 }
      end
   end

   self.batch = self.asset:make_batch(self.parts)
end

function emotion_icon_layer:draw(draw_x, draw_y, offx, offy)
   -- HACK this shouldn't be needed...
   local sx, sy, ox, oy = self.coords:get_start_offset(draw_x, draw_y, Draw.get_width(), Draw.get_height())

   Draw.set_color(255, 255, 255)
   Draw.image(self.batch, -draw_x + sx, -draw_y + sy)
end

return emotion_icon_layer
