local Draw = require("api.Draw")
local Gui = require("api.Gui")
local IInput = require("api.gui.IInput")
local IList = require("api.gui.IList")
local IUiList = require("api.gui.IUiList")
local ListModel = require("api.gui.ListModel")
local InputHandler = require("api.gui.InputHandler")
local TopicWindow = require("api.gui.TopicWindow")

local FuzzyFinderList = class.class("FuzzyFinderList", IUiList)

FuzzyFinderList:delegate("model", IList)
FuzzyFinderList:delegate("input", IInput)

function FuzzyFinderList:init()
   self.model = ListModel:new({})
   self.topic_win = TopicWindow:new(1, 1)

   self.offset = 0
   self.scroll_margin = 3
   self.page_size = 15

   self.input = InputHandler:new()
   self.input:bind_keys(self:make_keymap())

   self:set_data()
end

function FuzzyFinderList:set_data(data)
   self.model:set_data(data)
   self:update_offset()

   if self.width then
      self:relayout()
   end
end

function FuzzyFinderList:make_keymap()
   return {
      north = function()
         Gui.play_sound("base.cursor1")
         self.model:select_previous()
         self:update_offset()
      end,
      south = function()
         Gui.play_sound("base.cursor1")
         self.model:select_next()
         self:update_offset()
      end,
      repl_page_up = function()
         Gui.play_sound("base.cursor1")
         self.model:select_previous(self.page_size)
         self:update_offset()
      end,
      repl_page_down = function()
         Gui.play_sound("base.cursor1")
         self.model:select_next(self.page_size)
         self:update_offset()
      end,
   }
end

function FuzzyFinderList:relayout(x, y, width)
   Draw.set_font(14)

   self.x = x or self.x
   self.y = y or self.y
   self.width = width or self.width

   local entry_count = math.min(self.model:len()-self.offset, self.page_size)
   self.height = Draw.text_height() * (entry_count+3)

   self.topic_win:relayout(self.x, self.y, self.width, self.height)

   self:update_offset()
end

function FuzzyFinderList:update_offset()
   if self.model.selected - self.offset > self.page_size - self.scroll_margin then
      self.offset = self.model.selected - self.page_size + self.scroll_margin
   elseif self.model.selected - self.offset < self.scroll_margin then
      self.offset = self.model.selected - self.scroll_margin
   end

   self.offset = math.clamp(self.offset, 1, math.max(1, self.model:len() - self.page_size))
end

local COLORS = {
   {100, 100, 200},
   {100, 200, 100},
   {200, 200, 100},
}

function FuzzyFinderList:draw()
   self.topic_win:draw()
   Draw.set_font(14)
   local th = Draw.text_height()
   local x = self.x + 10
   local y = self.topic_win.y

   self:update_offset()
   local entry_count = math.min(self.model:len()-self.offset, self.page_size)
   for i=self.offset,self.offset+entry_count do
      y = y + th

      -- { "base.test", 0.75, matched_regions = {{ 200, 20 }} }
      local cand = self.model:get(i)
      if cand == nil then
         break
      end

      if i == self.model.selected  then
         Draw.filled_rect(x, y+1, self.width - 20, th, {100, 100, 100})
      end

      for j, region in ipairs(cand.matched_regions or {}) do
         local color = COLORS[(j-1)%#COLORS+1]
         Draw.filled_rect(x+region[1], y, region[2], th, color)
      end

      Draw.text(cand[1], x, y, {255, 255, 255})
   end
end

function FuzzyFinderList:update(dt)
   self.topic_win:update(dt)
end

return FuzzyFinderList
