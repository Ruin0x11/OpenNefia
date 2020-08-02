local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Map = require("api.Map")
local Event = require("api.Event")
local World = require("api.World")
local Skill = require("mod.elona_sys.api.Skill")
local Const = require("api.Const")
local Gui = require("api.Gui")
local Area = require("api.Area")
local Feat = require("api.Feat")
local IMapObject = require("api.IMapObject")
local Item = require("api.Item")
local Enum = require("api.Enum")
local Quest = require("mod.elona_sys.api.Quest")
local Role = require("mod.elona_sys.api.Role")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local ExHelp = require("mod.elona.api.ExHelp")
local save = require("internal.global.save")
local Log = require("api.Log")

local function relocate_chara(chara, map)
   local x, y
   for i=1, 1000 do
      if i <= 100 then
         x = chara.x + Rand.rnd(math.floor(i / 2) + 2) - Rand.rnd(math.floor(i / 2) + 2)
         y = chara.y + Rand.rnd(math.floor(i / 2) + 2) - Rand.rnd(math.floor(i / 2) + 2)
      else
         x = Rand.rnd(map:width())
         y = Rand.rnd(map:height())
      end

      if Map.can_access(x, y, map) then
         chara:set_pos(x, y)
         break
      end
   end
end

local function reset_chara_flags(map, load_type)
   -- >>>>>>>> shade2/map.hsp:1914 		repeat mHeight ..
   if load_type ~= "full" and load_type ~= "traveled" then
      return
   end

   for _, chara in Chara.iter_all(map) do
      if chara.state == "CitizenDead" and World.date_hours() >= chara.respawn_date then
         chara:revive()
      end

      if Chara.is_alive(chara) then
         if not chara:is_allied() then
            chara.hp = chara:calc("max_hp")
            chara.mp = chara:calc("max_mp")
            chara.insanity = 0

            if map:calc("has_anchored_npcs") then
               chara.initial_x = chara.x
               chara.initial_y = chara.y
            end

            if not chara.is_quest_target then
               chara:reset_ai()
            end

            if Role.has(chara, "elona.guard") then
               local player = Chara.player()
               if player:calc("karma") < Const.KARMA_BAD then
                  if player:calc("level") > chara:calc("level") then
                     Skill.gain_level(chara, false)
                  end
                  if not player:has_effect("elona.incognito") then
                     chara.ai_state.hate = 200
                     chara:mod_reaction_at(player, -1000)
                  end
               end
            end

            if map:has_type({"town", "guild"}) then
               chara:remove_effect("elona.sleep")
               local date = World.date()
               if date.hour >= 22 or date.hour < 7 then
                  if Rand.one_in(6) then
                     chara:set_effect_turns("elona.sleep", Rand.rnd(400))
                  end
               end
            end
         end
      end
   end
   -- <<<<<<<< shade2/map.hsp:1953 		loop ..
end

local function prepare_savable_map(map, load_type)
   local is_first_renewal = map.renew_major_date == 0

   -- >>>>>>>> shade2/map.hsp:1896 		if dateID>=mRenew:if mNoRenew=false:if mRenew!0: .
   if not map.is_not_renewable then
      if World.date_hours() > map.renew_major_date and not is_first_renewal then
         map:emit("base.on_map_renew_geometry")
      end
   end
   -- <<<<<<<< shade2/map.hsp:1913 		} ..

   reset_chara_flags(map, load_type)
end

local function renew_major(map)
   -- >>>>>>>> shade2/map.hsp:2180 		proc "renew_major" ..
   local is_first_renew = map.renew_major_date == 0

   if not is_first_renew then
      Feat.iter(map):filter(function(f) return f.is_temporary end)
                    :each(IMapObject.remove_ownership)

      for _, item in Item.iter(map) do
         item:emit("base.on_item_renew_major")
         if item.own_state == Enum.OwnState.None then
            item:remove()
         end
      end
   end

   for _, chara in Chara.iter_others(map) do
      chara:renew_status()
      if Chara.is_alive(chara) then
         if chara.is_summoned and Rand.one_in(2) then
            chara:remove_ownership()
         end
      end
   end

   -- TODO material spot
   map:emit("base.on_map_renew_major")
   -- <<<<<<<< shade2/map.hsp:2221 			} ..
end

local function renew_minor(map)
   map:emit("base.on_map_renew_minor")
end

