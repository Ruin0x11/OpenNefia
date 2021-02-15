local UiTheme = require("api.gui.UiTheme")
local IUiElement = require("api.gui.IUiElement")
local Draw = require("api.Draw")
local Window = require("api.gui.Window")
local TopicWindow = require("api.gui.TopicWindow")
local VisualAIPlanGrid = require("mod.visual_ai.api.gui.VisualAIPlanGrid")

local VisualAIPlanTrail = class.class("VisualAIPlanTrail", IUiElement)

function VisualAIPlanTrail:init()
   self.trail = {}
   self.selected_idx = 1
   self.offset_y = 0

   self.win = Window:new()

   self.item_height = 80
end

function VisualAIPlanTrail:set_trail(trail, selected_idx)
   self.trail = {}
   self.selected_idx = selected_idx or 1

   for _, entry in ipairs(trail) do
      if entry.type == "block" then
         self.trail[#self.trail+1] = {
            window = TopicWindow:new(4, 1),
            text = entry.text,
            tile = entry,
            wrapped = {},
         }
      end
   end

   self:_recalc_layout()
end

function VisualAIPlanTrail:_recalc_layout()
   self.offset_y = 0
   local selected_y = self.selected_idx * self.item_height + 10

   if selected_y + self.item_height > self.height then
      self.offset_y = math.max(self.height - (selected_y + self.item_height), math.floor(#self.trail - (self.height / self.item_height)) * -self.item_height - 80)
   end

   local x = self.x + 10
   local y = self.y + 10 + self.offset_y

   Draw.set_font(14)
   for _, entry in ipairs(self.trail) do
      entry.window:relayout(x + 5, y + 2.5, self.width - 40, self.item_height - 2.5)

      local _, wrapped = Draw.wrap_text(entry.text, self.width - 40 - 100)
      entry.wrapped = wrapped

      y = y + self.item_height
   end
end

function VisualAIPlanTrail:refresh()
   self:_recalc_layout()
end

function VisualAIPlanTrail:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.t = UiTheme.load(self)

   self.win:relayout(self.x, self.y, self.width, self.height)

   self:_recalc_layout()
end

function VisualAIPlanTrail:draw()
   Draw.set_color(255, 255, 255)
   self.win:draw()

   local x = self.x + 10
   local y = self.y + 10 + self.offset_y
   local tile_size_px = 48

   Draw.set_scissor(self.x + 10, self.y + 10 + 8, self.width, self.height - 28 - 16)
   for i, entry in ipairs(self.trail) do
      if y > self.y - self.item_height and self.y and y < self.y + self.height then
         entry.window:draw()

         Draw.set_font(20)
         Draw.text_shadowed(tostring(i), x + 20, y + self.item_height / 2 - Draw.text_height() / 2)

         VisualAIPlanGrid.draw_tile(entry.tile, x + 40, y + self.item_height / 2 - tile_size_px / 2, tile_size_px, 8)

         Draw.set_font(14)
         for i, line in ipairs(entry.wrapped) do
            Draw.text_shadowed(line, x + 40 + tile_size_px + 5, y + 5 + i * Draw.text_height())
         end

         if i ~= self.selected_idx then
            Draw.set_color(0, 0, 0, 128)
            Draw.filled_rect(entry.window.x, entry.window.y, entry.window.width, entry.window.height)
         end
      end
      y = y + self.item_height
   end
   Draw.set_scissor()
end

function VisualAIPlanTrail:update(dt)
   self.win:update(dt)
end

return VisualAIPlanTrail
