local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Input = require("api.Input")

local Prompt = require("api.gui.Prompt")
local I18N = require("api.I18N")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local CharacterSheetMenu = require("api.gui.menu.CharacterSheetMenu")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local WindowTitle = require("api.gui.menu.WindowTitle")
local CharaMake = require("api.CharaMake")

local CharacterFinalizeMenu = class.class("CharacterFinalizeMenu", ICharaMakeSection)

CharacterFinalizeMenu:delegate("input", IInput)

function CharacterFinalizeMenu:init()
   local chara = Chara.create("content.player", nil, nil, {ownerless = true}) -- TODO skills
   chara.name = "????"
   chara.title = CharaMake.get_section_result("api.gui.menu.chara_make.SelectAliasMenu")

   self.inner = CharacterSheetMenu:new(nil, chara)

   self.input = InputHandler:new()
   self.input:forward_to(self.inner)
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.final_screen.caption"
   self.intro_sound = "base.skill"

   local title_string = I18N.get("ui.chara_sheet.hint.reroll")
      .. I18N.get("ui.hint.portrait")
      .. I18N.get("ui.chara_sheet.hint.confirm")

   self.title = WindowTitle:new(title_string)

   self:reroll()
end

function CharacterFinalizeMenu:make_keymap()
   return {
      enter = function() self:reroll(true) end,
   }
end

function CharacterFinalizeMenu:on_query()
   Gui.play_sound("base.chara")
   self.canceled = false
end

function CharacterFinalizeMenu:on_make_chara(chara)
   if self.name then
      chara.name = self.name
   else
      chara.name = Event.trigger("base.generate_chara_name", {}, "player")
   end
end

function CharacterFinalizeMenu:reroll(play_sound)
   self.chara = require("api.CharaMake").make_chara()

   if play_sound then
      Gui.play_sound("base.dice")
   end
end

function CharacterFinalizeMenu:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.inner:relayout(x, y - 10, width, height)
   self.title:relayout(240, Draw.get_height() - 16, Draw.get_width() - 240, 16)
end

function CharacterFinalizeMenu:draw()
   self.inner:draw()

   self.title:draw()
end

local function prompt_final()
   return Prompt:new({"ああ", "いや...", "最初から", "前に戻る"}):query()
end

function CharacterFinalizeMenu:update()
   if self.inner.canceled then
      self.inner.canceled = false
      CharaMake.set_caption("chara_make.final_screen.are_you_satisfied.prompt")
      local res = prompt_final()
      if res.index == 1 then
         CharaMake.set_caption("chara_make.final_screen.what_is_your_name")

         local name, canceled = Input.query_text(10)
         if not canceled then
            self.name = name
            return self.chara
         end
      elseif res.index == 2 then
         -- pass
      elseif res.index == 3 then
         return { chara_make_action = "go_to_start" }, "canceled"
      elseif res.index == 4 then
         return nil, "canceled"
      end
   end

   local ok, err = xpcall(function() self.inner:update() end, debug.traceback)
   if err then
      print(err)
   end

   CharaMake.set_caption(self.caption)

   self.canceled = false
end

return CharacterFinalizeMenu
