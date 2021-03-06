local Map = require("api.Map")
local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Gui = require("api.Gui")
local World = require("api.World")
local Const = require("api.Const")
local ExHelp = require("mod.elona.api.ExHelp")
local Chara = require("api.Chara")
local Event = require("api.Event")
local global = require("mod.elona.internal.global")
local RandomEvent = require("mod.elona.api.RandomEvent")

local function hourly_events()
   -- >>>>>>>> shade2/main.hsp:627 	if mType=mTypeWorld{ ...
   local s = save.elona_sys
   local map = Map.current()

   -- TODO adventurer

   Effect.spoil_items(map)

   if Map.is_world_map(map) then
      if Rand.one_in(3) then
         s.awake_hours = s.awake_hours + 1
      end
      if Rand.one_in(15) then
         Gui.mes("action.move.global.nap")
         s.awake_hours = math.max(0, s.awake_hours - 3)
      end
   else
      if not map:calc("prevents_adding_awake_hours") then
         s.awake_hours = s.awake_hours + 1
      end
   end

   if World.date().hour == 8 then
      Gui.mes_c("action.new_day", "Yellow")
   end

   if s.awake_hours >= Const.SLEEP_THRESHOLD_LIGHT then
      ExHelp.maybe_show(9)
   end
   if Chara.player().nutrition < Const.HUNGER_THRESHOLD_NORMAL then
      ExHelp.maybe_show(10)
   end
   -- <<<<<<<< shade2/main.hsp:636 	if cHunger(pc)<hungerNormal	: help 10 ..
end

Event.register("base.on_hour_passed", "Update awake hours, rot food", hourly_events, { priority = 90000 })

local function hourly_events_2()
   if not global.is_player_sleeping then
      -- TODO god
      local map = Map.current()
      if not map:has_type("world_map") then
         if Rand.one_in(40) then
         end
      else
         if Rand.one_in(40) then
         end
      end
   end

   -- TODO shelter
   -- TODO jail
   RandomEvent.trigger_randomly()
end
Event.register("base.on_hour_passed", "Update piety, proc random events", hourly_events_2, { priority = 100000 })
