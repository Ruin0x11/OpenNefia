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
   self.input:bind_keys {
      escape = function() self.canceled = true end,
      shift = function() self.canceled = true end
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
   local x, y = Ui.params_centered(width, height)

   self.t = UiTheme.load(self)

   self.pages:relayout(x, y, width, height)
end

function QuestBoardMenu:draw()
   self.t.deco_board_a:draw_tiled()

   self.pages:draw()
end

function QuestBoardMenu:update()
   if self.canceled then
      return nil, "canceled"
   end

   if self.pages.chosen then
      Gui.mes("ui.board.do_you_meet")
      if Input.yes_no() then
         return self.pages:selected_item()
      end
   end

   self.pages:update()
end

return QuestBoardMenu
