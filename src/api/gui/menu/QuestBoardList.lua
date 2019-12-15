local Draw = require("api.Draw")
local Chara = require("api.Chara")
local I18N = require("api.I18N")
local IUiList = require("api.gui.IUiList")
local UiList = require("api.gui.UiList")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local IPaged = require("api.gui.IPaged")
local UiTheme = require("api.gui.UiTheme")
local Window = require("api.gui.Window")
local Gui = require("api.Gui")

local QuestBoardList = class.class("QuestBoardList", IUiList, IPaged)

QuestBoardList:delegate("model", {
                       "items",
                       "changed",
                       "selected",
                       "selected_item",
                       "select",
                       "select_next",
                       "select_previous",
                       "choose",
                       "can_select",
                       "set_data",
                       "get_item_text",
                       "chosen",
                       "on_choose",
                       "can_choose",
                       "on_select",
                       "select_page",
                       "next_page",
                       "previous_page",
                       "iter",
                       "len",
                       "page"
})

QuestBoardList:delegate("input", IInput)

local KEYS = "abcdefghijklmnopqr"

function QuestBoardList:init(quests)
   self.model = PagedListModel:new(quests, 4)

   self.windows = {}
   for _ = 1, 4 do
      self.windows[#self.windows+1] = Window:new(true)
      self.windows[#self.windows+1] = Window:new()
   end

   self.input = InputHandler:new()
   self.input:bind_keys(UiList.make_keymap(self))
end

function QuestBoardList:get_item_color(item)
   return {0, 0, 0}
end

function QuestBoardList:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   local window_height = math.floor(self.height / 4)

   self.t = UiTheme.load(self)

   for i = 1, 4 do
      local y = self.y + (i-1) * 120
      self.windows[i*2-1]:relayout(self.x + 4, y + 4, self.width, window_height)
      self.windows[i*2]:relayout(self.x, y, self.width, window_height)
   end
end

function QuestBoardList.quest_difficulty_color(level, difficulty)
   if level * 2 < difficulty then
      return {205, 0, 0}
   elseif math.floor(level * 3 / 2) < difficulty then
      return {140, 80, 0}
   elseif level < difficulty then
      return {0, 0, 205}
   else
      return {0, 155, 0}
   end
end

function QuestBoardList:draw_item(item, i, x, y, key_name)
   UiList.draw_select_key(self, item, i, key_name, x, y)
   UiList.draw_item_text(self, item.title or "Quest", item, i, x + 76, y - 1, 19)

   Draw.text(I18N.get("quest.info.days", item.deadline_days), x + 324, y + 2)

   Draw.text(tostring(item.client_name), x + 372, y + 2)

   local level = Chara.player():calc("level")
   local difficulty = item.difficulty
   local color = QuestBoardList.quest_difficulty_color(level, difficulty)
   Draw.set_color(color)

   local stars = math.floor(difficulty / 5) + 1
   if stars < 11 then
      local dy = 0
      if stars > 5 then
         Draw.set_font(10) -- 10 - en * 2
         dy = -3
      end
      for star = 0, stars-1 do
         Draw.text(I18N.get("ui.board.difficulty"), x + 250 + star % 5 * 13, y + dy + math.floor(star / 5) * 8 + 2)
      end
   else
      Draw.text(I18N.get("ui.board.difficulty_counter", stars), x + 250, y + 2)
   end

   Draw.set_color(255, 255, 255)

   Draw.text(item.description or "quest description", x, y + 20, {0, 0, 0}, 13)
end

function QuestBoardList:draw()
   for i = 1, 4 do
      --self.windows[i*2-1]:draw()
      self.windows[i*2]:draw()
      self.t.deco_board_b:draw(self.x + 20, self.y + 8 + (i-1) * 120)
   end

   Draw.set_font(16) -- 16 - en * 2
   Draw.text_shadowed(string.format("Page %i/%i", self.model.page+1, self.model.page_max+1),
                      self.x + self.width + 20,
                      self.y)

   for i, quest in self.model:iter() do
      local x = self.x + 20
      local y = self.y + (i-1) * 120 + 20
      local key_name = KEYS:sub(i, i)
      self:draw_item(quest, i, x, y, key_name)
   end
end

function QuestBoardList:update()
   UiList.update(self)
end

function QuestBoardList:get_hint()
   return "hint:"
end

return QuestBoardList
