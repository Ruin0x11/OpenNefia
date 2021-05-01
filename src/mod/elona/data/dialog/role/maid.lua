local Chara = require("api.Chara")
local I18N = require("api.I18N")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Event = require("api.Event")
local Rand = require("api.Rand")

data:add {
   _type = "elona_sys.dialog",
   _id = "maid",

   nodes = {
      meet_guest_prompt = {
         text = function(t)
            local guests = I18N.get("talk.random.params.maid", save.elona.waiting_guests)
            return {
               I18N.get("talk.random.maid", t.speaker, Chara.player(), guests)
            }
         end,
         choices = {
            {"meet_guest_yes", "talk.npc.maid.choices.meet_guest"},
            {"meet_guest_no", "talk.npc.maid.choices.do_not_meet"}
         }
      },
      meet_guest_yes = function(t)
         save.elona.waiting_guests = save.elona.waiting_guests - 1
         local map = t.speaker:current_map()
         DeferredEvent.add(function() DeferredEvents.meet_house_guest(map) end)
         return "__END__"
      end,
      meet_guest_no = {
         on_start = function()
            save.elona.waiting_guests = save.elona.waiting_guests - 1
         end,
         text = "talk.npc.maid.do_not_meet",
         choices = {
            {"elona.default:__start", "ui.more"}
         }
      }
   }
}

local function day_passes()
   local guests = save.elona.waiting_guests
   if guests < 3 and Rand.one_in(8 + guests * 5) then
      save.elona.waiting_guests = guests + 1
   end
end
Event.register("base.on_day_passed", "Update waiting guest count", day_passes, 100000)

local function prompt_maid_waiting_guests(_, params, result)
   local chara = params.talk.speaker
   if chara:find_role("elona.maid") then
      if result.node_id == "elona.default:__start" then
         if save.elona.waiting_guests > 0 then
            result.node_id = "elona.maid:meet_guest_prompt"
         end
      end
   end
   return result
end
Event.register("elona_sys.on_step_dialog", "Prompt maid waiting guests", prompt_maid_waiting_guests)
