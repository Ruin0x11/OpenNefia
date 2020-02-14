local Draw = require("api.Draw")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Rand = require("api.Rand")

local Weather = {}

local INF_VERH = 16 + 72

local function mkrain(mod_y, length_y, speed_x, speed_y)
   return function()
      local rain_x = {}
      local rain_y = {}
      local colors = {}
      local frames_passed = 1

      while true do
         local map = Map.current()
         if not map.is_indoor then
            local width = Draw.get_width()
            local height = Draw.get_height()
            local max_rain = width * height / 3500

            local factor = 1
            if map:has_type("world_map") then
               factor = 2
            end

            for _ = 1, frames_passed do
               for i = 1, max_rain*factor do
                  local color = colors[i] or {}

                  local color_delta = Rand.rnd(100)
                  color[1] = 170 - color_delta
                  color[2] = 200 - color_delta
                  color[3] = 250 - color_delta

                  colors[i] = color

                  local x = rain_x[i]
                  local y = rain_y[i]
                  if x == nil or x <= 0 then
                     x = Rand.rnd(width) + 40
                  end
                  if y == nil or y <= 0 then
                     y = Rand.rnd(height - INF_VERH) - 6
                  end

                  x = x + speed_x
                  y = y + speed_y + (i % 8)
                  if y > height - INF_VERH - 6 then
                     x = 0
                     y = 0
                  end

                  rain_x[i] = x
                  rain_y[i] = y
               end
            end

            for i = 1, max_rain*factor do
               local x = rain_x[i]
               local y = rain_y[i]
               local color = colors[i]

               if not (x and y and color) then
                  break
               end

               Draw.line(x - 40, y - (i % mod_y) - length_y, x - 39 + (i % 2), y, color)
            end
         end

         frames_passed = select(3, Draw.yield(config["base.anim_wait"]))
      end
   end
end

local rain = {
   callback = mkrain(3, 1, 2, 16),
}

local hard_rain = {
   callback = mkrain(5, 4, 1, 24)
}

function Weather.start_rain()
   Gui.start_draw_callback(rain.callback, true, "elona.weather")
end

function Weather.start_hard_rain()
   Gui.start_draw_callback(hard_rain.callback, true, "elona.weather")
end

function Weather.stop()
   Gui.stop_draw_callback("elona.weather")
end

return Weather
