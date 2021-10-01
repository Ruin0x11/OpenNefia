local Effect = require("mod.elona.api.Effect")
local Event = require("api.Event")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")
local Const = require("api.Const")
local Chara = require("api.Chara")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Gui = require("api.Gui")

data:add {
   _type = "elona_sys.dialog",
   _id = "ally",

   nodes = {
      marry = function(t)
         -- >>>>>>>> shade2/chat.hsp:2720 		if cImpression(tc)<defImpMarry :buff=lang("("+na ...
         if t.speaker:calc("impression") < Const.IMPRESSION_MARRY then
            return "marry_refuse"
         end

         return "marry_accept"
         -- <<<<<<<< shade2/chat.hsp:2723 		marry=tc:evAdd evMarry : goto *chat_end ..
      end,
      marry_refuse = {
         text = "talk.npc.ally.marriage.refuses",
         jump_to = "elona.default:__start"
      },
      marry_accept = {
         text = "talk.npc.ally.marriage.accepts",
         choices = {
            {"marry_event", "ui.more"}
         }
      },
      marry_event = function(t)
         local origin = Chara.player()
         local target = t.speaker
         local aspect = target:get_aspect_or_default(ICharaElonaFlags)
         aspect.is_married = true
         DeferredEvent.add(function() DeferredEvents.marry(target, origin) end)
         return "__END__"
      end,

      talk_silence_start = {
         on_start = function(t)
            t.speaker.is_talk_silenced = true
         end,
         text = "talk.npc.ally.silence.start",
         jump_to = "elona.default:__start"
      },
      talk_silence_stop = {
         on_start = function(t)
            t.speaker.is_talk_silenced = false
         end,
         text = "talk.npc.ally.silence.stop",
         jump_to = "elona.default:__start"
      },

      abandon = {
         text = "talk.npc.ally.abandon.prompt",
         choices = {
            {"abandon_confirm", "talk.npc.ally.abandon.choices.yes"},
            {"elona.default:__start", "talk.npc.ally.abandon.choices.no"}
         }
      },
      abandon_confirm = function(t)
         Gui.mes("talk.npc.ally.abandon.you_abandoned", t.speaker)
         t.speaker:vanquish()
         return "__END__"
      end
   }
}

local function add_ally_dialog_choices(speaker, params, result)
   -- >>>>>>>> shade2/chat.hsp:2231 	if tc<maxFollower:if cBit(cBodyguard,tc)=false:if ...
   if speaker:is_in_player_party() and not Effect.is_temporary_ally(speaker) then
      if not speaker:calc_aspect_base(ICharaElonaFlags, "is_married") then
         Dialog.add_choice("elona.ally:marry", "talk.npc.ally.choices.ask_for_marriage", result)
      end
      if not speaker.is_talk_silenced then
         Dialog.add_choice("elona.ally:talk_silence_start", "talk.npc.ally.choices.silence.start", result)
      else
         Dialog.add_choice("elona.ally:talk_silence_stop", "talk.npc.ally.choices.silence.stop", result)
      end
      Dialog.add_choice("elona.ally:abandon", "talk.npc.ally.choices.abandon", result)
   end

   return result
   -- <<<<<<<< shade2/chat.hsp:2236 		} ..
end
Event.register("elona.calc_dialog_choices", "Add ally dialog choices", add_ally_dialog_choices)
