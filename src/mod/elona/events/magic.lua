local Magic = require("mod.elona_sys.api.Magic")
local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Event = require("api.Event")
local Gui = require("api.Gui")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Chara = require("api.Chara")
local Input = require("api.Input")
local Map = require("api.Map")
local Quest = require("mod.elona.api.Quest")
local Enum = require("api.Enum")

local function set_return_restriction(map)
   if map:has_type("quest") then
      map.prevents_return = true
   end
end
Event.register("base.on_map_entered_events", "Set return restriction", set_return_restriction)

local function proc_return(chara)
   if not chara:is_player() then
      return
   end

   -- >>>>>>>> shade2/main.hsp:707 		if gReturn!0{ ..
   local s = save.elona
   if s.turns_until_cast_return > 0 then
      s.turns_until_cast_return = s.turns_until_cast_return - 1

      local map = chara:current_map()
      if not map then
         s.turns_until_cast_return = 0
      end
      if map:calc("prevents_return") then
         Gui.mes("magic.return.prevented.normal")
         s.turns_until_cast_return = 0
         return
      end

      if s.turns_until_cast_return <= 0 and not DeferredEvent.is_pending() then
         local has_escort = Chara.iter_allies()
            :filter(Chara.is_alive)
            :extract("is_quest_escort")
            :any(function(i) return i end)

         if has_escort then
            Gui.mes("magic.return.prevented.normal")
            return
         end

         if chara:calc("inventory_weight_type") >= 4 then
            Gui.mes("magic.return.prevented.overweight")
            return
         end

         local dest = s.return_destination_map_uid
         if dest == nil or dest == map.uid then
            Gui.mes("common.nothing_happens")
            return
         end

         if Quest.is_non_returnable_quest_active() then
            Gui.mes("quest.deliver.you_commit_a_serious_crime")
            Effect.modify_karma(chara, -10)
         end

         local blocked = Event.trigger("elona.before_cast_return", {}, false)
         if blocked then
            return
         end

         Gui.play_sound("base.teleport1")
         Gui.mes("magic.return.door_opens")
         Gui.update_screen()
         Input.query_more()
         local map_uid = s.return_destination_map_uid
         s.return_destination_map_uid = nil

         local _, new_map = assert(Map.load(map_uid))
         Map.travel_to(new_map)
      end
   end
   -- <<<<<<<< shade2/main.hsp:732 			} ..
end

Event.register("base.before_chara_turn_start", "Proc return event", proc_return)

local function calc_wand_success(chara, params)
   -- >>>>>>>> shade2/proc.hsp:1511 	if (efId>=headSpell)&(efId<tailSpell){ ..
   local skill_data = Magic.skills_for_magic(params.magic_id)[1] or nil

   local item = params.item

   if not chara:is_player() or item:calc("is_zap_always_successful") then
      return true
   end

   local magic_device = chara:skill_level("elona.magic_device")

   local success
   if skill_data and skill_data.type == "spell" then
      success = false

      local skill = magic_device * 20 + 100
      if item:calc("curse_state") == Enum.CurseState.Blessed then
         skill = skill * 125 / 100
      end
      if Effect.is_cursed(item:calc("curse_state")) then
         skill = skill * 50 / 100
      elseif Rand.one_in(2) then
         success = true
      end
      if Rand.rnd(skill_data.difficulty + 1) / 2 <= skill then
         success = true
      end
   else
      success = true
   end

   if Rand.one_in(30) then
      success = false
   end

   return success
   -- <<<<<<<< shade2/proc.hsp:1521 	if rnd(30)=0:f=false ..
end
Event.register("elona.calc_wand_success", "Default", calc_wand_success)
