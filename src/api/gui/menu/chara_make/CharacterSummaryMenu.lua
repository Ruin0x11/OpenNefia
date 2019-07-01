local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local Input = require("api.Input")

local Prompt = require("api.gui.Prompt")
local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")
local UiList = require("api.gui.UiList")
local CharacterSheetMenu = require("api.gui.menu.CharacterSheetMenu")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local CharaMakeCaption = require("api.gui.menu.chara_make.CharaMakeCaption")

local CharacterSummaryMenu = class.class("CharacterSummaryMenu", ICharaMakeSection)

CharacterSummaryMenu:delegate("input", IInput)

function CharacterSummaryMenu:init(chara)
   self.inner = CharacterSheetMenu:new(chara)

   self.input = InputHandler:new()
   self.input:forward_to(self.inner)
   self.input:bind_keys {
      ["return"] = function() self:reroll(true) end,
      shift = function() self.canceled = true end,
   }

   self.caption = "Here is the final summary."
   self.intro_sound = "base.skill"

   -- cheat a bit. this gets drawn over the one in the charamake
   -- wrapper.
   self.caption_box = CharaMakeCaption:new()

   self:reroll()
end

function CharacterSummaryMenu:on_query()
   self.canceled = false
   self.name = "????"
end

function CharacterSummaryMenu:on_make_chara(chara)
   if string.nonempty(self.name) then
      chara.name = self.name
   else
      chara.name = "name"
   end
end

function CharacterSummaryMenu:reroll(play_sound)
   self.chara = require("api.CharaMake").make_chara()

   if play_sound then
      Gui.play_sound("base.dice")
   end
end

function CharacterSummaryMenu:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.inner:relayout(x, y, width, height)
   self.caption_box:relayout(self.x + 20, self.y + 30)
end

function CharacterSummaryMenu:draw()
   self.inner:draw()

   if self.caption_box.caption ~= "" then
      self.caption_box:draw()
   end
end

local function prompt_final()
   return Prompt:new({"ああ", "いや...", "最初から", "前に戻る"}):query()
end

function CharacterSummaryMenu:update()
   if self.canceled then
      self.caption_box:set_data("Are you satisfied?")
      local res = prompt_final()
      if res.index == 1 then
         self.caption_box:set_data("Last question. What's your name?")

         local name, canceled = Input.query_text(10)
         if not canceled then
            self.name = name
            return self.chara
         end
      elseif res.index == 2 then
      elseif res.index == 3 then
         return { chara_make_action = "go_to_start" }, "canceled"
      elseif res.index == 4 then
         return nil, "canceled"
      end
   end

   self.inner:update()

   self.caption_box:set_data("")

   self.canceled = false
end

return CharacterSummaryMenu
