local CodeGenerator = require("api.CodeGenerator")
local Map = require("api.Map")
local Draw = require("api.Draw")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local Chara = require("api.Chara")
local Weather = require("mod.elona.api.Weather")
local Enum = require("api.Enum")
local ExHelp = require("mod.elona.api.ExHelp")
local Event = require("api.Event")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Const = require("api.Const")
local Effect = require("mod.elona.api.Effect")
local UiTheme = require("api.gui.UiTheme")
local Hunger = require("mod.elona.api.Hunger")

data:add_type {
   name = "weather",
   fields = {
      {
         name = "elona_id",
         indexed = true,
         type = types.optional(types.uint)
      },
      {
         name = "travel_speed_modifier",
         type = types.callback({"turns", types.number}, types.number),
         template = true
      },
      {
         name = "on_travel",
         type = types.callback({"chara", types.map_object("base.chara"), "turns", types.number}, types.number),
         template = true
      },
      {
         name = "on_weather_change",
         type = types.callback({}, types.data_id("elona.weather")),
         template = true
      },
      {
         name = "draw_callback",
         type = types.callback(),
         template = true
      },
      {
         name = "outdoor_shadow",
         type = types.optional(types.callback({"shadow", types.color}, types.color)),
         template = true
      },
      {
         name = "on_turn_start",
         type = types.callback("chara", types.map_object("base.chara")),
         template = true
      },
      {
         name = "is_bad_weather",
         type = types.boolean,
         template = true,
         default = false
      },
      {
         name = "ambient_sound",
         type = types.optional(types.data_id("base.sound")),
      },
   }
}

do
   local sunny = {
      _type = "elona.weather",
      _id = "sunny",
      elona_id = 0,
   }

   function sunny.on_weather_change()
      -- >>>>>>>> shade2/main.hsp:589 		if p=weatherSunny{ ...
      local player = Chara.player()
      if player and player:has_trait("elona.ether_rain") and Rand.one_in(4) then
         Gui.mes("action.weather.rain.draw_cloud")
         return "elona.rain"
      end

      local x, y = Weather.position_in_world_map()
      if x and y then
         if x > 65 and y < 10 then
            if Rand.one_in(2) then
               Gui.mes("action.weather.snow.starts")
               return "elona.snow"
            end
         else
            if Rand.one_in(10) then
               Gui.mes("action.weather.rain.starts")
               return "elona.rain"
            end
            if Rand.one_in(40) then
               Gui.mes("action.weather.rain.starts_heavy")
               return "elona.hard_rain"
            end
            if Rand.one_in(60) then
               Gui.mes("action.weather.snow.starts")
               return "elona.snow"
            end
         end
      end

      return nil
      -- <<<<<<<< shade2/main.hsp:599 			} ..
   end

   data:add(sunny)
end

