local Draw = require("api.Draw")
local IUiElement = require("api.gui.IUiElement")
local TopicWindow = require("api.gui.TopicWindow")
local I18N = require("api.I18N")
local Gui = require("api.Gui")
local ChatBubbleLayer = require("mod.chat_bubbles.api.gui.ChatBubbleLayer")
local UiTheme = require("api.gui.UiTheme")

local ChatBubbleConfigMenuPreview = class.class("ChatBubbleConfigMenuPreview", IUiElement)

function ChatBubbleConfigMenuPreview:init(chara_chip_id, text)
   self.chara_chip_id = chara_chip_id or "elona.putit"
   self.text = text or I18N.get("chat_bubbles:ui.menu.config.test_text")

   self.text_width = 0
   self.text_height = 0
   self.bg_color = {255, 255, 255}
   self.text_color = {0, 0, 0}
   self.curve = 5
   self.edge = 10
   self.font = nil
   self.font_size = 11
   self.font_style = "normal"
   self.x_offset = 0
   self.y_offset = 0

   self.topic_window = TopicWindow:new(1, 1)

   self:update_bubble_size()
end

function ChatBubbleConfigMenuPreview:update_bubble_size()
   Draw.set_font(self.font_size)
   self.text_width = Draw.text_width(self.text) + 10
   self.text_height = Draw.text_height() + 10
end

function ChatBubbleConfigMenuPreview:set_data(text_color, bg_color, font, font_size, font_style, x_offset, y_offset)
   self.text_color = text_color
   self.bg_color = bg_color
   self.font = font
   self.font_size = font_size
   self.font_style = font_style
   self.x_offset = x_offset or 0
   self.y_offset = y_offset or 0

   self:update_bubble_size()
end

local function make_tile_batch()
   local batch = Draw.make_chip_batch("tile")
   local tile_width, tile_height = Draw.get_coords():get_size()
   local default_id = "elona.grass"

   for j = 0, 3-1 do
      for i = 0, 3-1 do
         local sx, sy = Gui.tile_to_screen(i, j)
         batch:add(default_id, sx, sy, tile_width, tile_height)
      end
   end

   return batch
end

local function make_chip_batch(chara_chip_id)
   local batch = Draw.make_chip_batch("chip")
   local sx, sy = Gui.tile_to_screen(1, 2)
   local tile_width, tile_height = Draw.get_coords():get_size()

   batch:add(chara_chip_id, sx, sy - tile_height / 4)

   return batch
end

function ChatBubbleConfigMenuPreview:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.topic_window:relayout(self.x, self.y, self.width, self.height)

   self.tile_width, self.tile_height = Draw.get_coords():get_size()

   self.t = UiTheme.load(self)

   self.tile_batch = make_tile_batch()
   self.chip_batch = make_chip_batch(self.chara_chip_id)
end

function ChatBubbleConfigMenuPreview:draw()
   self.topic_window:draw()

   local x = self.x + 5 - self.text_width / 2 + self.tile_width * 1.5 + self.x_offset
   local y = self.y + 5 - self.text_height / 2 - self.edge + self.tile_height * 1.5 + self.y_offset

   self.tile_batch:draw(self.x + 5, self.y + 5)
   Draw.set_blend_mode("subtract")
   Draw.set_color(255, 255, 255, 96)
   self.t.base.character_shadow:draw(self.x + 5 + self.tile_width * 1.5,
                                     self.y + 5 + self.tile_height * 2.75,
                                     nil, nil, nil, true)
   Draw.set_blend_mode("alpha")
   self.chip_batch:draw(self.x + 5, self.y + 5)

   Draw.set_font(self.font_size)
   Draw.set_scissor(self.x + 5, self.y + 5, self.width - 10, self.height - 10)
   ChatBubbleLayer.draw_chat_bubble(x,
                                    y,
                                    self.text,
                                    self.text_width,
                                    self.text_height,
                                    self.bg_color,
                                    self.text_color,
                                    self.curve,
                                    self.edge,
                                    1)
   Draw.set_scissor()
end

function ChatBubbleConfigMenuPreview:update(dt)
   self.topic_window:update(dt)
end

return ChatBubbleConfigMenuPreview
