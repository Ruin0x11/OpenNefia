local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local Skill = require("mod.elona_sys.api.Skill")
local Const = require("api.Const")

local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiPagedContainer = require("api.gui.UiPagedContainer")
local CharacterSheetMenu = require("api.gui.menu.CharacterSheetMenu")
local SkillStatusMenu = require("api.gui.menu.SkillStatusMenu")
local ISettable = require("api.gui.ISettable")
local WindowTitle = require("api.gui.menu.WindowTitle")
local IUiLayer = require("api.gui.IUiLayer")

local CharacterInfoMenu = class.class("CharacterInfoMenu", { IUiLayer, ISettable })

CharacterInfoMenu:delegate("input", IInput)

function CharacterInfoMenu:init(chara, mode, opts)
   self.chara = chara
   self.mode = mode or "player_status"

   self.sublayers = UiPagedContainer:new {
      CharacterSheetMenu:new(self.chara, self.mode),
      SkillStatusMenu:new(self.chara, self.mode, opts)
   }

   self.title = WindowTitle:new()

   self.input = InputHandler:new()
   self.input:forward_to(self.sublayers:current_sublayer())
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.final_screen.caption"

   if self.mode == "trainer_train" or self.mode == "trainer_learn" then
      self:select_page(2)
   end

   self:refresh()
end

function CharacterInfoMenu:make_keymap()
   return {
      cancel = function() self.canceled = true end,
      escape = function() self.canceled = true end,
      previous_page = function() self:previous_page() end,
      next_page = function() self:next_page() end,
      west = function() self:previous_page() end,
      east = function() self:next_page() end,
   }
end

function CharacterInfoMenu:refresh()
   -- >>>>>>>> shade2/command.hsp:2452 	if csCtrl=0:if page=0:s=lang("ｶｰｿﾙ [祝福と呪いの情報]  ", ..
   local sublayer = self.sublayers:current_sublayer()
   local key_hints = sublayer:make_key_hints()
   local text = Ui.format_key_hints(key_hints)

   self.title:set_data(text)
   -- <<<<<<<< shade2/command.hsp:2457 	if csCtrl!1:if page!0:s+=""+key_mode2+" ["+lang(" ..

   self.input:forward_to(sublayer)
end

function CharacterInfoMenu:set_data(chara)
   self.chara = chara or self.chara

   for _, pair in self.sublayers:iter() do
      pair.layer:set_data(self.chara)
   end
end

function CharacterInfoMenu:select_page(page)
   self.sublayers:select_page(page)
   self:refresh()
end

function CharacterInfoMenu:next_page()
   self.sublayers:next_page()
   self:refresh()
   Gui.play_sound("base.pop1")
end

function CharacterInfoMenu:previous_page()
   self.sublayers:previous_page()
   self:refresh()
   Gui.play_sound("base.pop1")
end

function CharacterInfoMenu:on_query()
   Gui.play_sound("base.chara")
end

function CharacterInfoMenu:relayout(x, y, width, height)
   self.width = 700
   self.height = 400
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.sublayers:relayout(self.x, self.y, self.width, self.height)
   if self.mode == "chara_make" then
      self.title:relayout(240, Draw.get_height() - 16, Draw.get_width() - 240, 16)
   else
      self.title:relayout(236 - 10, 0, Draw.get_width() - 236 - 10, 16)
   end
end

function CharacterInfoMenu:draw()
   self.sublayers:draw()

   Draw.set_color(0, 0, 0)
   Draw.set_font(12, "bold")

   local page_str = string.format("Page.%d/%d", self.sublayers.page, self.sublayers.page_max)
   Draw.text(page_str, self.x + self.width - Draw.text_width(page_str) - 40, self.y + self.height - 24 - self.height % 8)
   self.title:draw()
end

function CharacterInfoMenu.apply_skill_point(chara, skill_id)
   -- >>>>>>>> shade2/command.hsp:2737 		if sORG(csSkill,pc)=0:snd seFail1:goto *com_char ..
   Skill.gain_skill_exp(chara, skill_id, Const.SKILL_POINT_EXPERIENCE_GAIN)
   Skill.modify_potential(chara, skill_id, math.floor(15 - chara:skill_potential(skill_id) / 15, 2, 15))
   chara:refresh()
   -- <<<<<<<< shade2/command.hsp:2743 		goto *com_charaInfo_loop ..
end

function CharacterInfoMenu:handle_select_skill(result)
   -- >>>>>>>> shade2/command.hsp:2733 	if p!-1:if csCtrl!4{ ..
   local sublayer = self.sublayers:current_sublayer()

   if self.mode == "player_status" then
      if result.kind == "skill" and self.chara.skill_bonus > 0 then
         if not self.chara:has_skill(result._id) then
            Gui.play_sound("base.fail1")
         else
            Gui.play_sound("base.spend1")
            CharacterInfoMenu.apply_skill_point(self.chara, result._id)

            self.chara.skill_bonus = self.chara.skill_bonus - 1

            sublayer:set_data(self.chara)
         end
      end

      return nil
   elseif self.mode == "trainer_train" or self.mode == "trainer_learn" then
      return result
   end

   return nil
   -- <<<<<<<< shade2/command.hsp:2744 		} ..
end

function CharacterInfoMenu:update(dt)
   if self.canceled then
      return nil, "canceled"
   end

   local result = self.sublayers:update(dt)

   if result then
      local sublayer = self.sublayers:current_sublayer()
      if class.is_an(SkillStatusMenu, sublayer) then
         return self:handle_select_skill(result)
      end
   end
end

return CharacterInfoMenu