do
   local etherwind = {
      _type = "elona.weather",
      _id = "etherwind",
      elona_id = 1,

      -- >>>>>>>> shade2/map.hsp:3353 		if (gWeather=weatherSnow)or(gWeather=weatherHard ...
      is_bad_weather = true,
      -- <<<<<<<< shade2/map.hsp:3353 		if (gWeather=weatherSnow)or(gWeather=weatherHard ...

      -- >>>>>>>> shade2/sound.hsp:379 	if gWeather=weatherEther	:env=seBgWind ...
      ambient_sound = "base.bg_wind",
      -- <<<<<<<< shade2/sound.hsp:379 	if gWeather=weatherEther	:env=seBgWind ..

      on_travel = nil,
   }

   function etherwind.on_weather_change()
      -- >>>>>>>> shade2/main.hsp:607 		if p=weatherEther{ ...
      if Rand.one_in(2) then
         Gui.mes("action.weather.ether_wind.stops")
         return "elona.sunny"
      end

      return nil
      -- <<<<<<<< shade2/main.hsp:609 			} ..
   end

   function etherwind.travel_speed_modifier(turns)
      -- >>>>>>>> shade2/proc.hsp:790 		if gWeather=weatherEther	:cActionPeriod(cc)=cAct ...
      return turns * 5 / 10
      -- <<<<<<<< shade2/proc.hsp:790 		if gWeather=weatherEther	:cActionPeriod(cc)=cAct ..
   end

   function etherwind.draw_callback()
      -- >>>>>>>> shade2/screen.hsp:1206 *screen_ether ...
      local t = UiTheme.load()

      local rain_x = {}
      local rain_y = {}
      local frames_passed = 1
      local prev_weather = nil

      while true do
         local map = Map.current()
         if not map:calc("is_indoor") then
            local width = Draw.get_width()
            local height = Draw.get_height()
            local max_rain = width * height / 3500

            for _ = 1, frames_passed do
               Draw.set_color(0, 0, 0)
               for i = 1, max_rain do

                  if rain_y[i] == nil or rain_y[i] <= 0 or prev_weather ~= save.elona.weather_id then
                     rain_y[i] = Draw.get_height() - (Gui.message_window_y() - 16) - 8 - Rand.rnd(100)
                     rain_x[i] = Rand.rnd(Draw.get_width())
                  else
                     rain_x[i] = rain_x[i] + Rand.rnd(3) - 1
                     rain_y[i] = rain_y[i] - Rand.rnd(2) + (i-1) % 5
                  end
               end
            end

            Draw.set_color(0, 0, 0)

            for i = 1, max_rain do
               local x = rain_x[i]
               local y = rain_y[i]

               if not (x and y) then
                  break
               end

               if (i-1) % 20 == 0 then
                  Draw.set_color(255, 255, 255, 100 + (i-1) % 150)
               end

               local idx = (rain_x[i]%2) + 2 + ((i-1)%6) * 4 + 1
               t.base.weather_snow_etherwind:draw_region(idx, rain_x[i], rain_y[i])
            end
         end

         prev_weather = save.elona.weather_id
         frames_passed = select(3, Draw.yield(config.base.background_effect_wait))
      end
      -- <<<<<<<< shade2/screen.hsp:1222 	return ..
   end

   data:add(etherwind)
end

do
   local snow = {
      _type = "elona.weather",
      _id = "snow",
      elona_id = 2,

      -- >>>>>>>> shade2/map.hsp:3353 		if (gWeather=weatherSnow)or(gWeather=weatherHard ...
      is_bad_weather = true,
      -- <<<<<<<< shade2/map.hsp:3353 		if (gWeather=weatherSnow)or(gWeather=weatherHard ...

      on_travel = nil,
      draw_callback = nil,
   }

   function snow.on_weather_change()
      -- >>>>>>>> shade2/main.hsp:610 		if p=weatherSnow{ ...
      if Rand.one_in(3) then
         Gui.mes("action.weather.snow.stops")
         return "elona.sunny"
      end

      return nil
      -- <<<<<<<< shade2/main.hsp:612 			} ..
   end

   function snow.travel_speed_modifier(turns, chara)
      -- >>>>>>>> shade2/proc.hsp:789 		if (gWeather=weatherSnow)or(tRole(map(cx(cc),cy( ...
      local map = chara:current_map()
      if map then
         local tile = map:tile(chara.x, chara.y)
         if tile.kind == Enum.TileRole.Snow then
            -- Don't apply the travel speed modifier twice. The vanilla code is:
            --
            -- if (gWeather=weatherSnow)or(tRole(map(cx(cc),cy(cc),0))=tSnow) : cActionPeriod(cc)=cActionPeriod(cc)*22/10
            --
            -- But we do the latter check already, inside the base.activity
            -- "elona.traveling."
            return turns
         end
      end

      return turns * 22 / 10
      -- <<<<<<<< shade2/proc.hsp:789 		if (gWeather=weatherSnow)or(tRole(map(cx(cc),cy( ..
   end

   function snow.on_travel(chara, turns)
      -- >>>>>>>> shade2/proc.hsp:808 	if (gWeather=weatherSnow)or(tRole(map(cx(cc),cy(c ...
      if chara:calc("is_protected_from_weather") then
         return
      end

      if Rand.one_in(100) and not SkillCheck.is_floating(chara) then
         Gui.mes_c("action.move.global.weather.snow.sound", "SkyBlue")
         turns = turns + 10
      end

      if Rand.one_in(1000) then
         Gui.mes_c("action.move.global.weather.snow.message", "Purple")
         turns = turns + 50
      end

      if chara.nutrition <= Const.HUNGER_THRESHOLD_HUNGRY and not chara:calc("is_anorexic") then
         Gui.play_sound("base.eat1", chara.x, chara.y)
         Gui.mes("action.move.global.weather.snow.eat")
         chara.nutrition = chara.nutrition + 5000
         Hunger.show_eating_message(chara)
         chara:apply_effect("elona.dimming", 1000)
      end

      return turns
      -- <<<<<<<< shade2/proc.hsp:824 		} ..
   end

   function snow.draw_callback()
      -- >>>>>>>> shade2/screen.hsp:1187 *screen_snow ...
      local t = UiTheme.load()

      local rain_x = {}
      local rain_y = {}
      local frames_passed = 1
      local prev_weather = nil

      while true do
         local map = Map.current()
         if not map:calc("is_indoor") then
            local width = Draw.get_width()
            local height = Draw.get_height()
            local max_rain = width * height / 3500 * 2

            for _ = 1, frames_passed do
               for i = 1, max_rain do
                  if rain_y[i] == nil or rain_y[i] == 0 or prev_weather ~= save.elona.weather_id then
                     rain_y[i] = Rand.rnd(Draw.get_height()/2) * -1
                     rain_x[i] = Rand.rnd(Draw.get_width())
                  else
                     rain_x[i] = rain_x[i] + Rand.rnd(3) - 1
                     rain_y[i] = rain_y[i] + Rand.rnd(2) + (i-1) % 5
                     if rain_y[i] > Draw.get_width() - (Gui.message_window_y() - 16) - 10
                        or Rand.one_in(500)
                     then
                        rain_y[i] = 0
                        rain_x[i] = 0
                     end
                  end
               end
            end

            Draw.set_color(0, 0, 0)

            for i = 1, max_rain do
               if (i-1) % 30 == 0 then
                  Draw.set_color(255, 255, 255, 100 + (i-1) % 150)
               end

               local idx = (rain_x[i]%2) + ((i-1)%6) * 4 + 1
               t.base.weather_snow_etherwind:draw_region(idx, rain_x[i], rain_y[i])
            end
         end

         prev_weather = save.elona.weather_id
         frames_passed = select(3, Draw.yield(config.base.background_effect_wait))
      end
      -- <<<<<<<< shade2/screen.hsp:1204 	return ..
   end

   data:add(snow)
end

-- >>>>>>>> shade2/screen.hsp:1165 *screen_rain ...
local function mkrain(mod_y, length_y, speed_x, speed_y)
   return function()
      local rain_x = {}
      local rain_y = {}
      local colors = {}
      local frames_passed = 1

      while true do
         local map = Map.current()
         if not map:calc("is_indoor") then
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
                     y = Rand.rnd(Gui.message_window_y() - 16) - 6
                  end

                  x = x + speed_x
                  y = y + speed_y + (i % 8)
                  if y > (Gui.message_window_y() - 16) - 6 then
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

         frames_passed = select(3, Draw.yield(config.base.background_effect_wait))
      end
   end
end
-- <<<<<<<< shade2/screen.hsp:1185 	return ..

do
   local rain = {
      _type = "elona.weather",      _id = "rain",
      elona_id = 3,

      -- >>>>>>>> shade2/sound.hsp:377 	if gWeather=weatherRain		:env=seBgRain ...
      ambient_sound = "base.bg_rain",
      -- <<<<<<<< shade2/sound.hsp:377 	if gWeather=weatherRain		:env=seBgRain ..

      travel_speed_modifier = nil,
      on_travel = nil,

      -- >>>>>>>> shade2/screen.hsp:1154 		if gWeather=weatherRain		:gosub *screen_rain ...
      draw_callback = mkrain(3, 1, 2, 16),
      -- <<<<<<<< shade2/screen.hsp:1154 		if gWeather=weatherRain		:gosub *screen_rain ..
   }

   function rain.outdoor_shadow(shadow)
      -- >>>>>>>> shade2/map.hsp:2298 		if gWeather=weatherRain:if p<40:p=40,40,40 ...
      if shadow[1] < 40 then
         shadow[1] = 40
         shadow[2] = 40
         shadow[3] = 40
      end
      return shadow
      -- <<<<<<<< shade2/map.hsp:2298 		if gWeather=weatherRain:if p<40:p=40,40,40 ..
   end

   function rain.on_weather_change()
      -- >>>>>>>> shade2/main.hsp:600 		if p=weatherRain{ ...
      if Rand.one_in(4) then
         Gui.mes("action.weather.rain.stops")
         return "elona.sunny"
      end
      if Rand.one_in(15) then
         Gui.mes("action.weather.rain.becomes_heavier")
         return "elona.hard_rain"
      end

      return nil
      -- <<<<<<<< shade2/main.hsp:603 			} ...   end,
   end

   function rain.travel_speed_modifier(turns)
      -- >>>>>>>> shade2/proc.hsp:788 		if gWeather=weatherHardRain	:cActionPeriod(cc)=c ...
      return turns * 13 / 10
      -- <<<<<<<< shade2/proc.hsp:788 		if gWeather=weatherHardRain	:cActionPeriod(cc)=c ..
   end

   function rain.on_turn_start(chara)
      -- >>>>>>>> shade2/main.hsp:867 	if mField=mFieldOutdoor : if gWeather>=weatherRai ...
      local map = chara:current_map()
      if not map:calc("is_indoor") then
         chara:set_effect_turns("elona.wet", 50)
      end
      -- <<<<<<<< shade2/main.hsp:867 	if mField=mFieldOutdoor : if gWeather>=weatherRai ..
   end

   data:add(rain)
end

do
   local hard_rain = {
      _type = "elona.weather",
      _id = "hard_rain",
      elona_id = 4,

      -- >>>>>>>> shade2/sound.hsp:378 	if gWeather=weatherHardRain	:env=seBgThunder ...
      ambient_sound = "base.bg_thunder",
      -- <<<<<<<< shade2/sound.hsp:378 	if gWeather=weatherHardRain	:env=seBgThunder ..

      -- >>>>>>>> shade2/map.hsp:3353 		if (gWeather=weatherSnow)or(gWeather=weatherHard ...
      is_bad_weather = true,
      -- <<<<<<<< shade2/map.hsp:3353 		if (gWeather=weatherSnow)or(gWeather=weatherHard ...

      on_travel = nil,

      -- >>>>>>>> shade2/screen.hsp:1155 		if gWeather=weatherHardRain	:gosub *screen_hardR ...
      draw_callback = mkrain(5, 4, 1, 24)
      -- <<<<<<<< shade2/screen.hsp:1155 		if gWeather=weatherHardRain	:gosub *screen_hardR ..
   }

   function hard_rain.outdoor_shadow(shadow)
      -- >>>>>>>> shade2/map.hsp:2299 		if gWeather=weatherHardRain:if p<65:p=65,65,65 ...
      if shadow[1] < 65 then
         shadow[1] = 65
         shadow[2] = 65
         shadow[3] = 65
      end
      return shadow
      -- <<<<<<<< shade2/map.hsp:2299 		if gWeather=weatherHardRain:if p<65:p=65,65,65 ...
   end

   function hard_rain.on_weather_change()
      -- >>>>>>>> shade2/main.hsp:604 		if p=weatherHardRain{ ...
      if Rand.one_in(3) then
         Gui.mes("action.weather.rain.becomes_lighter")
         return "elona.rain"
      end

      return nil
      -- <<<<<<<< shade2/main.hsp:606 			} ..
   end

   function hard_rain.travel_speed_modifier(turns)
      -- >>>>>>>> shade2/proc.hsp:788 		if gWeather=weatherHardRain	:cActionPeriod(cc)=c ...
      return turns * 16 / 10
      -- <<<<<<<< shade2/proc.hsp:788 		if gWeather=weatherHardRain	:cActionPeriod(cc)=c ..
   end

   function hard_rain.on_travel(chara, turns)
      -- >>>>>>>> shade2/proc.hsp:826 	if gWeather=weatherHardRain{ ...
      if chara:calc("is_protected_from_weather") then
         return
      end

      if Rand.one_in(100) and not SkillCheck.is_floating(chara) then
         Gui.mes_c("action.move.global.weather.heavy_rain.sound", "SkyBlue")
         turns = turns + 5
      end

      if not chara:has_effect("elona.confusion") then
         if Rand.one_in(500) then
            Gui.mes_c("action.move.global.weather.heavy_rain.message", "Purple")
            chara:set_effect_turns("elona.confusion", 10)
         end
      else
         if Rand.one_in(5) then
            chara:set_effect_turns("elona.confusion", 10)
         end
      end

      chara:set_effect_turns("elona.blindness", 3)

      return turns
      -- <<<<<<<< shade2/proc.hsp:846 		} ..
   end

   function hard_rain.on_turn_start(chara)
      -- >>>>>>>> shade2/main.hsp:867 	if mField=mFieldOutdoor : if gWeather>=weatherRai ...
      local map = chara:current_map()
      if not map:calc("is_indoor") then
         chara:set_effect_turns("elona.wet", 50)
      end
      -- <<<<<<<< shade2/main.hsp:867 	if mField=mFieldOutdoor : if gWeather>=weatherRai ..
   end

   data:add(hard_rain)
end

local function show_weather_ex_help(_, params)
   -- >>>>>>>> shade2/main.hsp:615 		if gWeather=weatherHardRain	:help 11 ...
   local id = params.new_weather_id
   if id == "elona.hard_rain" then
      ExHelp.show("elona.bad_weather")
   elseif id == "elona.snow" then
      ExHelp.show("elona.snow")
   elseif id == "elona.etherwind" then
      ExHelp.show("elona.etherwind")
   end
   -- <<<<<<<< shade2/main.hsp:617 		if gWeather=weatherEther	:help 13 ..
end
Event.register("elona.on_weather_changed", "Show ex help for dangerous weather", show_weather_ex_help)
