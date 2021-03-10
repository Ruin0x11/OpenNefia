local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Event = require("api.Event")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Gui = require("api.Gui")
local Servant = require("mod.elona.api.Servant")

data:add {
   _type = "elona_sys.dialog",
   _id = "servant",

   nodes = {
      fire_confirm = {
         text = "talk.npc.servant.fire.prompt",
         choices = {
            {"fire", "talk.npc.servant.fire.choices.yes"},
            {"elona.default:__start", "talk.npc.servant.fire.choices.no"}
         }
      },
      fire = function(t)
         -- >>>>>>>> shade2/chat.hsp:2750 			txt lang(""+name(tc)+"を解雇した… ","You dismiss "+n ...
         Gui.mes("talk.npc.servant.fire.you_dismiss", t.speaker)
         t.speaker:vanquish()
         -- <<<<<<<< shade2/chat.hsp:2753 			goto *chat_end ..
      end
   }
}

local function fire_servant_choice(speaker, params, result)
   if Servant.is_servant(speaker) and not DeferredEvent.is_pending() then
      Dialog.add_choice("elona.servant:fire_confirm", "talk.npc.servant.choices.fire", result)
   end
   return result
end
Event.register("elona.calc_dialog_choices", "Add choice to fire servant", fire_servant_choice, { priority = 100000 })
