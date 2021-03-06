local Const = require("api.Const")
local Item = require("api.Item")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local Event = require("api.Event")
local Weather = require("mod.elona.api.Weather")
local Rand = require("api.Rand")
local Magic = require("mod.elona_sys.api.Magic")
local Hunger = require("mod.elona.api.Hunger")

local function proc_auto_eat_cargo_food(chara)
   -- >>>>>>>> shade2/proc.hsp:795 	if cHunger(pc)<=hungerNormal{ ...
   if chara.nutrition <= Const.HUNGER_THRESHOLD_NORMAL then
      local is_cargo_food = function(item)
         return Item.is_alive(item)
            and item:has_category("elona.cargo_food")
      end

      local cargo_food = chara:iter_inventory():filter(is_cargo_food):nth(1)
      if cargo_food then
         Gui.mes_visible("activity.eat.finish", chara, cargo_food:build_name(1))
         Hunger.eat_food(chara, cargo_food)
      end
   end
   -- <<<<<<<< shade2/proc.hsp:806 	} ..
end
Event.register("elona.on_chara_travel_in_world_map", "Proc auto eat cargo food", proc_auto_eat_cargo_food, { priority = 80000 })

local function proc_weather_travel_effects(chara, params)
   local weather = Weather.get()
   if weather.on_travel then
      local activity = params.activity
      activity.turns = weather.on_travel(chara, activity.turns) or activity.turns
   end
end
Event.register("elona.on_chara_travel_in_world_map", "Proc weather travel effects", proc_weather_travel_effects, { priority = 90000 })

local function proc_weather_changing(chara, params)
   Weather.pass_turn()
end
Event.register("base.on_hour_passed", "Proc weather changing", proc_weather_changing, 70000)

local function proc_weather_from_world_map_pos(map)
   Weather.change_from_world_map()
   Weather.play_ambient_sound(map)
end
Event.register("base.on_map_enter", "Proc weather based on world map position when the map changes", proc_weather_from_world_map_pos)

local function proc_weather_on_turn_start(chara, params, result)
   local weather = Weather.get()
   if weather.on_turn_start then
      weather.on_turn_start(chara)
   end
end

Event.register("base.before_chara_turn_start", "Proc weather on_turn_start", proc_weather_on_turn_start)

local function proc_etherwind(chara, params)
   -- >>>>>>>> shade2/main.hsp:736 		if gWeather=weatherEther{ ...
   if Weather.is("elona.etherwind") and chara:is_player() then
      local map = chara:current_map()
      if not map:calc("is_indoor") then
         if Rand.one_in(2) then
            if not chara:calc("is_protected_from_etherwind") then
               Effect.modify_corruption(chara, 5 + math.clamp(save.base.play_turns / 20000, 0, 15))
            else
               if Rand.one_in(10) then
                  Effect.modify_corruption(chara, 5)
               end
            end
         end

         if not chara:calc("is_protected_from_etherwind") or Rand.one_in(4) then
            if Rand.one_in(2000) then
               Magic.cast("elona.mutation", { source = chara, target = chara, power = 100 })
            end
         end
      else
         local archetype = map._archetype
         if Rand.one_in(1500) and not (archetype == "elona.your_home" or archetype == "elona.shelter") then
            Effect.modify_corruption(chara, 10)
         end
      end
   end
   -- <<<<<<<< shade2/main.hsp:744 		} ..
end
Event.register("base.before_chara_turn_start", "Proc etherwind effects", proc_etherwind, { priority = 60000 })

local function modify_map_shadow_from_weather(map, _, shadow)
   local weather = Weather.get()
   local weather_shadow = weather.outdoor_shadow

   if type(weather_shadow) == "table" then
      shadow[1] = weather_shadow[1]
      shadow[2] = weather_shadow[2]
      shadow[3] = weather_shadow[3]
      shadow[4] = weather_shadow[4]
   elseif type(weather_shadow) == "function" then
      shadow = weather_shadow(shadow) or shadow
      assert(type(shadow) == "table")
   elseif weather_shadow ~= nil then
      error("Invalid weather shadow " .. tostring(weather_shadow))
   end

   return shadow
end
Event.register("base.on_map_calc_shadow", "Modify map shadow from weather", modify_map_shadow_from_weather)
