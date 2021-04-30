local Area = require("api.Area")
local God = require("mod.elona.api.God")
local Chara = require("api.Chara")
local Item = require("api.Item")

data:add {
   _type = "elona_sys.dialog",
   _id = "part_time_worker",

   nodes = {
      __start = function(t)
         local map = t.speaker:current_map()
         local area = map and Area.for_map(map)

         if not (map._archetype == "elona.noyel"
                    and area
                    and area.metadata.is_noyel_christmas_festival)
         then
            return "__END__"
         end
         if Chara.player().god == "elona.jure" then
            return "already_believe_in_jure"
         end

         return "dialog"
      end,
      already_believe_in_jure = {
         text = "talk.unique.part_time_worker.already_believe_in_jure",
      },
      dialog = {
         text = "talk.unique.part_time_worker.dialog",
         choices = {
            {"confirm", "talk.unique.part_time_worker.choices.yes"},
            {"no", "talk.unique.part_time_worker.choices.no"}
         },
         default_choice = "no"
      },
      confirm = {
         text = "talk.unique.part_time_worker.yes.dialog",
         choices = {
            {"convert_to_jure", "talk.unique.part_time_worker.yes.choices.yes"},
            {"no", "talk.unique.part_time_worker.yes.choices.no"}
         },
         default_choice = "no"
      },
      convert_to_jure = {
         text = "talk.unique.part_time_worker.yes.yes",
         on_finish = function()
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.jures_body_pillow", player.x, player.y, {}, map)
            God.switch_religion(player, "elona.jure")
         end
      },
      no = {
         text = "talk.unique.part_time_worker.no",
      },
   }
}
