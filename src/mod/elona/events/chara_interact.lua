local Chara = require("api.Chara")
local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")
local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Input = require("api.Input")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local Gui = require("api.Gui")
local ChangeAppearanceMenu = require("api.gui.menu.ChangeAppearanceMenu")
local Item = require("api.Item")
local ICharaSandBag = require("mod.elona.api.aspect.ICharaSandBag")
local ChangeToneMenu = require("api.gui.menu.ChangeToneMenu")
local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")

--
-- Interact Actions
--

local function interact_talk(chara, player)
-- >>>>>>>> shade2/command.hsp:1872 	if p=0:gosub *screen_draw:gosub *chat:if chatTele ...
   local turn_result = Effect.try_to_chat(chara, player)

   return turn_result or "turn_end"
-- <<<<<<<< shade2/command.hsp:1872 	if p=0:gosub *screen_draw:gosub *chat:if chatTele ..
end

local function interact_attack(chara, player)
   -- >>>>>>>> shade2/command.hsp:1873 	if p=1:gosub *screen_draw:gosub *act_melee:goto * ...
   ElonaAction.melee_attack(player, chara)

   return "turn_end"
   -- <<<<<<<< shade2/command.hsp:1873 	if p=1:gosub *screen_draw:gosub *act_melee:goto * ..
end

local function interact_inventory(chara, player)
   -- >>>>>>>> shade2/command.hsp:1876 	if p=4:goto *com_allyInventory ...
   return ElonaCommand.do_give_ally(player, chara)
   -- <<<<<<<< shade2/command.hsp:1876 	if p=4:goto *com_allyInventory ..
end

local function interact_give(chara, player)
   -- >>>>>>>> shade2/command.hsp:1874 	if p=2:gosub *screen_draw:invCtrl=10:snd seInv:go ...
   return ElonaCommand.do_give_other(player, chara)
   -- <<<<<<<< shade2/command.hsp:1874 	if p=2:gosub *screen_draw:invCtrl=10:snd seInv:go ..
end

local function interact_info(chara, player)
   -- >>>>>>>> shade2/command.hsp:1883 		csCtrl=4:pop:cc=tc:gosub *com_charainfo:cc=pc:go ...
   CharacterInfoMenu:new(chara):query()

   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:1883 		csCtrl=4:pop:cc=tc:gosub *com_charainfo:cc=pc:go ..
end

local function interact_bring_out(chara, player)
   -- >>>>>>>> shade2/command.hsp:1877 	if p=5{ ...
   local player = player

   player:recruit_as_ally(chara)
   Gui.update_screen()

   return "turn_end"
   -- <<<<<<<< shade2/command.hsp:1880 		} ...
end

local function interact_appearance(chara, player)
   -- >>>>>>>> shade2/command.hsp:1897 	if p=8{ ...
   ChangeAppearanceMenu:new({chara = chara}):query()

   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:1903 		} ..
end

local function interact_teach_words(chara, player)
   -- >>>>>>>> shade2/command.hsp:1885 	if p=7{ ...
   Gui.mes("action.interact.change_tone.prompt", chara)

   chara.taught_words = nil

   local sentence, canceled = Input.query_text(20, true)
   if canceled then
      return "player_turn_query"
   end

   if sentence ~= "" then
      chara.taught_words = sentence
      Gui.mes_c(sentence, "SkyBlue")
   end

   Gui.update_screen()

   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:1896 		} ..
end

local function interact_change_tone(chara, player)
   -- >>>>>>>> shade2/command.hsp:1910 	if p=10:gosub *com_tone ...
   local result, canceled = ChangeToneMenu:new():query()

   if result and not canceled then
      Gui.mes("action.interact.change_tone.is_somewhat_different", chara)
      local tone_id = result.tone_id
      if tone_id == nil then
         chara.tone = chara.proto.tone
      else
         chara.tone = tone_id
      end
   end

   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:1910 	if p=10:gosub *com_tone ..
end

local function interact_release(chara, player)
   -- >>>>>>>> shade2/command.hsp:1904 	if p=9{ ...
   Gui.play_sound("base.build1", chara.x, chara.y)
   chara:get_aspect(ICharaSandBag):release_from_sand_bag(chara, true)
   Gui.mes("action.interact.release", chara)
   chara:refresh()

   return "player_turn_query"
   -- <<<<<<<< shade2/command.hsp:1909 		} ..
end

local function interact_name(chara, player)
   -- >>>>>>>> shade2/command.hsp:1875 	if p=3:gosub *screen_draw:goto *com_name ...
   return ElonaCommand.name(player, chara)
   -- <<<<<<<< shade2/command.hsp:1875 	if p=3:gosub *screen_draw:goto *com_name ..
end

--
-- Event Handler
--

local function add_interact_actions(chara, params, actions)
   local function add_option(text, callback)
      table.insert(actions, { text = text, callback = callback })
   end

   local player = Chara.player()

   -- >>>>>>>> shade2/command.hsp:1850 	if tc!pc{ ...
   if not chara:is_player() then
      if not player:has_effect("elona.confusion") then
         add_option("action.interact.choices.talk", interact_talk)
         add_option("action.interact.choices.attack", interact_attack)
      end

      if not Effect.is_temporary_ally(chara) then
         if chara:is_in_player_party() then
            add_option("action.interact.choices.inventory", interact_inventory)
         else
            add_option("action.interact.choices.give", interact_give)
         end
         if chara.is_livestock then -- TODO refactor this flag to ranch-specific event handler
            add_option("action.interact.choices.bring_out", interact_bring_out)
         end
         if chara:is_in_player_party() then
            add_option("action.interact.choices.appearance", interact_appearance)
         end
      end

      add_option("action.interact.choices.teach_words", interact_teach_words)
      add_option("action.interact.choices.change_tone", interact_change_tone)

      -- TODO show house
      if chara:calc_aspect(ICharaSandBag, "is_hung_on_sand_bag") then
         add_option("action.interact.choices.release", interact_release)
      end
   end

   add_option("action.interact.choices.name", interact_name)

   if config.base.development_mode or save.base.is_wizard then
      add_option("action.interact.choices.info", interact_info)
   end
   -- <<<<<<<< shade2/command.hsp:1867 	if (develop)or(gWizard):promptAdd lang("情報","Info ..
   return actions
end
Event.register("elona_sys.on_build_interact_actions", "Build default options", add_interact_actions)
