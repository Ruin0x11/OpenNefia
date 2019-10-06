local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Item = require("api.Item")
local I18N = require("api.I18N")

local function can_receive_reward()
   return true
end

data:add {
   _type = "elona_sys.dialog",
   _id = "test",

   root = "talk.unique.strange_scientist",
   nodes = {
      __start = function()
         local flag = 1 -- Internal.get_quest_flag("little_sister")
         if flag == 0 then
            return "first"
         elseif flag > 0 then
            return "dialog"
         end

         return "__IGNORED__"
      end,

      first = {
         text = {
            {"first"},
         },
         choices = {
            {"__END__", "__MORE__"},
         },
         on_finish = function()
            Item.create("elona.little_ball")

            Gui.mes(I18N.get("common.something_is_put_on_the_ground"))
            -- Gui.show_journal_update_message()

            -- Internal.set_quest_flag("little_sister", 1)
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

            if Chara.find("elona.little_sister", "ally") ~= nil then
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
            function() print("reward dialog") end,
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
            Item.create("elona.little_ball")
            Gui.mes(I18N.get("core.locale.common.something_is_put_on_the_ground"))
         end
      },

      turn_over = {
         text = {
            -- turn_over_little_sister,
            {"turn_over.dialog"},
         },
         choices = {
            {"__END__", "__MORE__"},
         }
      },
   }
}
