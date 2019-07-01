local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiWindow = require("api.gui.UiWindow")
local InputHandler = require("api.gui.InputHandler")
local IInput = require("api.gui.IInput")
local UiTextGroup = require("api.gui.UiTextGroup")
local IUiLayer = require("api.gui.IUiLayer")

local RollBackgroundMenu = class.class("RollBackgroundMenu", IUiLayer)

RollBackgroundMenu:delegate("input", IInput)
RollBackgroundMenu:delegate("list", "items")

local UiListExt = function(select_alias_menu)
   local E = {}

   function E:get_item_text(item)
      return item.text
   end
   function E:on_choose(item)
      if item.on_choose then
         self.chosen = false
         item.on_choose()
      else
         self.chosen = item.type
      end
   end

   return E
end

function RollBackgroundMenu:init()
   self.width = 360
   self.height = 352

   self.win = UiWindow:new("Profile Reroll")

   local items = {
      { text = "Proceed", type = "proceed" },
      { text = "Keep secret", type = "keep_secret" },
      { text = "Reroll all", type = "reroll", on_choose = function() self:reroll(true) end },
      { text = "Reroll first half", type = "reroll", on_choose = function() self:reroll(true, "first") end },
      { text = "Reroll second half", type = "reroll", on_choose = function() self:reroll(true, "second") end }
   }

   self.list = UiList:new(items, 23)
   table.merge(self.list, UiListExt(self))

   self.bg = Ui.random_cm_bg() -- TODO 180, 300

   self.texts = UiTextGroup:new({}, 13, {0, 0, 0}, nil, nil, 0, 15)
   self:reroll()

   self.input = InputHandler:new()
   self.input:forward_to(self.list)
   self.input:bind_keys {
      shift = function() self.canceled = true end
   }

   self.caption = "Can you tell me the history of you?"
   self.intro_sound = "base.ok1"
end

function RollBackgroundMenu:reroll(play_sound, which_part)
   local generator = function(i) return "the history " .. math.random(100) end
   local first, second = self.texts:iter():split(2)
   local gen = fun.tabulate(generator)

   if which_part == "first" then
      first = gen:take(2)
   elseif which_part == "second" then
      second = gen:take(3)
   else
      first = gen:take(2)
      second = gen:take(3)
   end

   local data = fun.chain(first, second):to_list()
   self.texts:set_data(data)

   if play_sound then
      Gui.play_sound("base.dice")
   end
end

function RollBackgroundMenu:relayout(x, y)
   self.x, self.y = Ui.params_centered(self.width, self.height)
   self.y = self.y - 20

   self.win:relayout(self.x, self.y, self.width, self.height)
   self.list:relayout(self.x + 38, self.y + 66)
   self.texts:relayout(self.x + 75, self.y + 200)
end

function RollBackgroundMenu:charamake_result()
   return self.texts.texts
end

function RollBackgroundMenu:on_make_chara(result)
end

function RollBackgroundMenu:on_query()
   self.canceled = false
   self.list:update()
end

function RollBackgroundMenu:draw()
   self.win:draw()
   self.list:draw()
   Ui.draw_topic("history", self.x + 28, self.y + 30)

   self.texts:draw()
end

function RollBackgroundMenu:update()
   if self.list.chosen then
      if self.list.chosen == "keep_secret" then
         self.keep_secret = true
         return true
      else
         self.keep_secret = false
         return true
      end
   end

   if self.canceled then
      return nil, "canceled"
   end

   self.win:update()
   self.list:update()
end

return RollBackgroundMenu
