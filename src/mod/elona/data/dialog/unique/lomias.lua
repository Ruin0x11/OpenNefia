local Area = require("api.Area")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Item = require("api.Item")
local Itemgen = require("mod.tools.api.Itemgen")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Enum = require("api.Enum")

local common = require("mod.elona.data.dialog.common")

local function is_digging_tutorial_step(map)
   return Area.current()._archetype == "elona.your_home" and Sidequest.progress("elona.tutorial") == 2
end


Event.register("elona.hook_calc_dig_success", "Digging in tutorial", function(map, _, result)
                  if is_digging_tutorial_step(map) then
                     return true
                  end

                  return result
end)

Event.register("elona.on_dig_success", "Digging in tutorial", function(map, params)
                  if is_digging_tutorial_step(map) then
                     Map.force_clear_pos(params.dig_x, params.dig_y, map)
                     local item = Item.create("elona.worthless_fake_gold_bar", params.dig_x, params.dig_y, {}, map)
                     item.curse_state = Enum.CurseState.Cursed
                     Sidequest.set_progress("elona.tutorial", 3)
                  end
end)

data:add {
   _type = "elona_sys.dialog",
   _id = "lomias_game_begin",

   nodes = {
      __start = function()
         if save.elona.is_lomias_easter_egg_enabled then
            return "easter_egg"
         else
            Gui.mes_newline()
         end

         return "game_begin"
      end,

      easter_egg = {
         text = {
            function() Chara.player():apply_effect("elona.blindness", 100) end,
            {"talk.unique.lomias.begin.easter_egg._0", speaker = "elona.larnneire"},
            {"talk.unique.lomias.begin.easter_egg._1", speaker = "elona.lomias"},
            function()
               Gui.update_screen()
               Gui.wait(3000)
               Gui.mes_newline()
               Gui.mes_c("talk.unique.lomias.begin.easter_egg.something_is_killed", "Red")
               Gui.play_sound("base.kill1")
               Map.spill_blood(28, 6, 10)
               Item.create("elona.beggars_pendant", 28, 6)
               Gui.update_screen()
               Gui.wait(500)
               Gui.wait(500)
            end,
            {"talk.unique.lomias.begin.easter_egg._2", speaker = "elona.larnneire"},
            {"talk.unique.lomias.begin.easter_egg._3", speaker = "elona.lomias"},
            {"talk.unique.lomias.begin.easter_egg._4", speaker = "elona.larnneire"},
            {"talk.unique.lomias.begin.easter_egg._5", speaker = "elona.lomias"},
            {"talk.unique.lomias.begin.easter_egg._6", speaker = "elona.larnneire"},
         },
         choices = {
            {"game_begin", "ui.more"}
         },
         on_finish = function()
            Gui.wait(1500)
            Gui.update_screen()
            Gui.fade_out()
            Gui.mes("talk.unique.lomias.begin.easter_egg.was_dream")
         end
      },

      game_begin = {
         text = {
            function() Gui.mes("talk.unique.lomias.begin.regain_consciousness") end,
            {"talk.unique.lomias.begin._0"},
            {"talk.unique.lomias.begin._1"},
            {"talk.unique.lomias.begin._2"},
            {"talk.unique.lomias.begin._3", speaker = "elona.larnneire"},
            {"talk.unique.lomias.begin._4", args = common.args_name, speaker = "elona.lomias"},
         },
         choices = {
            {"elona.lomias:__start", "ui.more"}
         },
         on_finish = function(t)
            t.speaker:current_map().music = "elona.home"
            Gui.play_music("elona.home")
         end
      }
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "lomias",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.tutorial")
         if flag == 0 then
            return "tutorial_0"
         elseif flag == 1 then
            return "tutorial_1"
         elseif flag == 2 then
            return "tutorial_2"
         elseif flag == 3 then
            return "tutorial_3"
         elseif flag == 4 then
            return "tutorial_4"
         elseif flag == 5 then
            return "tutorial_5"
         elseif flag == 6 then
            return "tutorial_6"
         elseif flag == 7 then
            return "tutorial_7"
         elseif flag == 8 then
            return "tutorial_8"
         elseif flag == 99 then
            return "tutorial_99"
         elseif flag == -1 then
            return "tutorial_after"
         end

         return "__END__"
      end,
      tutorial_0 = {
         text = {
            {"talk.unique.lomias.tutorial.before.dialog"},
         },
         choices = {
            {"start_tutorial", "talk.unique.lomias.tutorial.before.choices.yes"},
            {"__END__", "talk.unique.lomias.tutorial.before.choices.no"},
            {"get_out", "talk.unique.lomias.after.choices.get_out"}
         }
      },
      tutorial_1 = {
         text = {
            {"talk.unique.lomias.tutorial.movement.dialog._0"},
            {"talk.unique.lomias.tutorial.movement.dialog._1"},
            {"talk.unique.lomias.tutorial.movement.dialog._2"},
            {"talk.unique.lomias.tutorial.movement.dialog._3"},
         },
         choices = {
            {"__END__", "talk.unique.lomias.tutorial.movement.choices.alright"},
            {"ate", "talk.unique.lomias.tutorial.movement.choices.ate"}
         }
      },
      tutorial_2 = {
         text = {
            {"talk.unique.lomias.tutorial.skills.dialog._0"},
            {"talk.unique.lomias.tutorial.skills.dialog._1"},
            {"talk.unique.lomias.tutorial.skills.dialog._2"},
         },
         choices = {
            {"__END__", "talk.unique.lomias.tutorial.skills.response"}
         }
      },
      tutorial_3 = {
         text = {
            function()
               Gui.mes("common.something_is_put_on_the_ground")
               local scroll = Item.create("elona.scroll_of_identify", Chara.player().x, Chara.player().y)
               scroll.identify_state = Enum.IdentifyState.Full
            end,
            {"talk.unique.lomias.tutorial.after_dig.dialog"},
         },
         choices = {
            {"__start", "ui.more"}
         },
         on_finish = function()
            Sidequest.set_progress("elona.tutorial", 4)
         end
      },
      tutorial_4 = {
         text = {
            {"talk.unique.lomias.tutorial.identify.dialog._0"},
            {"talk.unique.lomias.tutorial.identify.dialog._1"},
            {"talk.unique.lomias.tutorial.identify.dialog._2"},
         },
         choices = {
            {"__END__", "talk.unique.lomias.tutorial.identify.choices.alright"},
            {"identify_done", "talk.unique.lomias.tutorial.identify.choices.done"},
         }
      },
      tutorial_5 = {
         text = {
            {"talk.unique.lomias.tutorial.equip.dialog"}
         },
         choices = {
            {"__END__", "talk.unique.lomias.tutorial.equip.choices.alright"},
            {"equip_done", "talk.unique.lomias.tutorial.equip.choices.done"},
         }
      },
      tutorial_6 = function()
         if Chara.find("elona.putit", "others") ~= nil then
            return "tutorial_6_not_finished"
         end
         return "tutorial_6_finished"
      end,
      tutorial_6_not_finished = {
         text = {
            {"talk.unique.lomias.tutorial.combat.not_finished"}
         }
      },
      tutorial_6_finished = {
         text = {
            {"talk.unique.lomias.tutorial.combat.finished"}
         },
         choices = {
            {"tutorial_7", "ui.more"}
         },
         on_finish = function()
            Sidequest.set_progress("elona.tutorial", 7)
         end
      },
      tutorial_7 = {
         text = {
            {"talk.unique.lomias.tutorial.chests.dialog._0"},
            {"talk.unique.lomias.tutorial.chests.dialog._1"},
            function()
               local chest = Item.create("elona.chest", Chara.player().x, Chara.player().y)
               chest.params.chest_item_level = 35
               chest.params.chest_lockpick_difficulty = 25
               Item.create("elona.lockpick", Chara.player().x, Chara.player().y, {amount=2})
               Gui.mes("common.something_is_put_on_the_ground")
            end,
            {"talk.unique.lomias.tutorial.chests.dialog._2"},
         },
         choices = {
            {"__END__", "talk.unique.lomias.tutorial.chests.response"}
         },
         on_finish = function()
            Sidequest.set_progress("elona.tutorial", 8)
         end
      },
      tutorial_8 = {
         text = {
            {"talk.unique.lomias.tutorial.house.dialog._0"},
            {"talk.unique.lomias.tutorial.house.dialog._1"},
            {"talk.unique.lomias.tutorial.house.dialog._2"},
            {"talk.unique.lomias.tutorial.house.dialog._3"}
         },
         choices = {
            {"__start", "ui.more"}
         },
         on_finish = function()
            Sidequest.set_progress("elona.tutorial", 99)
         end
      },
      tutorial_99 = {
         text = {
            {"talk.unique.lomias.tutorial.end.dialog._0"},
            {"talk.unique.lomias.tutorial.end.dialog._1"}
         },
         on_finish = function()
            Sidequest.set_progress("elona.tutorial", -1)
         end
      },
      tutorial_after = {
         text = {
            {"talk.unique.lomias.after.dialog"}
         },
         choices = {
            {"__END__", "talk.unique.lomias.after.choices.nothing"},
            {"get_out", "talk.unique.lomias.after.choices.get_out"}
         }
      },
      start_tutorial = {
         text = {
            {"talk.unique.lomias.tutorial.before.yes"}
         },
         choices = {
            {"__start", "ui.more"}
         },
         on_finish = function()
            local corpse = Item.create("elona.corpse", Chara.player().x, Chara.player().y)
            corpse.params = { chara_id = "elona.beggar" }
            corpse.identify_state = Enum.IdentifyState.Full
            Gui.mes("common.something_is_put_on_the_ground")
            Sidequest.set_progress("elona.tutorial", 1)
         end
      },
      get_out = function(t)
         local larnneire = Chara.find("elona.larnneire", "others")
         if not Chara.is_alive(larnneire) then
            local lomias = Chara.find("elona.lomias", "others")
            Chara.player():act_hostile_towards(lomias)
            t:say("talk.unique.lomias.after.get_out.larnneire_died", "__BYE__")
            return "__END__"
         end
         return "get_out_1"
      end,
      get_out_1 = {
         text = {
            {"talk.unique.lomias.after.get_out.dialog._0", args = common.args_name, speaker = "elona.larnneire"},
            {"talk.unique.lomias.after.get_out.dialog._1", speaker = "elona.lomias"},
            {"talk.unique.lomias.after.get_out.dialog._2", args = common.args_title},
         },
         on_finish = function()
            Chara.find("elona.larnneire", "others"):vanquish()
            Chara.find("elona.lomias", "others"):vanquish()

            Gui.mes_c("quest.completed", "Green")
            Gui.play_sound("base.complete1")
            Gui.mes("common.something_is_put_on_the_ground")
            for _ = 0, 2 do
               Itemgen.create(Chara.player().x, Chara.player().y, {categories = {"elona.furniture"}})
            end
         end
      },
      ate = {
         text = {
            {"talk.unique.lomias.tutorial.movement.ate.dialog._0", choice = "talk.unique.lomias.tutorial.movement.ate.response"},
            {"talk.unique.lomias.tutorial.movement.ate.dialog._1"},
            {"talk.unique.lomias.tutorial.movement.ate.dialog._2"},
         },
         choices = {
            {"__start", "ui.more"}
         },
         on_finish = function()
            Sidequest.set_progress("elona.tutorial", 2)
         end
      },
      identify_done = {
         text = {
            {"talk.unique.lomias.tutorial.identify.done.dialog._0"},
            {"talk.unique.lomias.tutorial.identify.done.dialog._1"},
         },
         choices = {
            {"__start", "ui.more"}
         },
         on_finish = function()
            local item = Item.create("elona.long_bow", Chara.player().x, Chara.player().y)
            item.curse_state = Enum.CurseState.Cursed

            item = Item.create("elona.arrow", Chara.player().x, Chara.player().y)
            item.curse_state = Enum.CurseState.Normal

            item = Item.create("elona.scroll_of_vanish_curse", Chara.player().x, Chara.player().y)
            item.identify_state = Enum.IdentifyState.Full
            item.curse_state = Enum.CurseState.Blessed

            Gui.mes("common.something_is_put_on_the_ground")

            Sidequest.set_progress("elona.tutorial", 5)
         end
      },
      equip_done = {
         text = {
            {"talk.unique.lomias.tutorial.equip.done.dialog._0"},
            {"talk.unique.lomias.tutorial.equip.done.dialog._1"},
            {"talk.unique.lomias.tutorial.equip.done.dialog._2"}
         },
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function()
            Gui.mes_c("talk.unique.lomias.tutorial.equip.done.lomias_releases", "SkyBlue")
            for i=0,2 do
               local putit = Chara.create("elona.putit", Chara.player().x, Chara.player().y)
               putit.is_not_targeted_by_ai = true
            end
            local item = Item.create("elona.potion_of_cure_minor_wound", Chara.player().x, Chara.player().y)
            item.identify_state = Enum.IdentifyState.Full
            Sidequest.set_progress("elona.tutorial", 6)
         end
      }
   }
}
