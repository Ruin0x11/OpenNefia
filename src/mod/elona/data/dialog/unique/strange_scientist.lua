local Chara = require("game.Chara")
local GUI = require("game.GUI")
local I18N = require("game.I18N")
local Internal = require("game.Internal")
local Item = require("game.Item")
local table = require("game.table")

local function can_receive_reward()
   local count = Sidequest.progress("elona.kill_count_of_little_sister")

   for i=1,Sidequest.progress("elona.gift_count_of_little_sister")+1 do
      count = count + i
   end

    return Sidequest.progress("elona.save_count_of_little_sister") >= count
end

local function turn_over_little_sister()
    GUI.txt(I18N.get("core.talk.unique.strange_scientist.turn_over.text"))
    Sidequest.set_progress("elona.save_count_of_little_sister",
                            Sidequest.progress("elona.save_count_of_little_sister") + 1)
    GUI.txt(I18N.get("core.talk.unique.strange_scientist.saved_count",
                     Sidequest.progress("elona.save_count_of_little_sister"),
                     Sidequest.progress("elona.kill_count_of_little_sister")), "Green")
    Chara.find("core.little_sister", "Allies"):vanquish()
    GUI.play_sound("core.complete1")
end

return {
   id = "strange_scientist",
   root = "core.talk.unique.strange_scientist",
   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.little_sister")
         if flag == 0 then
            return "first"
         elseif flag > 0 then
            return "dialog"
         end

         return "elona_sys.ignores_you:__start"
      end,

      first = {
         text = {
            {"first"},
         },
         choices = {
            {"__END__", "__MORE__"},
         },
         on_finish = function()
            Item.create(Chara.player().position, "core.little_ball", 0)

            GUI.txt(I18N.get("core.common.something_is_put_on_the_ground"))
            GUI.show_journal_update_message()

            Sidequest.set_progress("elona.little_sister", 1)
         end
      },

      dialog = {
         text = {
            {"dialog"}
         },
         choices = function()
            local choices = {
               {"reward_check", "choices.reward"},
               {"replenish", "choices.replenish"}
            }

            if Chara.find("core.little_sister", "Allies") ~= nil then
               table.insert(choices, {"turn_over", "choices.turn_over"})
            end
            table.insert(choices, {"__END__", "__BYE__"})

            return choices
         end
      },

      reward_check = function()
         if can_receive_reward() then
            return "reward_pick"
         end

         return "reward_not_enough"
      end,
      reward_pick = {
         text = {
            {"reward.dialog"},
            Internal.strange_scientist_pick_reward,
            {"reward.find"},
         },
      },
      reward_not_enough = {
         text = {
            {"reward.not_enough"},
         },
      },

      replenish = {
         text = {
            {"replenish"},
         },
         on_finish = function()
            Item.create(Chara.player().position, "core.little_ball", 0)
            GUI.txt(I18N.get("core.common.something_is_put_on_the_ground"))
         end
      },

      turn_over = {
         text = {
            turn_over_little_sister,
            {"turn_over.dialog"},
         },
         choices = {
            {"__END__", "__MORE__"},
         }
      },
   }
}
