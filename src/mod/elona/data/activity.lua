local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Rand = require("api.Rand")

local activity = {
   {
      _id = "eating",
      params = { food = "table", no_message = "boolean" },
      default_turns = 8,

      animation_wait = 5,

      on_interrupt = "prompt",

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

               self.food.chara_using = chara
               self.food:emit("elona.on_eat_item_begin", {chara=chara})
            end
         },
         {
            id = "base.on_activity_pass_turns",
            name = "pass turns",

            callback = function(self, params)
               if not Item.is_alive(self.food) then
                  return { action = "stop" }
               end

               -- TODO cargo check

               self.food.chara_using = params.chara

               return { turn_result = "turn_end" }
            end
         },
         {
            id = "base.on_activity_cleanup",
            name = "start",

            callback = function(self)
               if not Item.is_alive(self.food) then
                  return
               end
               self.food.chara_using = nil
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

               if chara:unequip_item(self.food) then
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
   },
   {
      _id = "fishing",

      params = { item = "table" },
      default_turns = 100,

      animation_wait = 2,

      on_interrupt = "stop",
      events = {
         {
            id = "base.on_activity_start",
            name = "start",

            callback = function(self, params)
            end
         },
         {
            id = "base.on_activity_pass_turns",
            name = "pass turns",

            callback = function(self, params)
               if Rand.one_in(5) then
                  self.state = 1
                  self.fish = "the fish"
               end

               if self.state == 1 then
                  if Rand.one_in(5) then
                     Gui.mes("fishwait")
                     if Rand.one_in(3) then
                        self.state = 2
                     end
                     if Rand.one_in(6) then
                        self.state = 0
                     end
                     self.animation = 0
                  end
               end
               if self.state == 2 then
                  self.animation = 2
                  Gui.play_sound("base.water2")
                  Gui.mes("fishwait2")
                  if Rand.one_in(10) then
                     self.state = 3
                  else
                     self.state = 0
                  end
                  self.animation = 0
               end
               if self.state == 3 then
                  self.animation = 3
                  Gui.mes("fishwait3")
                  local difficulty = 10
                  if difficulty >= Rand.rnd(params.chara:skill_level("elona.fishing") + 1) then
                     self.state = 0
                  else
                     self.state = 4
                  end
               end
               if self.state == 4 then
                  Gui.play_sound("base.fish_get")
                  Gui.mes("fishwait5")
                  Gui.play_sound(Rand.choice({"base.get1", "base.get2"}))
                  Skill.gain_skill_exp(params.chara, "elona.fishing", 100)
                  return { action = "stop" }
               end
               if Rand.one_in(10) then
                  params.chara:damage_sp(1)
               end

               return { turn_result = "turn_end" }
            end
         },
         {
            id = "base.on_activity_finish",
            name = "finish",

            callback = function(self, params)
               Gui.mes("fishing failed")
            end
         }
      }
   }
}

data:add_multi("base.activity", activity)
