local Item = require("api.Item")
local Gui = require("api.Gui")

local activity = {
   {
      _id = "eating",
      params = { food = "table", no_message = "boolean" },
      turns = 8,

      events = {
         {
            id = "base.on_activity_start",
            name = "start",

            callback = function(self, params)
               -- TODO error handling
               local chara = params.chara
               if chara:is_in_fov() then
                  Gui.play_sound("base.eat1")
                  if self.food.own_state == "not_owned" and chara:is_ally() then
                     Gui.mes(chara.uid .. ": start eat in secret ")
                  else
                     Gui.mes(chara.uid .. ": start eat normal ")
                  end
               end

               self.food:emit("elona.on_eat_item_begin", {chara=chara})
            end
         },
         {
            id = "base.on_activity_pass_turns",
            name = "start",

            callback = function(self)
               if not Item.is_alive(self.food) then
                  return "interrupt"
               end
            end
         },
         {
            id = "base.on_activity_finish",
            name = "finish",

            callback = function(self, params)
               local chara = params.chara
               if not self.no_message then
                  Gui.mes_visible(chara.uid .. ": Eat act finish.", chara.x, chara.y)
               end

               -- apply general eating effect
               self.food:emit("elona.on_eat_item_effect", {chara=chara})

               if chara:is_player() then
                  -- partly identify
               end

               if self.food:unequip() then
                  chara:refresh()
               end

               self.food.amount = self.food.amount - 1

               if chara:is_player() then
                  Gui.mes("Show eating message")
               else
                  if chara.item_to_be_used
                  and chara.item_to_be_used.uid == self.food
                  then
                     chara.item_to_be_used = nil
                  end

                  -- quest
               end

               -- anorexia

               -- mochi
               self.food:emit("elona.on_eat_item_finish", {chara=chara})
            end
         }
      }
   }
}

data:add_multi("base.activity", activity)
