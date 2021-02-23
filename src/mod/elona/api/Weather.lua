local Weather = {}
local Map = require("api.Map")
local Chara = require("api.Chara")
local Area = require("api.Area")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local World = require("api.World")
local Event = require("api.Event")

function Weather.get()
   return data["elona.weather"]:ensure(save.elona.weather_id)
end

function Weather.is(weather_id)
   data["elona.weather"]:ensure(weather_id)
   local weather = Weather.get()
   return weather._id == weather_id
end

function Weather.change_to(weather_id, next_turns)
   local weather = data["elona.weather"]:ensure(weather_id)
   local prev_weather_id = save.elona.weather_id

   if weather._id ~= prev_weather_id then
      Gui.stop_background_sound("elona.weather")
      Gui.stop_draw_callback("elona.weather")

      save.elona.weather_id = weather._id

      if weather.ambient_sound then
         Gui.play_background_sound(weather.ambient_sound, "elona.weather")
      end

      if weather.draw_callback and config.base.weather_effect then
         Gui.start_background_draw_callback(weather.draw_callback, "elona.weather")
      end

      Event.trigger("elona.on_weather_changed", {previous_weather_id=prev_weather_id,new_weather_id=weather._id})
   end

   if next_turns then
      save.elona.turns_until_weather_changes = math.max(next_turns, 0)
   end
end

function Weather.position_in_world_map()
   -- TODO support for more world maps, less hardcoding. this is just for
   -- compat, for now.
   local player = Chara.player()
   local map = Map.current()
   if not map then
      return nil, nil
   end

   local x, y
   if map._archetype == "elona.north_tyris" then
      x, y = player.x, player.y
   else
      -- Check if we're inside a map where the parent map is North Tyris, so we
      -- can do things like check if our position in North Tyris is to the
      -- northeast (snowy).
      --
      -- Hackish, but works.
      local prev_uid, prev_x, prev_y = map:previous_map_and_location()
      if prev_uid == nil then
         return nil, nil
      end
      local area = Area.get_unique("elona.north_tyris")
      if area == nil then
         return nil, nil
      end
      local ok, toplevel_floor = area:get_floor(area:starting_floor())
      if not ok then
         return nil, nil
      end
      if toplevel_floor.uid ~= prev_uid then
         return nil, nil
      end
      x, y = prev_x, prev_y
   end

   return x, y
end

function Weather.change_from_world_map()
   -- >>>>>>>> shade2/main.hsp:564 *weather_change ...
   local x, y = Weather.position_in_world_map()
   if x == nil then
      return
   end

   local w = Weather.get()

   -- TODO hardcoded to North Tyris
   if w._id == "elona.snow" then
      if x < 65 and y > 10 then
         Weather.change_to("elona.rain")
         Weather.extend_duration(3)
         Gui.mes("action.weather.changes")
      end
   elseif w._id == "elona.hard_rain" or w._id == "elona.rain" then
      if x > 65 or y < 10 then
         Weather.change_to("elona.snow")
         Weather.extend_duration(3)
         Gui.mes("action.weather.changes")
      end
   end
   -- <<<<<<<< shade2/main.hsp:567 	return ..
end

function Weather.random_weather_id_and_turns()
   -- >>>>>>>> shade2/main.hsp:582 		if gMonth¥3=0{ ...
   local date = World.date()
   if date.month % 3 == 0 then
      if date.day >= 1 and date.day <= 10 and save.elona.date_of_last_etherwind.month ~= date.month then
         if Rand.rnd(15) < date.day + 5 then
            save.elona.date_of_last_etherwind = table.deepcopy(date)
            Gui.mes_c("action.weather.ether_wind.starts", "Red")
            return "elona.etherwind", Rand.rnd(24) + 24
         end
      end
   end

   local prev_weather = Weather.get()

   local id = prev_weather._id
   local turns = Weather.calc_random_weather_duration()

   if prev_weather.on_weather_change then
      local id_, turns_ = prev_weather.on_weather_change()
      id = id_ or id
      turns = turns_ or turns
   end

   return id, turns
   -- <<<<<<<< shade2/main.hsp:612 			} ..
end

function Weather.change_randomly()
   local next_weather_id, next_weather_turns = Weather.random_weather_id_and_turns()
   Weather.change_to(next_weather_id, next_weather_turns)
end

function Weather.calc_random_weather_duration()
   return Rand.rnd(22) + 2
end

function Weather.pass_turn()
   save.elona.turns_until_weather_changes = save.elona.turns_until_weather_changes - 1
   Weather.change_from_world_map()

   -- >>>>>>>> shade2/main.hsp:576 	gNextWeather-- ...
   if save.elona.turns_until_weather_changes < 0 then
      Weather.change_randomly()
   end
   -- <<<<<<<< shade2/main.hsp:579 		gNextWeather=rnd(22)+2 ..
end

function Weather.is_raining()
   local w = Weather.get()
   return w._id == "elona.rain" or w._id == "elona.hard_rain"
end

function Weather.is_bad_weather()
   return Weather.get().is_bad_weather
end

return Weather
