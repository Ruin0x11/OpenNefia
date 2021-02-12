local Event = require("api.Event")
local Gui = require("api.Gui")
local World = require("api.World")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local ElonaAction = require("mod.elona.api.ElonaAction")

local function try_to_chat(chara, player)
   -- >>>>>>>> elona122/shade2/chat.hsp:42 *chat ..
   if chara:reaction_towards(player) < 0 then
      Gui.mes("talk.will_not_listen")
      return
   end

   if World.date_hours() >= chara.interest_renew_date then
      chara.interest = 100
   end
   -- <<<<<<<< elona122/shade2/chat.hsp:52 	if dateID>=cInterestRenew(tc):cInterest(tc)=100 ..

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
   local on_cell = params.chara
   local reaction = on_cell:reaction_towards(player)

   if reaction > 0 and not on_cell:calc("is_hung_on_sandbag") then
      if on_cell:is_ally() or on_cell.faction == "base.citizen" or Gui.player_is_running() then
         if player:swap_places(on_cell) then
            Gui.mes("action.move.displace.text", on_cell)
            Gui.set_scroll()
            on_cell:emit("elona.on_displaced")
         end
         return "turn_end"
      end

      try_to_chat(on_cell, player)
      return "player_turn_query"
   end

   -- TODO: relation as -1
   if reaction <= 0 then
      player:set_target(on_cell)
      ElonaAction.melee_attack(player, on_cell)
      Gui.set_scroll()
      return "turn_end"
   end

   return result
end

Event.register("elona_sys.on_player_bumped_into_chara", "Attack/swap position", bump_into_chara)

local function calc_dialog_choices(speaker, params, result)
   table.insert(result, {"talk", "talk.npc.common.choices.talk"})

   for _, role in ipairs(speaker.roles) do
      local id = role._id
      local role_data = data["base.role"]:ensure(id)
      if role_data.dialog_choices then
         for _, choice in ipairs(role_data.dialog_choices) do
            if type(choice) == "function" then
               local choices = choice(speaker, params)
               assert(type(choices) == "table")
               for _, choice in ipairs(choices) do
                  table.insert(result, choice)
               end
            else
               table.insert(result, choice)
            end
         end
      end
   end

   return result
end

Event.register("elona.calc_dialog_choices", "Default NPC dialog choices", calc_dialog_choices)
