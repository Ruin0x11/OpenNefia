local Chara = require("api.Chara")
local Draw = require("api.Draw")
local I18N = require("api.I18N")
local IInput = require("api.gui.IInput")
local IPaged = require("api.gui.IPaged")
local IUiList = require("api.gui.IUiList")
local InputHandler = require("api.gui.InputHandler")
local PagedListModel = require("api.gui.PagedListModel")
local Quest = require("mod.elona_sys.api.Quest")
local UiList = require("api.gui.UiList")
local UiTheme = require("api.gui.UiTheme")
local IList = require("api.gui.IList")
local Window = require("api.gui.Window")

local QuestBoardList = class.class("QuestBoardList", {IUiList, IPaged})

QuestBoardList:delegate("model", IList)
QuestBoardList:delegate("model", IPaged)
QuestBoardList:delegate("input", IInput)

local KEYS = "abcdefghijklmnopqr"

function QuestBoardList:init(quests)
   local data = fun.iter(quests)
      :map(function(q)
            local speaker = assert(Chara.find(q.client_uid))
            local title, desc = Quest.get_name_and_desc(q, speaker, false)

            local deadline
            if q.deadline_days == nil then
               deadline = I18N.get("quest.info.no_deadline")
            else
               deadline = I18N.get("quest.info.days", q.deadline_days)
            end

            return {
               quest = q,
               title = title,
               wrapped_desc = "",
               desc = desc,
               deadline = deadline
            }
          end)
      :to_list()

   table.sort(data, function(a, b) return a.quest.difficulty < b.quest.difficulty end)

   self.model = PagedListModel:new(data, 4)

   self.windows = {}
   for _ = 1, 4 do
      self.windows[#self.windows+1] = Window:new(true)
      self.windows[#self.windows+1] = Window:new()
   end

   self.input = InputHandler:new()
   self.input:bind_keys(UiList.make_keymap(self))
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

   Draw.set_font(13)
   for _, entry in self.model:iter_all_pages() do
      local _, wrapped = Draw.wrap_text(entry.desc, self.width - 40)
      entry.wrapped_desc = wrapped
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

   Draw.text(item.deadline, x + 324, y + 2)

   Draw.text(tostring(item.quest.client_name), x + 372, y + 2)

   local level = Chara.player():calc("level")
   local difficulty = item.quest.difficulty
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

   y = y + 20
   for ind=1,#item.wrapped_desc do
      Draw.text(item.wrapped_desc[ind], x, y, {0, 0, 0}, 13)
      y = y + Draw.text_height()
   end
end

function QuestBoardList:draw()
   for i = 1, 4 do
      --self.windows[i*2-1]:draw()
      self.windows[i*2]:draw()
      self.t.base.deco_board_b:draw(self.x + 20, self.y + 8 + (i-1) * 120)
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
