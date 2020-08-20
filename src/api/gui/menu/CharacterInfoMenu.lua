local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Ui = require("api.Ui")
local save = require("internal.global.save")
local config = require("internal.config")
local Skill = require("mod.elona_sys.api.Skill")
local Const = require("api.Const")

local IInput = require("api.gui.IInput")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local InputHandler = require("api.gui.InputHandler")
local UiPagedContainer = require("api.gui.UiPagedContainer")
local CharacterSheetMenu = require("api.gui.menu.CharacterSheetMenu")
local SkillStatusMenu = require("api.gui.menu.SkillStatusMenu")
local ISettable = require("api.gui.ISettable")

local CharacterInfoMenu = class.class("CharacterInfoMenu", { ICharaMakeSection, ISettable })

CharacterInfoMenu:delegate("input", IInput)

function CharacterInfoMenu:init(chara, mode)
   self.chara = chara
   self.mode = self.mode or "chara_status"

   self.sublayers = UiPagedContainer:new {
      CharacterSheetMenu:new(self.chara),
      SkillStatusMenu:new(self.chara, self.mode)
   }

   self.input = InputHandler:new()
   self.input:forward_to(self.sublayers:current_sublayer())
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.final_screen.caption"
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

function CharacterInfoMenu:set_data(chara)
   self.chara = chara or self.chara
   self.sublayers.sublayers[1]:set_data(self.chara)
end

function CharacterInfoMenu:next_page()
   self.sublayers:next_page()
   self.input:forward_to(self.sublayers:current_sublayer())
end

function CharacterInfoMenu:previous_page()
   self.sublayers:previous_page()
   self.input:forward_to(self.sublayers:current_sublayer())
end

function CharacterInfoMenu:on_query()
   Gui.play_sound("base.chara")
end

function CharacterInfoMenu:relayout(x, y, width, height)
   self.width = 700
   self.height = 400
   self.x, self.y = Ui.params_centered(self.width, self.height)

   self.sublayers:relayout(self.x, self.y, self.width, self.height)
end

function CharacterInfoMenu:draw()
   self.sublayers:draw()

   Draw.set_color(0, 0, 0)
   Draw.set_font(12, "bold")

   local page_str = string.format("Page.%d/%d", self.sublayers.page, self.sublayers.page_max)
   Draw.text(page_str, self.x + self.width - Draw.text_width(page_str) - 40, self.y + self.height - 24 - self.height % 8)
end

function CharacterInfoMenu.apply_skill_point(chara, skill_id)
   -- >>>>>>>> shade2/command.hsp:2737 		if sORG(csSkill,pc)=0:snd seFail1:goto *com_char ..
   Skill.gain_skill_exp(chara, skill_id, Const.SKILL_POINT_EXPERIENCE_GAIN)
   Skill.modify_potential(chara, skill_id, math.floor(15 - chara:skill_potential(skill_id) / 15, 2, 15))
   -- <<<<<<<< shade2/command.hsp:2743 		goto *com_charaInfo_loop ..
end

function CharacterInfoMenu:update(dt)
   if self.canceled then
      return nil, "canceled"
   end

   local result = self.sublayers:update(dt)

   if result then
      local sublayer = self.sublayers:current_sublayer()
      if class.is_an(SkillStatusMenu, sublayer) then
         if self.mode == "chara_status"
            and result.kind == "skill"
            and self.chara.skill_bonus > 0
         then
            if not self.chara:has_skill(result._id) then
               Gui.play_sound("base.fail1")
            else
               Gui.play_sound("base.spend1")
               CharacterInfoMenu.apply_skill_point(self.chara, result._id)

               if not config["base.debug_infinite_skill_points"] then
                  self.chara.skill_bonus = self.chara.skill_bonus - 1
               end

               sublayer:set_data(self.chara)
            end
         end
      end
   end
end

return CharacterInfoMenu
