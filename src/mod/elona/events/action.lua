local Event = require("api.Event")
local Gui = require("api.Gui")
local World = require("api.World")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Enum = require("api.Enum")

local function try_to_chat(chara, player)
   -- >>>>>>>> shade2/chat.hsp:42 *chat ...
   if chara:relation_towards(player) <= Enum.Relation.Dislike then
      Gui.mes("talk.will_not_listen")
      return
   end

   if World.date_hours() >= chara.interest_renew_date then
      chara.interest = 100
   end
   -- <<<<<<<< shade2/chat.hsp:52 	if dateID>=cInterestRenew(tc):cInterest(tc)=100 ..

   -- >>>>>>>> elona122/shade2/chat.hsp:66 	if cSleep(tc)!0{ ..
   if chara:has_effect("elona.sleep") then
      Dialog.start(chara, "elona.is_sleeping")
      return
   end

   if chara:has_activity() then
      Dialog.start(chara, "elona.is_busy")
      return
   end

   if chara:is_player() then
      return
   end
   -- <<<<<<<< elona122/shade2/chat.hsp:75 	if tc=pc:goto *chat_end ..

   local dialog_id = chara:calc("dialog") or "elona.default"
   Dialog.start(chara, dialog_id)
end

local function bump_into_chara(player, params, result)
   -- >>>>>>>> shade2/action.hsp:537 		tc=cellChara ...
   local on_cell = params.chara
   local relation = player:relation_towards(on_cell)

   if relation >= Enum.Relation.Ally
      or (relation == Enum.Relation.Dislike and (not config.base.attack_neutral_npcs or Gui.player_is_running()))
   then
      if not on_cell:calc("is_hung_on_sandbag") then
         if player:swap_places(on_cell) then
            Gui.mes("action.move.displace.text", on_cell)
            Gui.set_scroll()
            on_cell:emit("elona.on_displaced")
         end
         return "turn_end"
      end
   end

   if relation <= Enum.Relation.Dislike then
      player:set_target(on_cell)
      ElonaAction.melee_attack(player, on_cell)
      Gui.set_scroll()
      return "turn_end"
   end

   try_to_chat(on_cell, player)

   return result
   -- <<<<<<<< shade2/action.hsp:563 		goto *turn_end ..
end

Event.register("elona_sys.on_player_bumped_into_chara", "Attack/swap position", bump_into_chara)
