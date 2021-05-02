local UiTheme = require("api.gui.UiTheme")
local IUiElement = require("api.gui.IUiElement")
local Draw = require("api.Draw")
local Window = require("api.gui.Window")
local VisualAIBlockCard = require("mod.visual_ai.api.gui.VisualAIBlockCard")

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

   for i, entry in ipairs(trail) do
      if entry.type == "block" then
         self.trail[#self.trail+1] = VisualAIBlockCard:new(entry.text, entry.color, entry.icon, i)
      end
   end

   self:_recalc_layout()
end

function VisualAIPlanTrail:_recalc_layout()
   self.offset_y = 0
   local selected_y = self.selected_idx * self.item_height + 10

   if selected_y + self.item_height > self.height then
      self.offset_y = math.max(self.height - (selected_y + self.item_height), math.floor(#self.trail - (self.height / self.item_height)) * -self.item_height - 100)
   end

   local x = self.x + 10
   local y = self.y + 10 + self.offset_y

   Draw.set_font(14)
   for i, entry in ipairs(self.trail) do
      entry:relayout(x, y, self.width - 30, self.item_height)
      entry.selected = i == self.selected_idx

      y = y + entry.height
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

   Draw.set_scissor(self.x + 10, self.y + 10 + 8, self.width, self.height - 54)
   for _, entry in ipairs(self.trail) do
      if entry.y > self.y - entry.height and self.y and entry.y < self.y + self.height then
         entry:draw()
      end
   end
   Draw.set_scissor()
end

function VisualAIPlanTrail:update(dt)
   self.win:update(dt)
end

return VisualAIPlanTrail
