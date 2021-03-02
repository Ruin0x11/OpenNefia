local ElonaAction = require("mod.elona.api.ElonaAction")
local Chara = require("api.Chara")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Event = require("api.Event")

data:add {
   _type = "elona_sys.dialog",
   _id = "sex",

   nodes = {
      confirm = {
         text = "talk.npc.common.sex.prompt",
         choices = {
            {"accept", "talk.npc.common.sex.choices.accept"},
            {"elona.default:you_kidding", "talk.npc.common.sex.choices.go_back"}
         }
      },
      accept = {
         text = "talk.npc.common.sex.start",
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:2914 		gosub *sexsex: goto *chat_end ...
            ElonaAction.do_sex(Chara.player(), t.speaker)
            -- <<<<<<<< shade2/chat.hsp:2914 		gosub *sexsex: goto *chat_end ..
         end
      }
   }
}

local function add_sex_dialog_choice(speaker, params, result)
   -- >>>>>>>> shade2/chat.hsp:2307 	if (cDrunk(tc)!0)or(develop):if gArea!areaShowHou ...
   if (speaker:has_effect("elona.drunk") or config.base.development_mode)
      and not speaker:is_in_player_party()
      and not DeferredEvent.is_pending()
   then
      Dialog.add_choice("elona.sex:confirm", "talk.npc.common.choices.sex", result)
   end
   -- <<<<<<<< shade2/chat.hsp:2307 	if (cDrunk(tc)!0)or(develop):if gArea!areaShowHou ..

   return result
end

Event.register("elona.calc_dialog_choices", "Add sex dialog choice", add_sex_dialog_choice)
