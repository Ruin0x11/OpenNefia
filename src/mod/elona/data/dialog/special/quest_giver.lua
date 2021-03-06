local Quest = require("mod.elona_sys.api.Quest")
local Event = require("api.Event")

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_giver",

   root = "talk.npc.quest_giver",
   nodes = {
      quest_about = {
         text = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest, "Character doesn't have a quest.")
            local _, desc = Quest.format_name_and_desc(quest, t.speaker, false)
            return {{desc}}
         end,
         choices = {
            {"before_accept", "talk.npc.quest_giver.about.choices.take"},
            {"elona.default:you_kidding", "talk.npc.quest_giver.about.choices.leave"}
         }
      },
      before_accept = function(t)
         local quest = Quest.for_client(t.speaker)
         assert(quest, "Character doesn't have a quest.")

         if Quest.iter_accepted():length() >= 5 then
            return "too_many_unfinished"
         end

         local quest_proto = data["elona_sys.quest"]:ensure(quest._id)

         local node = "accept"
         if quest_proto.on_accept then
            local ok
            ok, node = quest_proto.on_accept(quest, t.speaker)
            if not ok then
               assert(node, "`on_accept()` must return a boolean and dialog node")
               return node
            end
         end

         quest.state = "accepted"

         return node or "accept"
      end,
      too_many_unfinished = {
         text = {
            {"talk.npc.quest_giver.about.too_many_unfinished"}
         },
         jump_to = "elona.default:__start"
      },
      accept = {
         text = {
            {"talk.npc.quest_giver.about.thanks"}
         },
         jump_to = "elona.default:__start"
      },
      finish = function(t)
         local quest = Quest.for_client(t.speaker)
         assert(quest, "Character doesn't have a quest.")
         local next_node = Quest.complete(quest, t.speaker)
         return next_node
      end,
      complete_default = {
         text = {
            {"quest.giver.complete.done_well"}
         },
         jump_to = "elona.default:__start"
      }
   },
}

local function add_quest_dialog(speaker, params, result)
   local quest = Quest.for_client(speaker)
   if quest and quest.state == "not_accepted" then
      table.insert(result, {"elona.quest_giver:quest_about", "talk.npc.quest_giver.choices.about_the_work"})
   end

   return result
end

Event.register("elona.calc_dialog_choices", "Add quest dialog choices", add_quest_dialog)
