local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Skill = require("mod.elona_sys.api.Skill")
local Enum = require("api.Enum")
local Item = require("api.Item")
local data = require("internal.data")

local Prompt = require("api.gui.Prompt")
local I18N = require("api.I18N")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local CharaMake = require("api.CharaMake")
local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")

local CharacterFinalizeMenu = class.class("CharacterFinalizeMenu", ICharaMakeSection)

CharacterFinalizeMenu:delegate("input", IInput)

function CharacterFinalizeMenu:init(charamake_data)
   self.charamake_data = charamake_data

   local chara = self.charamake_data.chara
   self.skills = table.deepcopy(chara.skills)
   self.inner = CharacterInfoMenu:new(chara, "chara_make")

   self.input = InputHandler:new()
   self.input:forward_to(self.inner)
   self.input:bind_keys(self:make_keymap())

   self.caption = "chara_make.final_screen.caption"
   self.intro_sound = "base.skill"

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

local function finalize_player(chara)
   -- >>>>>>>> shade2/chara.hsp:539 *cm_finishPC ..
   chara.quality = Enum.Quality.Normal
   Item.create("elona.cargo_travelers_food", nil, nil, {amount=8}, chara)
   Item.create("elona.ration", nil, nil, {amount=8}, chara)
   Item.create("elona.bottle_of_crim_ale", nil, nil, {amount=2}, chara)
   if chara:skill_level("elona.literacy") == 0 then
      Item.create("elona.potion_of_cure_minor_wound", nil, nil, {amount=3}, chara)
   end

   local klass = data["base.class"]:ensure(chara.class)
   if klass.on_init_chara then
      klass.on_init_chara(chara)
   end

   local skill_bonus = 5 + chara:trait_level("elona.perm_skill_point")
   chara.skill_bonus = chara.skill_bonus + skill_bonus
   chara.total_skill_bonus = chara.total_skill_bonus + skill_bonus

   for _, item in chara:iter_items() do
      if Item.is_alive(item) then
         item.identify_state = Enum.IdentifyState.Full
      end
   end

   chara:refresh()
   -- <<<<<<<< shade2/chara.hsp:579 	return ..
end

Event.register("base.on_finalize_player", "Default finalize player", finalize_player)

function CharacterFinalizeMenu.finalize_chara(chara)
   chara:emit("base.on_finalize_player")
end

function CharacterFinalizeMenu:reroll(play_sound)
   -- >>>>>>>> shade2/chara.hsp:1025 	del_chara 0	 ..
   -- XXX: Unsure if this works. It's certainly not efficient...
   local chara = self.charamake_data.chara:clone()

   chara.skills = {}
   chara.height = nil
   chara.age = nil
   Skill.apply_race_params(chara, chara.race)
   Skill.apply_class_params(chara, chara.class)

   chara.name = "????"
   chara.level = 1

   for skill_id, skill in pairs(self.skills) do
      chara.skills[skill_id] = skill
   end

   chara:build()

   self.charamake_data.chara = chara
   self.inner:set_data(self.charamake_data.chara)

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
end

function CharacterFinalizeMenu:draw()
   self.inner:draw()
end

function CharacterFinalizeMenu:get_charamake_result(charamake_result, retval)
   local chara = charamake_result.chara
   if self.name then
      chara.name = self.name
   else
      chara.name = Event.trigger("base.generate_chara_name", {}, "player")
   end
   CharacterFinalizeMenu.finalize_chara(chara)
   return charamake_result
end

local function prompt_final()
   return Prompt:new(
      {
         "chara_make.final_screen.are_you_satisfied.yes",
         "chara_make.final_screen.are_you_satisfied.no",
         "chara_make.final_screen.are_you_satisfied.restart",
         "chara_make.final_screen.are_you_satisfied.go_back",
      }
      ):query()
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
            return true
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
