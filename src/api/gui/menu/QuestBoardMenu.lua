local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Ui = require("api.Ui")
local World = require("api.World")

local I18N = require("api.I18N")
local IUiLayer = require("api.gui.IUiLayer")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTheme = require("api.gui.UiTheme")
local QuestBoardList = require("api.gui.menu.QuestBoardList")

local QuestBoardMenu = class.class("QuestBoardMenu", IUiLayer)

QuestBoardMenu:delegate("pages", "chosen")
QuestBoardMenu:delegate("input", IInput)

function QuestBoardMenu:init(quests)
   self.pages = QuestBoardList:new(quests)

   self.input = InputHandler:new()
   self.input:forward_to(self.pages)
   self.input:bind_keys(self:make_keymap())
end

function QuestBoardMenu:make_keymap()
   return {
      escape = function() self.canceled = true end,
      cancel = function() self.canceled = true end
   }
end

function QuestBoardMenu:on_query()
   Gui.play_sound("base.chat")

   if self.pages:len() == 0 then
      Gui.mes("ui.board.no_new_notices")
      return false
   end
end

function QuestBoardMenu:relayout()
   local width = 560
   local window_height = 140
   local height = window_height * 4
   local x, y = Ui.params_centered(width, height, false)

   self.t = UiTheme.load(self)

   self.pages:relayout(x, y, width, height)
end

function QuestBoardMenu:draw()
   Draw.set_color(255, 255, 255)

   self.t.base.deco_board_a:draw_tiled()

   self.pages:draw()
end

function QuestBoardMenu:update(dt)
   local canceled = self.canceled
   local chosen = self.pages.chosen

   self.canceled = false
   self.pages:update(dt)

   if canceled then
      return nil, "canceled"
   end

   if chosen then
      Gui.mes("ui.board.do_you_meet")
      if Input.yes_no() then
         return self.pages:selected_item().quest
      end
   end
end

return QuestBoardMenu
