local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Chara = require("api.Chara")
local Gui = require("api.Gui")

data:add {
   _type = "elona_sys.dialog",
   _id = "kaneda_bike",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.kaneda_bike")
         if flag >= 3 then
            return "query_join"
         end

         return "check_drug"
      end,

      query_join = {
         text = "talk.unique.kaneda_bike.after_drug.dialog",
         choices = {
            {"query_join_yes", "talk.unique.kaneda_bike.after_drug.choices.yes"},
            {"query_join_no", "talk.unique.kaneda_bike.after_drug.choices.no"}
         },
         default_choice = "query_join_no"
      },
      query_join_yes = function()
         if not Chara.player():can_recruit_allies() then
            return "party_full"
         end

         return "join_party"
      end,
      query_join_no = {
         text = "talk.unique.kaneda_bike.after_drug.no",
      },
      party_full = {
         text = "talk.unique.kaneda_bike.after_drug.yes.party_full",
      },
      join_party = {
         text = "talk.unique.kaneda_bike.after_drug.yes.dialog",
         on_finish = function(t)
            Chara.player():recruit_as_ally(t.speaker)
            Sidequest.set_progress("elona.kaneda_bike", 0)
            t.speaker.dialog = nil
         end
      },

      check_drug = function()
         if Chara.player():find_item("elona.blue_capsule_drug") ~= nil then
            return "query_give_drug"
         end

         return "do_not_have_drug"
      end,
      query_give_drug = {
         text = "talk.unique.kaneda_bike.before_drug.dialog",
         choices = {
            {"give_drug", "talk.unique.kaneda_bike.before_drug.choices.yes"},
            {"do_not_have_drug", "talk.unique.kaneda_bike.before_drug.choices.no"}
         },
         default_choice = "do_not_have_drug"
      },
      give_drug = {
         on_start = function()
            local drug = Chara.player():find_item("elona.blue_capsule_drug")
            drug.amount = drug.amount - 1
            Gui.mes("talk.unique.kaneda_bike.before_drug.yes.you_hand_him")
            Gui.play_sound("base.equip1")
         end,
         text = "talk.unique.kaneda_bike.before_drug.yes.dialog",
         on_finish = function()
            local flag = Sidequest.progress("elona.kaneda_bike")
            Sidequest.set_progress("elona.kaneda_bike", flag + 1)
         end
      },
      do_not_have_drug = {
         text = "talk.unique.kaneda_bike.do_not_have_drug",
      },
   }
}