local function check_renew(map)
   local area = Area.for_map(map)
   if area == nil then
      pause()
   end
   assert(area)
   local area_meta = area.metadata
   -- >>>>>>>> shade2/map.hsp:2173 *check_renew ..
   if area_meta.arena_seed_renew_date and World.date_hours() >= area_meta.arena_seed_renew_date then
      area_meta.arena_seed = Rand.rnd(10000)
      area_meta.arena_seed_renew_date = World.date_hours() + 24
   end

   if World.date_hours() > map.renew_major_date then
      renew_major(map)
      map.renew_major_date = World.date_hours() + Const.MAP_RENEW_MAJOR_HOURS
   end

   if World.date_hours() > map.renew_minor_date then
      renew_minor(map)
      map.renew_minor_date = World.date_hours() + Const.MAP_RENEW_MINOR_HOURS
   end
   -- <<<<<<<< shade2/map.hsp:2273 	return ..
end

local function recalculate_crowd(map)
   map.crowd_density = 0
   for _, chara in Chara.iter_all(map) do
      chara.time_this_turn = 0
      if not map.no_aggro_refresh then
         chara:reset_ai()
      end
      if not chara:is_allied() and chara.state ~= "Dead" then
         map.crowd_density = map.crowd_density + 1
      end
   end
end

local function update_quests(map)
   Quest.update_in_map(map)
end

local function proc_scene()
   -- >>>>>>>> shade2/map.hsp:1995 	proc "Map:Proc scene" ..
   -- TODO main quest
   -- this should get folded into base.on_map_minor_events
   -- <<<<<<<< shade2/map.hsp:2015 		} ..
end

local function proc_area_minor_events(map)
   -- >>>>>>>> shade2/map.hsp:2018 	proc "Map:Area specific" ..
   -- TODO
   map:emit("base.on_map_minor_events")
   -- <<<<<<<< shade2/map.hsp:2054 		} ..
end

local function init_world_map(map)
   -- >>>>>>>> shade2/map.hsp:2065 	proc "Map:Init world" ..
   -- TODO
   -- <<<<<<<< shade2/map.hsp:2070 		} ..
end

local function proc_area_major_events(map)
   ElonaCommand.wake_up_everyone(map)
   Chara.player():reset_ai()

   -- TODO
   map:emit("base.on_map_major_events")
end

local function proc_map_entered(map)
   if Map.is_world_map(map) then
      ExHelp.maybe_show(2)
   elseif map:has_type("town") then
      ExHelp.maybe_show(3)
   elseif map._archetype == "elona.shelter" then
      ExHelp.maybe_show(14)
   end

   if map:has_type("town")
      or map:has_type("guild")
      or map:calc("is_travel_destination")
   then
      if save.base.travel_distance >= 16 then
         local hours = World.date_hours() - save.base.travel_date
         Gui.mes("map.since_leaving.time_passed", math.floor(hours / 24), hours % 24, save.base.travel_last_town_name)

         local player = Chara.player()
         local gained_exp = math.floor(player:calc("level") * save.base.travel_distance * player:skill_level("elona.traveling") / 100 + 1)
         local total = 0
         for _, chara in Chara.iter_party(map) do
            if Chara.is_alive(chara) then
               total = total + 1
               chara.experience = chara.experience + gained_exp
            end
         end

         local mes = "map.since_leaving.walked.you"
         if total > 1 then
            mes = "map.since_leaving.walked.you_and_allies"
         end
         Gui.mes(mes, save.base.travel_distance)
         Skill.gain_skill_exp(player, "elona.traveling", 25 + save.base.travel_distance * 2 / 3, 0, 1000)
         save.base.travel_distance = 0
      end
   end
end

local function proc_quest_message(map)
   -- TODO
end

local function prepare_map(map, params)
   local load_type = assert(params.load_type)

   if not map.is_temporary then
      prepare_savable_map(map, load_type)
   end

   check_renew(map)

   recalculate_crowd(map)

   Gui.update_minimap(map)

   update_quests(map)

   if load_type == "initialize" then
      return
   end

   proc_scene(map)

   proc_area_minor_events(map)

   if Map.is_world_map(map) then
      init_world_map(map)
   end

   if load_type == "continue" then
      return
   end

   proc_area_major_events(map)

   proc_map_entered(map)

   proc_quest_message(map)
end

Event.register("base.on_map_enter", "Prepare map after load", prepare_map)

Event.register("base.on_map_enter", "reveal fog",
               function(map, params)
                  if map:has_type({"town", "world_map", "player_owned", "guild"}) then
                     map:mod("reveals_fog", true)
                  end
                  if map:calc("reveals_fog") then
                     for _, x, y in map:iter_tiles() do
                        map:memorize_tile(x, y)
                     end
                  end
end)
