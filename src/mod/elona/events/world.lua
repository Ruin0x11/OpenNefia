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
local Rank = require("mod.elona.api.Rank")
local Home = require("mod.elona.api.Home")
local Adventurer = require("mod.elona.api.Adventurer")

local function hourly_events()
   -- >>>>>>>> shade2/main.hsp:627 	if mType=mTypeWorld{ ...
   local s = save.elona_sys
   local map = Map.current()

   if map then
      Adventurer.update_all(map)
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
   end

   if World.date().hour == 8 then
      Gui.mes_c("action.new_day", "Yellow")
   end

   if s.awake_hours >= Const.SLEEP_THRESHOLD_LIGHT then
      ExHelp.show("elona.sleep")
   end

   local player = Chara.player()
   if player and player.nutrition < Const.HUNGER_THRESHOLD_NORMAL then
      ExHelp.show("elona.hunger")
   end
   -- <<<<<<<< shade2/main.hsp:636 	if cHunger(pc)<hungerNormal	: help 10 ..
end

Event.register("base.on_hour_passed", "Update awake hours, rot food", hourly_events, { priority = 90000 })

local function adjust_prayer_charge_and_piety(player)
   local map = player:current_map()
   if map then
      if not map:has_type("world_map") then
         if Rand.one_in(40) then
            player.piety = player.piety - 1
            player.prayer_charge = player.prayer_charge + 4
         end
      else
         if Rand.one_in(5) then
            player.piety = player.piety - 1
            player.prayer_charge = player.prayer_charge + 32
         end
      end
   end
   player.piety = math.max(player.piety, 0)
end

local function hourly_events_2()
   if not global.is_player_sleeping then
      local player = Chara.player()
      if Chara.is_alive(player) then
         adjust_prayer_charge_and_piety(player)
      end
   end

   -- TODO shelter
   -- TODO jail
   RandomEvent.trigger_randomly()
end
Event.register("base.on_hour_passed", "Update piety, proc random events", hourly_events_2, { priority = 100000 })

local function update_rank_decays(_, params)
   local days_passed = params.days

   -- >>>>>>>> shade2/main.hsp:642 		repeat tailRank ...
   for _, rank_proto, rank in Rank.iter() do
      local next_days = Rank.get_decay_period_days(rank_proto._id)
      if next_days then
         rank.days_until_decay = rank.days_until_decay - days_passed
         if rank.days_until_decay < 0 then
            Rank.modify(rank_proto._id, -(rank.place / 12 + 100))
            rank.days_until_decay = next_days
         end
      end
   end
   -- <<<<<<<< shade2/main.hsp:651 		loop ..
end
Event.register("base.on_day_passed", "Update rank decays", update_rank_decays, 100000)

local function create_income(_, params)
   -- >>>>>>>> shade2/main.hsp:660 		if (gDay=1)or(gDay=15)	:gosub *event_income ...
   local day = save.base.date.day

   -- NOTE: Because of the way events are fired when time passes, this will only
   -- get triggered if the day isn't skipped over in a single call to
   -- World.pass_time_in_seconds(). For example, if the current day is the 31st
   -- and you pass three days' worth of time, then you won't receive a bill or
   -- salary for the 1st day. (This is also vanilla's behavior.)
   --
   -- To change this we'd add a new :pass_time() method to DateTime and somehow
   -- allow stepping through each day from the previous time point to the
   -- current one.
   if not (day == 1 or day == 15) then
      return
   end

   local player = Chara.player()

   Home.add_salary_to_salary_chest()

   if day == 1 then
      local receives_bill = player.level > 5
      if receives_bill then
         Home.add_monthly_bill_to_salary_chest_and_update()
      else
         Gui.mes("misc.tax.no_duty")
      end
   end

   ExHelp.show("elona.salary")
   -- <<<<<<<< shade2/main.hsp:660 		if (gDay=1)or(gDay=15)	:gosub *event_income ..
end
Event.register("base.on_day_passed", "create_income", create_income, 200000)

local function update_holy_well_count(_, params)
   -- >>>>>>>> shade2/main.hsp:658 		if gDay>=31		:gMonth++:gDay=gDay-30:if gMonth¥2= ...
   if save.base.date.month % 2 == 0 then
      save.elona.holy_well_count = save.elona.holy_well_count + 1
   end
   -- <<<<<<<< shade2/main.hsp:658 		if gDay>=31		:gMonth++:gDay=gDay-30:if gMonth¥2= ..
end
Event.register("base.on_month_passed", "Update holy well count", update_holy_well_count, 100000)

local function update_well_wish_count_trainer_wallet(_, params)
   -- >>>>>>>> shade2/main.hsp:659 		if gMonth>=13		:gYear++:gMonth=1:gGuildTrainer=0 ...
   save.elona.next_guest_trainer_date = 0
   save.elona.well_wish_count = math.clamp(save.elona.well_wish_count - 1, 0, 10)
   save.elona.lost_wallets_reported = math.clamp(save.elona.lost_wallets_reported - 1, 0, 999999)
   -- <<<<<<<< shade2/main.hsp:659 		if gMonth>=13		:gYear++:gMonth=1:gGuildTrainer=0 ..
end
Event.register("base.on_year_passed", "Update well wish count, etc.", update_well_wish_count_trainer_wallet, 100000)
