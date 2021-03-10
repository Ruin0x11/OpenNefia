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
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local ExHelp = require("mod.elona.api.ExHelp")
local save = require("internal.global.save")
local Effect = require("mod.elona.api.Effect")
local config = require("internal.config")
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

local function reset_chara_flags(map)
   -- >>>>>>>> shade2/map.hsp:1914 		repeat mHeight ..
   for _, chara in Chara.iter_all(map) do
      chara.was_passed_quest_item = false

      if chara.state == "CitizenDead" and World.date_hours() >= chara.respawn_date then
         chara:revive()
      end

      if Chara.is_alive(chara) then
         if not chara:is_in_player_party() then
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

            if chara:find_role("elona.guard") then
               local player = Chara.player()
               if player:calc("karma") < Const.KARMA_BAD then
                  if player:calc("level") > chara:calc("level") then
                     Skill.gain_level(chara, false)
                  end
                  if not player:calc("is_incognito") then
                     chara:set_aggro(player, 200)
                     chara:set_relation_towards(player, Enum.Relation.Enemy)
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
   if not map.is_temporary then
      if World.date_hours() > map.renew_major_date and not is_first_renewal then
         map:emit("base.on_map_renew_geometry")
      end
   end
   -- <<<<<<<< shade2/map.hsp:1913 		} ..

   if load_type == "full" or load_type == "traveled" then
      reset_chara_flags(map)
   end
end

local function renew_major(map)
   -- >>>>>>>> shade2/map.hsp:2180 		proc "renew_major" ..
   local is_first_renewal = map.renew_major_date == 0

   Log.warn("Running map major renewal for %d. (%s)", map.uid, map._archetype)

   if not is_first_renewal then
      Feat.iter(map):filter(function(f) return f.is_temporary end)
                    :each(IMapObject.remove_ownership)

      if map:has_type("town") or map:has_type("guild") then
         for _, item in Item.iter(map) do
            -- Restocks fruit trees.
            item:emit("base.on_item_renew_major")

            if item.amount == 0 or item.own_state == Enum.OwnState.None then
               item:remove()
            end
         end
      end
   end

   for _, chara in Chara.iter_others(map) do
      chara:renew_status()
      if Chara.is_alive(chara) then
         if chara.is_summoned and Rand.one_in(2) then
            chara:remove_ownership()
         end
      elseif chara.state == "Dead" then
         local party = chara:get_party()
         if party then
            assert(save.base.parties:remove_member(party.uid, chara))
         end
         chara:remove_ownership()
      end
   end

   map:emit("base.on_map_renew_major", {is_first_renewal=is_first_renewal})
   -- <<<<<<<< shade2/map.hsp:2221 			} ..
end

local function renew_minor(map)
  local renew_steps
  -- >>>>>>>> elona122/shade2/map.hsp:2227 		if mRenewMinor=0:renewMulti=1:else:renewMulti=(d ..
  if map.renew_minor_date == 0 then
     renew_steps = 1
  else
     renew_steps = math.max(math.floor((World.date_hours() - map.renew_minor_date) / Const.MAP_RENEW_MINOR_HOURS), 1)
  end

   Log.warn("Running map minor renewal for %d. (%s, %d steps)", map.uid, map._archetype, renew_steps)

  -- <<<<<<<< elona122/shade2/map.hsp:2227 		if mRenewMinor=0:renewMulti=1:else:renewMulti=(d ..
  map:emit("base.on_map_renew_minor", {renew_steps=renew_steps})
end

local function check_renew(map)
   local area = Area.for_map(map)
   if area == nil then
      return
   end

   local area_meta = area.metadata
   -- >>>>>>>> shade2/map.hsp:2173 *check_renew ..
   if area_meta.arena_seed_renew_date and World.date_hours() >= area_meta.arena_seed_renew_date then
      area_meta.arena_seed = Rand.rnd(10000)
      area_meta.arena_seed_renew_date = World.date_hours() + Const.MAP_RENEW_MINOR_HOURS
   end

   local debug_renew = config.base.debug_always_renew_map

   if World.date_hours() > map.renew_major_date or debug_renew == "major" then
      renew_major(map)
      map.renew_major_date = World.date_hours() + Const.MAP_RENEW_MAJOR_HOURS
   end

   if World.date_hours() > map.renew_minor_date
      or debug_renew == "major"
      or debug_renew == "minor"
   then
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
      if not chara:is_in_player_party() and chara.state ~= "Dead" then
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
   -- this should get folded into base.on_map_loaded_events
   -- <<<<<<<< shade2/map.hsp:2015 		} ..
end

local function proc_map_loaded_events(map)
   -- >>>>>>>> shade2/map.hsp:2018 	proc "Map:Area specific" ..
   -- TODO
   map:emit("base.on_map_loaded_events")
   -- <<<<<<<< shade2/map.hsp:2054 		} ..
end

local function init_world_map(map)
   -- >>>>>>>> shade2/map.hsp:2065 	proc "Map:Init world" ..
   -- TODO
   -- <<<<<<<< shade2/map.hsp:2070 		} ..
end

local function proc_map_entered_events(map)
   -- >>>>>>>> shade2/map.hsp:2084 	proc "Map:Update area" ..
   Effect.wake_up_everyone(map)
   Chara.player():reset_ai()

   -- TODO
   map:emit("base.on_map_entered_events")
   -- <<<<<<<< shade2/map.hsp:2087 	mode=mode_Main:screenUpdate=-1:gosub *screen_refr ..
end

local function proc_map_entered(map)
   -- >>>>>>>> shade2/map.hsp:286 	if gDeepest<gLevel:if gArea!areaShelter:gDeepest= ..
   local area = Area.for_map(map)
   if area then
      area.deepest_level_visited = math.max(area.deepest_level_visited, Map.floor_number(map))
   end
   -- <<<<<<<< shade2/map.hsp:287 	if areaDeepest(gArea)<gLevel:areaDeepest(gArea)=g ..

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
         for _, chara in player:iter_party_members() do
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

local function initialize_map(map, params)
   local load_type = assert(params.load_type)

   if not map.is_temporary then
      prepare_savable_map(map, load_type)
   end

   check_renew(map)

   recalculate_crowd(map)

   update_quests(map)
end

Event.register("base.on_map_initialize", "Initialize map renewal, crowding and quests", initialize_map)

local function prepare_map(map, params)
   local load_type = assert(params.load_type)

   map:emit("base.on_map_initialize", {load_type=load_type})

   if load_type == "initialize" then
      return
   end

   proc_scene(map)

   proc_map_loaded_events(map)

   if Map.is_world_map(map) then
      init_world_map(map)
   end

   if load_type == "continue" then
      return
   end

   proc_map_entered_events(map)

   proc_map_entered(map)

   proc_quest_message(map)
end

Event.register("base.on_map_enter", "Prepare map after load", prepare_map)

Event.register("base.on_map_enter", "Reveal fog if town",
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
