local Draw = require("api.Draw")
local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiList = require("api.gui.IUiList")
local InputHandler = require("api.gui.InputHandler")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local IList = require("api.gui.IList")
local Gui = require("api.Gui")
local ListModel = require("api.gui.ListModel")
local TopicWindow = require("api.gui.TopicWindow")
local utils = require("mod.visual_ai.internal.utils")
local VisualAIPlanGrid = require("mod.visual_ai.api.gui.VisualAIPlanGrid")
local VisualAIBlockCard = require("mod.visual_ai.api.gui.VisualAIBlockCard")

local VisualAIBlockList = class.class("VisualAIBlockList", IUiList)

VisualAIBlockList:delegate("model", IList)
VisualAIBlockList:delegate("model", IPaged)
VisualAIBlockList:delegate("input", IInput)

local CATEGORIES = {
   "condition",
   "target",
   "action",
   "special"
}

function VisualAIBlockList:init()
   self.item_height = 80
   self.tile_size_px = 48
   self.offset_y = 0

   self.model = ListModel:new({})
   self.category_idx = 1
   self.category = CATEGORIES[self.category_idx]

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())
end

function VisualAIBlockList:make_keymap()
   return {
      north = function()
         self:select_previous()
         Gui.play_sound("base.cursor1")
         self:_recalc_layout()
      end,
      south = function()
         self:select_next()
         Gui.play_sound("base.cursor1")
         self:_recalc_layout()
      end,
      west = function() self:change_category(self.model:selected_index(), -1) end,
      east = function() self:change_category(self.model:selected_index(), 1) end,
      enter = function() self.chosen = true end,
   }
end

function VisualAIBlockList:make_key_hints()
   return {
      {
         action = "ui.key_hint.action.page",
         keys = { "previous_page", "next_page" }
      }
   }
end

function VisualAIBlockList:_recalc_layout()
   self.offset_y = 0
   local selected_y = self:selected_index() * self.item_height + 10

   if selected_y + self.item_height > self.height then
      self.offset_y = math.max(self.height - (selected_y + self.item_height), math.floor(self:len() - (self.height / self.item_height)) * -self.item_height - 80)
   end

   local x = self.x + 10
   local y = self.y + 10 + self.offset_y

   Draw.set_font(14)
   for i, entry in self.model:iter() do
      entry.card:relayout(x, y, self.width - 40, self.item_height)
      entry.card.selected = i == self:selected_index()

      y = y + self.item_height
   end
end

function VisualAIBlockList:set_category(category_idx)
   self.t = self.t or UiTheme.load(self)

   local category = CATEGORIES[category_idx]
   if category == nil then
      category_idx = table.index_of(CATEGORIES, category_idx)
      category = CATEGORIES[category_idx]
   end

   if category == nil then
      category_idx = 1
      category = CATEGORIES[category_idx]
   end
   self.category_idx = category_idx
   self.category = category

   local pred = function(e) return e.type == category end
   local map = function(e)
      local vars = utils.get_default_vars(e.vars)
      local color = utils.get_block_color(e, self.t)
      local icon = utils.get_block_icon(e, self.t)
      local text = utils.get_block_text(e, vars)

      return {
         card = VisualAIBlockCard:new(text, color, icon),
         proto = e,
      }
   end
   local entries = data["visual_ai.block"]:iter():filter(pred):map(map):to_list()

   self.model:set_data(entries)

   self:_recalc_layout()
   self.changed = true
end

function VisualAIBlockList:select_block(block_id)
   for i, item in self.model:iter() do
      if item.proto._id == block_id then
         self.model:select(i)
         break
      end
   end
   self:_recalc_layout()
end

function VisualAIBlockList:change_category(index, delta)
   Gui.play_sound("base.pop1")
   local category_idx = math.wrap(self.category_idx + delta, 1, #CATEGORIES+1)
   self:set_category(category_idx)
end

function VisualAIBlockList:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height

   self.t = UiTheme.load(self)

   self:_recalc_layout()
end

function VisualAIBlockList:draw()
   Draw.set_scissor(self.x + 10, self.y + 10 + 8, self.width, self.height - 28 - 16)
   for i, entry in self.model:iter() do
      if entry.card.y > self.y - entry.card.height and self.y and entry.card.y < self.y + self.height then
         entry.card:draw()
      end
   end
   Draw.set_scissor()
end

function VisualAIBlockList:update(dt)
   if self.canceled then
      return self.color, "canceled"
   end
   if self.chosen then
      self.chosen = false
      return {
         block_id = self:selected_item().proto._id,
         last_category = self.category_idx
      }
   end

   UiList.update(self)
end

return VisualAIBlockList
