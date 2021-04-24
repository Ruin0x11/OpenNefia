local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Chara = require("api.Chara")
local common = require("mod.elona.data.dialog.common")
local Item = require("api.Item")
local Gui = require("api.Gui")

data:add {
   _type = "elona_sys.dialog",
   _id = "erystia",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.main_quest")
         if flag >= 200 then
            return "late"
         elseif flag == 120 then
            return "all_stones"
         elseif flag == 105 then
            return "stones"
         elseif flag >= 60 then
            return "investigation"
         elseif flag == 50 then
            return "introduction"
         end
         return "elona_sys.ignores_you:__start"
      end,

      late = {
         text = {
            "talk.unique.erystia.late._0",
            "talk.unique.erystia.late._1",
            {"talk.unique.erystia.late._2", args = function() return {Chara.player():calc("title"), Chara.player():calc("name")} end},
         },
         choices = {
            {"__END__", "ui.more"},
         }
      },

      all_stones = {
         text = {
            {"talk.unique.erystia.all_stones.dialog._0", args = common.args_name},
            "talk.unique.erystia.all_stones.dialog._1",
            "talk.unique.erystia.all_stones.dialog._2",
            {"talk.unique.erystia.all_stones.dialog._3", args = common.args_name},
         },
         on_finish = function()
            Gui.play_sound("base.write1")
            Gui.mes_c("talk.unique.erystia.all_stones.you_receive", "Green")
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.palmia_pride", player.x, player.y, {}, map)
            Gui.mes("common.something_is_put_on_the_ground")
            Sidequest.set_progress("elona.main_quest", 125)
         end
      },

      stones = {
         text = {
            {"talk.unique.erystia.stones.dialog._0", args = common.args_name},
            function() Gui.fade_out() end,
            "talk.unique.erystia.stones.dialog._1",
            "talk.unique.erystia.stones.dialog._2",
            "talk.unique.erystia.stones.dialog._3",
            "talk.unique.erystia.stones.dialog._4",
         },
         on_finish = function()
            Gui.play_sound("base.write1")
            Gui.mes_c("talk.unique.erystia.stones.you_receive", "Green")
            Sidequest.set_progress("elona.main_quest", 110)
         end
      },

      investigation = {
         text = {
            {"talk.unique.erystia.investigation.dialog", args = common.args_name},
         },
         choices = function()
            local choices = {
               {"lesmias", "talk.unique.erystia.investigation.choices.lesimas"},
               {"mission", "talk.unique.erystia.investigation.choices.mission"},
            }
            local flag = Sidequest.progress("elona.main_quest")

            if flag >= 100 and flag <= 120 then
               table.insert(choices, {"stones_castle", "talk.unique.erystia.investigation.choices.stones.castle"})
               table.insert(choices, {"stones_inferno", "talk.unique.erystia.investigation.choices.stones.inferno"})
               table.insert(choices, {"stones_crypt", "talk.unique.erystia.investigation.choices.stones.crypt"})
            end

            table.insert(choices, {"__END__", "ui.bye"})

            return choices
         end
      },
      lesmias = {
         text = {
            "talk.unique.erystia.investigation.lesmias._0",
            "talk.unique.erystia.investigation.lesmias._1",
            "talk.unique.erystia.investigation.lesmias._2",
            "talk.unique.erystia.investigation.lesmias._3",
            "talk.unique.erystia.investigation.lesmias._4",
         },
         choices = {
            {"__start", "ui.more"},
         }
      },

      mission = function()
         local flag = Sidequest.progress("elona.main_quest")

         if flag >= 125 then
            return "mission_excavation"
         elseif flag >= 110 then
            return "mission_stones_0"
         else
            return "mission_stones_1"
         end
      end,
      mission_excavation = {
         text = {
            "talk.unique.erystia.investigation.mission.excavation._0",
            "talk.unique.erystia.investigation.mission.excavation._1",
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      mission_stones_0 = {
         text = "talk.unique.erystia.investigation.mission.stones._0",
         choices = {
            {"__start", "ui.more"},
         }
      },
      mission_stones_1 = {
         text = {
            {"talk.unique.erystia.investigation.mission.stones._1", args = common.args_name},
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      stones_castle = {
         text = {
            "talk.unique.erystia.investigation.castle._0",
            "talk.unique.erystia.investigation.castle._1",
            "talk.unique.erystia.investigation.castle._2",
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      stones_inferno = {
         text = {
            "talk.unique.erystia.investigation.inferno._0",
            "talk.unique.erystia.investigation.inferno._1",
            "talk.unique.erystia.investigation.inferno._2",
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      stones_crypt = {
         text = {
            "talk.unique.erystia.investigation.crypt._0",
            "talk.unique.erystia.investigation.crypt._1",
            "talk.unique.erystia.investigation.crypt._2",
         },
         choices = {
            {"__start", "ui.more"},
         }
      },

      introduction = {
         text = {
            {"talk.unique.erystia.introduction.dialog", args = common.args_name},
         },
         choices = {
            {"pledge_strength", "talk.unique.erystia.introduction.choices.pledge_strength"},
            {"not_interested", "talk.unique.erystia.introduction.choices.not_interested"},
         },
         default_choice = "not_interested"
      },
      not_interested = {
         text = "talk.unique.erystia.introduction.not_interested",
      },
      pledge_strength = {
         text = {
            "talk.unique.erystia.introduction.pledge_strength.dialog._0",
            "talk.unique.erystia.introduction.pledge_strength.dialog._1",
            "talk.unique.erystia.introduction.pledge_strength.dialog._2",
            {"talk.unique.erystia.introduction.pledge_strength.dialog._3", args = common.args_name},
         },
         on_finish = function()
            -- >>>>>>>> shade2/chat.hsp:859 		snd seSave:txtEf coGreen:txt lang("レシマス4階の鍵を受け取っ ...
            Gui.play_sound("base.write1")
            Gui.mes_c("talk.unique.erystia.introduction.pledge_strength.you_receive", "Green")
            Sidequest.set_progress("elona.main_quest", 60)
            -- <<<<<<<< shade2/chat.hsp:860 		flagMain=60 ..
         end
      }
   }
}
