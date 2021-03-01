local Draw = require("api.Draw")
local Gui = require("api.Gui")

data:add {
   _type = "base.auto_turn_anim",
   _id = "mining",

   callback = function(x, y, t)
      return function()
         local frame = 0
         local played_sound = false
         while frame < 10 do
            if frame >= 2 and played_sound == false then
               Gui.play_sound("base.dig1")
               played_sound = true
            end

            t.base.auto_turn_mining:draw_region(math.floor(frame/2)%5+1, x, y)
            local frames_passed = select(3, Draw.yield(40))
            frame = frame + frames_passed
         end
      end
   end,
   draw = function(x, y, t)
      t.base.auto_turn_mining:draw_region(1, x, y)
   end
}

data:add {
   _type = "base.auto_turn_anim",
   _id = "fishing",

   on_start_callback = function()
      Gui.play_sound("base.water")
   end,
   callback = function(x, y, t)
      return function()
         local frame = 0
         while frame < 10 do
            t.base.auto_turn_fishing:draw_region(math.floor(frame/3)%3+1, x, y)
            local frames_passed = select(3, Draw.yield(50))
            frame = frame + frames_passed
         end
      end
   end,
   draw = function(x, y, t)
      t.base.auto_turn_fishing:draw_region(1, x, y)
   end
}

data:add {
   _type = "base.auto_turn_anim",
   _id = "harvesting",

   callback = function(x, y, t)
      return function()
         local frame = 0
         local played_sound = false
         while frame < 10 do
            if frame >= 3 and played_sound == false then
               Gui.play_sound("base.bush1")
               played_sound = true
            end
            t.base.auto_turn_harvesting:draw_region(math.floor(frame/2)%3+1, x, y)
            local frames_passed = select(3, Draw.yield(55))
            frame = frame + frames_passed
         end
      end
   end,
   draw = function(x, y, t)
      t.base.auto_turn_harvesting:draw_region(1, x, y)
   end
}

data:add {
   _type = "base.auto_turn_anim",
   _id = "searching",

   callback = function(x, y, t)
      return function()
         local frame = 0
         local played_sound = false
         while frame < 10 do
            if frame >= 2 then
               Gui.play_sound("base.dig2")
               played_sound = true
            end
            t.base.auto_turn_searching:draw_region(math.floor(frame/2)%4+1, x, y)
            local frames_passed = select(3, Draw.yield(60))
            frame = frame + frames_passed
         end
      end
   end,
   draw = function(x, y, t)
      t.base.auto_turn_searching:draw_region(1, x, y)
   end
}
