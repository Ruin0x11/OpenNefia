local Filters = require("mod.elona.api.Filters")
local Chara = require("api.Chara")
local Map = require("api.Map")
local Event = require("api.Event")
local Pos = require("api.Pos")
local Anim = require("mod.elona_sys.api.Anim")
local World = require("api.World")
local Item = require("api.Item")
local Skill = require("mod.elona_sys.api.Skill")
local Feat = require("api.Feat")
local Calc = require("mod.elona.api.Calc")
local ElonaCommand = require("mod.elona.api.ElonaCommand")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Itemgen = require("mod.tools.api.Itemgen")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Material = require("mod.elona.api.Material")
local Magic = require("mod.elona.api.Magic")
local Quest = require("mod.elona_sys.api.Quest")
local elona_Quest = require("mod.elona.api.Quest")
local I18N = require("api.I18N")
local Action = require("api.Action")
local Ui = require("api.Ui")
local Const = require("api.Const")
local Weather = require("mod.elona.api.Weather")
local Hunger = require("mod.elona.api.Hunger")

local function sex_check_end(chara, partner)
   if not Chara.is_alive(partner)
   or not partner:has_activity("elona.sex") then
      Gui.mes_visible("activity.sex.spare_life", chara.x, chara.y, partner, I18N.get("ui.sex2." .. chara:calc("gender")))
      partner:remove_activity()
      chara:remove_activity()
      return true
   end

   if chara:is_player() then
      if not Effect.do_stamina_check(chara, 1 + Rand.rnd(2)) then
         Gui.mes("magic.common.too_exhausted")
         partner:remove_activity()
         chara:remove_activity()
         return true
      end
   end

   return false
end

local function sex_apply_effect(chara, is_partner)
   chara:remove_effect("elona.drunk")

   local exp = 250
   if not chara:is_ally() then
      exp = exp + 1000
   end

   if is_partner then
      if Rand.one_in(3) then
         chara:apply_effect("elona.insanity", 500)
      end
      if Rand.one_in(5) then
         chara:apply_effect("elona.paralysis", 500)
      end
      chara:apply_effect("elona.insanity", 300)
      chara:add_effect_turns(chara, -10)
      Skill.gain_skill_exp(chara, "elona.stat_constitution", exp)
      Skill.gain_skill_exp(chara, "elona.stat_will", exp)
   end
   if Rand.one_in(15) then
      chara:apply_effect("elona.sick", 200)
   end
   Skill.gain_skill_exp(chara, "elona.stat_charisma", exp)
end

data:add {
   _type = "base.activity",
   _id = "eating",
   elona_id = 1,

   params = { food = "table", no_message = "boolean" },
   default_turns = 8,

   animation_wait = 100,

   -- >>>>>>>> shade2/main.hsp:821 		if cc=pc:if (cRowAct(cc)!rowActEat)&(cRowAct(cc) ...
   on_interrupt = "prompt",
   -- <<<<<<<< shade2/main.hsp:821 		if cc=pc:if (cRowAct(cc)!rowActEat)&(cRowAct(cc) ..
   interrupt_on_displace = true,

   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1111 		cItemUsing(cc)=ci ...
            local chara = params.chara
            if chara:is_in_fov() then
               Gui.play_sound("base.eat1")
               if self.food.own_state == Enum.OwnState.NotOwned and chara:is_ally() then
                  Gui.mes("activity.eat.start.in_secret", chara, self.food)
               else
                  Gui.mes("activity.eat.start.normal", chara, self.food:build_name(1))
               end
            end

            chara:set_item_using(self.food)
            self.food:emit("elona.on_item_eat_begin", {chara=chara})
            -- <<<<<<<< shade2/proc.hsp:1116 		} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            if not Item.is_alive(self.food) then
               params.chara:remove_activity()
               params.chara:set_item_using(nil)
               return "turn_end"
            end

            -- TODO cargo check

            params.chara:set_item_using(self.food)

            return "turn_end"
         end
      },
      {
         id = "base.on_activity_cleanup",
         name = "start",

         callback = function(self, params)
            params.chara:set_item_using(nil)
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1122 	if sync(cc):txt lang(npcN(cc)+itemName(ci,1)+"を食べ ...
            local chara = params.chara
            if not self.no_message then
               if chara:is_in_fov() then
                  Gui.mes("activity.eat.finish", chara, self.food:build_name(1))
               end
            end
            params.chara:set_item_using(nil)

            Hunger.eat_food(chara, self.food)
            -- <<<<<<<< shade2/proc.hsp:1123 	gosub *insta_eat ..
         end
      }
   }
}

local traveling = {
   _type = "base.activity",
   _id = "traveling",
   elona_id = 3,

   params = { dest_x = "number", dest_y = "number" },

   animation_wait = 0,

   -- >>>>>>>> shade2/chara_func.hsp:456 	if cRowAct(c)!0:if cRowAct(c)!rowActTravel:cRowAc ...
   on_interrupt = "ignore",
   -- <<<<<<<< shade2/chara_func.hsp:456 	if cRowAct(c)!0:if cRowAct(c)!rowActTravel:cRowAc ..
}

function traveling.default_turns(self, params, chara)
   -- >>>>>>>> shade2/proc.hsp:786 		cActionPeriod(cc)=20 ...
   local turns = 20

   local weather = Weather.get()
   if weather.travel_speed_modifier then
      turns = weather.travel_speed_modifier(turns, chara)
   end

   local map = chara:current_map()
   if map then
      local tile = map:tile(chara.x, chara.y)

      if tile.kind == Enum.TileRole.Snow then
         turns = turns * 22 / 10
      end
   end

   turns = turns * 100 / (100 + chara:calc("travel_speed") + chara:skill_level("elona.traveling"))

   return turns
   -- <<<<<<<< shade2/proc.hsp:791 		cActionPeriod(cc)=cActionPeriod(cc)*100/(100+gTr ..
end

-- TODO #136
traveling.events = {}
traveling.events[#traveling.events+1] = {
   id = "base.on_activity_start",
   name = "start",

   callback = function(self, params)
   end
}

traveling.events[#traveling.events+1] = {
   id = "base.on_activity_pass_turns",
   name = "pass turns",

   callback = function(self, params)
      local chara = params.chara

      chara:emit("elona.on_chara_travel_in_world_map", {activity=self})

      -- >>>>>>>> shade2/proc.hsp:849 	if cActionPeriod(cc)>0:gMin++:return ..
      World.pass_time_in_seconds(60)
      -- <<<<<<<< shade2/proc.hsp:849 	if cActionPeriod(cc)>0:gMin++:return ..
   end
}

local travel_finished = false

traveling.events[#traveling.events+1] = {
   id = "base.on_activity_finish",
   name = "finish",

   callback = function(self, params)
      -- >>>>>>>> shade2/proc.hsp:851 	travelDone=true:gTravelDistance+=4 ...
      save.base.travel_distance = save.base.travel_distance + 4
      travel_finished = true

      -- Triggers "base.before_chara_moved". See below.
      Action.move(params.chara, self.dest_x, self.dest_y)
      -- <<<<<<<< shade2/proc.hsp:851 	travelDone=true:gTravelDistance+=4 ..
   end
}

data:add(traveling)

-- This function is sneaky as hell in the original code.
--
-- When you're in the world map and try to move onto another tile, the game will
-- end your turn early and give you the "traveling" activity. That gets finished
-- instantly as it has no animation delay. Each turn the activity runs it does
-- the traveling logic and *also* calls the "move to this square" routine
-- (*act_move) again, over and over. When the activity finishes it sets the
-- `travelDone` boolean, and then when *act_move gets called immediately after
-- it will finally update your position, doing all the normal movement things.
local function proc_world_map_travel(chara, params, result)
   -- >>>>>>>> shade2/action.hsp:635 	if dbg_noTravel=false:if mType=mTypeWorld : if cc ...
   if chara:is_player() then
      local map = chara:current_map()
      if map:has_type("world_map") then
         if travel_finished then
            travel_finished = false
            -- Continue with movement below.
         else
            if not chara:has_activity("elona.traveling") then
               -- removes any current activity as well
               chara:start_activity("elona.traveling", {dest_x=params.x,dest_y=params.y})
            end
            return { blocked = true }, "blocked"
         end
      end
   end
   -- <<<<<<<< shade2/action.hsp:635 	if dbg_noTravel=false:if mType=mTypeWorld : if cc ..
   return result
end
Event.register("base.before_chara_moved", "Proc world map travel", proc_world_map_travel, { priority = 150000 })

data:add {
   _type = "base.activity",
   _id = "fishing",
   elona_id = 7,

   params = {},
   default_turns = 100,

   animation_wait = 40,
   auto_turn_anim = "base.fishing",

   on_interrupt = "prompt",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            Gui.mes("start fishing")
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
               params.chara:remove_activity()
               return "turn_end"
            end
            if Rand.one_in(10) then
               params.chara:damage_sp(1)
            end

            return "turn_end"
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

local function calc_dig_success(map, params, result)
   local chara = params.chara
   local x = params.dig_x
   local y = params.dig_y
   local dig_count = params.dig_count
   local success = false
   local flag = false -- kind == 6

   local tile = map:tile(x, y)

   -- TODO config difficulty
   local difficulty = tile.mining_difficulty or 1500
   local coefficient = tile.mining_difficulty_coefficient or 20

   if Rand.rnd(difficulty) < chara:skill_level("elona.stat_strength") + chara:skill_level("elona.mining") * 10 then
      success = true
   end
   local p = math.floor(coefficient - chara:skill_level("elona.mining") / 2)
   if p > 0 and dig_count <= p then
      success = false
   end

   return success
end

Event.define_hook("calc_dig_success",
                  "Calculates if digging succeeded.",
                  false,
                  nil,
                  calc_dig_success)

local function create_dig_item(map, params)
   if map:calc("cannot_mine_items") then
      return
   end

   local x = params.dig_x
   local y = params.dig_y

   local item = nil
   if Rand.one_in(5) then
      item = "gold"
   end
   if Rand.one_in(8) then
      item = "item"
   end
   if item == "gold" then
      Item.create("elona.gold_piece", x, y, map)
   elseif item == "item" then
      local itemgen_params = {
         level = Calc.calc_object_level(map:calc("level"), map),
         quality = Calc.calc_object_quality(Enum.Quality.Good),
         categories = "elona.ore"
      }

      Itemgen.create(x, y, itemgen_params, map)
   end
end
Event.register("elona.on_dig_success", "Create mining item", create_dig_item)

local function do_dig_success(chara, x, y)
   local map = chara:current_map()
   local tile = MapTileset.get("elona.mapgen_tunnel", map)
   map:set_tile(x, y, tile)
   Map.spill_fragments(x, y, 2, map)
   Gui.play_sound("base.crush1")
   local anim = Anim.breaking(x, y)
   Gui.start_draw_callback(anim)

   for _, feat in Feat.at(x, y, map) do
      feat:emit("elona.on_feat_tile_digged_into", {chara=chara})
   end

   Gui.mes("activity.dig_mining.finish.wall")

   map:emit("elona.on_dig_success", {chara=chara, dig_x=x, dig_y=y})

   Skill.gain_skill_exp(chara, "elona.mining", 100)
end

data:add {
   _type = "base.activity",
   _id = "mining",
   elona_id = 5,

   params = { x = "number", y = "number" },
   default_turns = 40,

   animation_wait = 15,
   auto_turn_anim = "base.mining",

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            local map = params.chara:current_map()
            assert(map, "Character not in map")

            Gui.mes("activity.dig_mining.start.wall")
            local tile = map:tile(self.x, self.y)
            if tile.kind == Enum.TileRole.HardWall then
               Gui.mes("activity.dig_mining.start.hard")
            end

            self.dig_count = 0
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            local chara = params.chara
            if Rand.one_in(5) then
               chara:damage_sp(1)
            end
            self.dig_count = self.dig_count + 1

            local map = chara:current_map()

            local success = map:emit("elona.hook_calc_dig_success", {chara=chara, dig_x=self.x, dig_y=self.y, dig_count=self.dig_count})

            if success then
               do_dig_success(chara, self.x, self.y)
               chara:remove_activity()
               return "turn_end"
            elseif chara.turns_alive % 5 == 0 then
               Gui.mes_c("activity.dig_spot.sound", "Blue")
            end

            return "turn_end"
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            Gui.mes("activity.dig_mining.fail")
         end
      }
   }
}
data:add {
   _type = "base.activity",
   _id = "resting",
   elona_id = 4,

   params = {},
   default_turns = 50,

   animation_wait = 5,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            Gui.mes("activity.rest.start")
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            local chara = params.chara

            if self.turns % 2 == 0 then
               chara:heal_stamina(1, true)
            end
            if self.turns % 3 == 0 then
               chara:heal_hp(1, true)
               chara:heal_mp(1, true)
            end

            if save.elona_sys.awake_hours >= Const.SLEEP_THRESHOLD_MODERATE then
               local do_sleep = false
               if save.elona_sys.awake_hours >= Const.SLEEP_THRESHOLD_HEAVY then
                  do_sleep = true
               elseif Rand.one_in(2) then
                  do_sleep = true
               end
               if do_sleep then
                  Gui.mes("activity.rest.drop_off_to_sleep")
                  chara:set_item_using(nil)
                  ElonaCommand.do_sleep(chara, nil)
                  chara:remove_activity()
                  return "turn_end"
               end
            end

            return "turn_end"
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            Gui.mes("activity.rest.finish")
         end
      }
   }
}
data:add {
   _type = "base.activity",
   _id = "preparing_to_sleep",
   elona_id = 100,

   params = { bed = "table" },
   default_turns = 20,

   animation_wait = 5,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:447 		if gRowAct=rowActSleep{ ...
            local map = params.chara:current_map()
            local is_town_or_guild = map:has_type("player_owned") or map:has_type("town") or map:has_type("guild")
            if is_town_or_guild then
               Gui.mes("activity.sleep.start.other")
               self.turns = 5
            else
               Gui.mes("activity.sleep.start.global")
               self.turns = 20
            end
            params.chara:set_item_using(self.bed)
            -- <<<<<<<< shade2/proc.hsp:455 			} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            params.chara:set_item_using(self.bed)
            return "turn_end"
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:610 		txt lang("あなたは眠り込んだ。","You fall asleep."):gosub  ...
            Gui.mes("activity.sleep.finish")
            ElonaCommand.do_sleep(params.chara, self.bed)
            params.chara:set_item_using(nil)
            -- <<<<<<<< shade2/proc.hsp:610 		txt lang("あなたは眠り込んだ。","You fall asleep."):gosub  ..
         end
      }
   }
}
data:add {
   _type = "base.activity",
   _id = "sex",
   elona_id = 11,

   params = { partner = "table", is_host = "boolean" },
   default_turns = function()
      return 25 + Rand.rnd(10)
   end,

   animation_wait = 50,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            if not Chara.is_alive(self.partner) then
               return "stop"
            end

            if self.is_host then
               Gui.mes_visible("activity.sex.take_clothes_off", params.chara.x, params.chara.y, params.chara)
               self.partner:start_activity("elona.sex", {partner=params.chara,is_host=false}, self.turns * 2)
            end
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            local r = sex_check_end(params.chara, self.partner)
            if r then
               return "turn_end"
            end

            if not self.is_host and self.turns % 5 == 0 then
               Gui.mes_visible("activity.sex.dialog", params.chara.x, params.chara.y, "SkyBlue")
            end

            return "turn_end"
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            local r = sex_check_end(params.chara, self.partner)
            if r then
               return "turn_end"
            end

            if not self.is_host then
               return "turn_end"
            end

            sex_apply_effect(params.chara)
            sex_apply_effect(self.partner)

            local gold_earned = params.chara:skill_level("elona.stat_charisma") * (50 + Rand.rnd(50)) + 100

            Gui.mes_c_visible("activity.sex.after_dialog", params.chara.x, params.chara.y, "Talk")

            if not self.partner:is_player() then
               if self.partner.gold >= gold_earned then
                  Gui.mes_visible("activity.sex.take", params.chara, self.partner)
               else
                  if params.chara:is_in_fov() then
                     Gui.mes("activity.sex.take_all_i_have", self.partner)
                     if Rand.one_in(3) and not params.chara:is_player() then
                        Gui.mes("activity.sex.gets_furious", params.chara)
                        params.chara:set_target(self.partner)
                        params.chara.aggro = 20
                     end
                  end
                  self.partner.gold = math.max(self.partner.gold, 1)
                  gold_earned = self.partner.gold
               end

               self.partner.gold = self.partner.gold - gold_earned

               if params.chara:is_player() then
                  Skill.modify_impression(self.partner, 5)
                  Item.create("elona.gold_piece", params.chara.x, params.chara.y, {amount = gold_earned})
                  Gui.mes("common.something_is_put_on_the_ground")
                  Effect.modify_karma(params.chara, -1)
               else
                  params.chara.gold = params.chara.gold + gold_earned
               end
            end

            self.partner:remove_activity()
            return "turn_end"
         end
      }
   }
}

local function performance_calc_earned_gold(chara, instrument, audience, activity)
   -- >>>>>>>> shade2/proc.hsp:254 				p=(cPerformScore(cc)*cPerformScore(cc))*(100+i ..
   local gold = math.floor(activity.performance_quality * activity.performance_quality * (100 + (instrument:calc("performance_quality") or 0) / 5) / 100 / 1000 + Rand.rnd(10))
   gold = math.clamp(gold, 1, 100)
   gold = math.clamp(audience.gold * gold / 125, 0, chara:skill_level("elona.performer") * 100)
   if chara:is_party_leader_of(audience) then
      gold = Rand.rnd(math.clamp(gold, 1, 100)) + 1
   end
   if chara:find_role("elona.shopkeeper") then
      gold = math.floor(gold / 5)
   end

   return math.min(gold, audience.gold)
   -- <<<<<<<< shade2/proc.hsp:261 				cGold(tc)-=p:cGold(cc)+=p:gold+=p ..
end

local function performance_bad(chara, instrument, audience, activity)
   -- >>>>>>>> shade2/proc.hsp:241 				cPerformScore(cc)-=cLevel(tc)/2 ..
   activity.performace_quality = activity.performance_quality - math.floor(audience:calc("level") / 2)

   Gui.mes_c_visible("activity.perform.dialog.angry", audience.x, audience.y, "SkyBlue")
   Gui.mes_visible("activity.perform.throws_rock", audience.x, audience.y, audience)
   local damage = audience:emit("elona.calc_bad_performance_damage", {chara=chara,instrument=instrument,activity=activity}, Rand.rnd(audience:calc("level") + 1) + 1)
   chara:damage_hp(damage, "elona.performer")
   -- <<<<<<<< shade2/proc.hsp:250 				dmgHP cc,dmg,dmgFromPerform:if cExist(cc)=cDea ..
end

local function pos_nearby(x, y, map)
   x = math.clamp(x - 1 + Rand.rnd(3), 0, map:width() - 1)
   y = math.clamp(y - 1 + Rand.rnd(3), 0, map:height() - 1)
   if not map:can_access(x, y) then
      return nil
   end

   return x, y
end

local function get_thrown_item_filter(chara, instrument, audience, activity)
   local level, quality
   local map = chara:current_map()

   if instrument:find_merged_enchantment("elona.strad") then
      level = Calc.calc_object_level(activity.performance_quality / 8, map)
      quality = Enum.Quality.Good
      if Rand.one_in(4) then
         quality = Enum.Quality.Great
      end
      quality = Calc.calc_object_quality(quality)
   else
      level = Calc.calc_object_level(activity.performance_quality / 10, map)
      quality = Calc.calc_object_quality(Enum.Quality.Good)
   end

   local categories = Rand.choice(Filters.fsetperform)
   local id = nil

   local quest = Quest.get_immediate_quest()
   if quest and quest._id == "elona.party" then
      if Rand.one_in(150) then
         id = "elona.safe"
      end
      if Rand.one_in(150) then
         id = "elona.small_medal"
      end
      if audience:calc("level") > 15 and Rand.one_in(1000) then
         id = "elona.kill_kill_piano"
      end
      if audience:calc("level") > 15 and Rand.one_in(1000) then
         id = "elona.kill_kill_piano"
      end
   else
      if Rand.one_in(10) then
         id = "elona.music_ticket"
      end
      if Rand.one_in(250) then
         id = "elona.platinum_coin"
      end
   end

   return {
      level = level,
      quality = quality,
      categories = categories,
      id = id
   }
end

local function performance_throw_item(chara, instrument, audience, activity, x, y)
   -- >>>>>>>> shade2/proc.hsp:285 					if encFindSpec(ci,encStrad)!falseM{ ..
   local map = chara:current_map()
   local filter = get_thrown_item_filter(chara, instrument, audience, activity)
   filter.ownerless = true
   local item = Itemgen.create(nil, nil, filter)

   if item then
      local cb = Anim.ranged_attack(audience.x, audience.y, x, y, item:calc("image"), item:calc("color"))
      Gui.start_draw_callback(cb)
      assert(map:take_object(item, x, y))
      item:refresh_cell_on_map()
      activity.number_of_tips = activity.number_of_tips + 1
   end
   -- <<<<<<<< elona122/shade2/proc.hsp:307 						} ..
end

local function update_quest_score(audience)
   local quest = Quest.get_immediate_quest()
   if quest and quest._id == "elona.party" then
      if not audience:is_in_player_party() then
         audience.impression = audience.impression + Rand.rnd(3)
         local score = elona_Quest.calc_party_score(audience:current_map())
         -- >>>>>>>> shade2/calculation.hsp:1346 	if p>qParam2(gQuestRef) : txtEf coBlue: txt "(+"+ ..
         local diff = score - quest.params.current_points
         if diff > 0 then
            Gui.mes_c(("(+%d) "):format(diff), "Blue")
         elseif diff < 0 then
            Gui.mes_c(("(%d) "):format(diff), "Red")
         end
         quest.params.current_points = score
         -- <<<<<<<< shade2/calculation.hsp:1349 	return  ..
      end
   end
end

local function performance_good(chara, instrument, audience, activity)
   -- >>>>>>>> shade2/proc.hsp:265 			p=rnd(cLevel(tc)+1)+1 ..
   local level = audience:calc("level")
   local quality_delta = Rand.rnd(level + 1) + 1
   if Rand.rnd(chara:skill_level("elona.performer") + 1) > Rand.rnd(level * 2 + 1) then
      update_quest_score(audience)
      if Rand.one_in(2) then
         activity.performance_quality = activity.performance_quality + quality_delta
      elseif Rand.one_in(2) then
         activity.performance_quality = activity.performance_quality - quality_delta
      end
   end

   if instrument:find_merged_enchantment("elona.gould") and Rand.one_in(15) then
      audience:apply_effect("elona.drunk", 500)
   end

   if Rand.rnd(chara:skill_level("elona.performer") + 1) > Rand.rnd(level * 5 + 1) then
      if Rand.one_in(3) then
         Gui.mes_c_visible("activity.perform.dialog.interest", chara.x, chara.y, "SkyBlue", audience, chara)
         activity.performance_quality = activity.performance_quality + level + 5

         local receive_goods = chara:calc("perform_receives_goods")
         if receive_goods == nil then
            receive_goods = chara:is_player()
         end
         if receive_goods and not chara:is_party_leader_of(audience) then
            local get_goods = Rand.one_in(activity.number_of_tips * 2 + 2)
            if get_goods then
               local map = audience:current_map()
               local x, y = pos_nearby(chara.x, chara.y, map)

               if x and map:has_los(audience.x, audience.y, x, y) then
                  performance_throw_item(chara, instrument, audience, activity, x, y)
               end
            end
         end
      end
   end
   -- <<<<<<<< shade2/proc.hsp:309 				} ..
end

local function performance_apply(chara, instrument, audience, activity)
   -- >>>>>>>> shade2/proc.hsp:209 			if cExist(cnt)!cAlive	:continue ..
   local gold_earned = 0

   if not Chara.is_alive(audience) then
      return
   end

   local date = audience:calc("interest_renew_date")
   if World.date_hours() >= date then
      audience.interest = 100
   end

   if chara:is_in_fov() then
      if not audience:is_in_fov() then
         return
      end
   elseif Pos.dist(chara.x, chara.y, audience.x, audience.y) > 3 then
      return
   end

   if audience:calc("interest") <= 0 then
      return
   end

   if audience:has_effect("elona.sleep") then
      return
   end

   if chara.uid == audience.uid then
      return
   end

   if audience:relation_towards(chara) <= Enum.Relation.Enemy then
      if audience:get_aggro(chara) <= 0 then
         Gui.mes_visible("activity.perform.gets_angry", audience.x, audience.y, audience)
      end
      audience:set_aggro(chara, 30)
      return
   end

   if chara:is_player() then
      audience.interest = audience.interest - Rand.rnd(15)
      audience.interest_renew_date = World.date_hours() + 12
   end

   if audience:calc("interest") <= 0 then
      Gui.mes_c_visible("activity.perform.disinterest", audience.x, audience.y, "SkyBlue")
      audience:reset("interest", 0)
      return
   end

   if chara:skill_level("elona.performer") < audience:calc("level") then
      if Rand.one_in(3) then
         performance_bad(chara, instrument, audience, activity)
         return
      end
   end

   if Rand.one_in(3) then
      local gold = performance_calc_earned_gold(chara, instrument, audience, activity)
      audience.gold = audience.gold - gold
      chara.gold = chara.gold + gold
      gold_earned = gold_earned + gold
   end

   if audience:calc("level") > chara:skill_level("elona.performer") then
      return
   end

   performance_good(chara, instrument, audience, activity)

   return gold_earned
   -- <<<<<<<< shade2/proc.hsp:310  ..
end

data:add {
   _type = "base.activity",
   _id = "performing",
   elona_id = 6,

   params = { instrument = "table", performace_quality = "number", tip_gold = "number", number_of_tips = "number" },
   default_turns = 61,

   animation_wait = 40,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:189 	if cRowAct(cc)=false{ ..
            self.performance_quality = 40
            self.tip_gold = 0
            self.number_of_tips = 0

            if not Item.is_alive(self.instrument) then
               return "stop"
            end
            Gui.mes_visible("activity.perform.start", params.chara.x, params.chara.y, params.chara, self.instrument:build_name(1))
            -- <<<<<<<< shade2/proc.hsp:197 		} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:199 	if cActionPeriod(cc)>0{ ..
            local chara = params.chara
            if self.turns % 10 == 0 then
               if Rand.one_in(10) then
                  Gui.mes_c_visible("activity.perform.sound.random", chara.x, chara.y, "Blue")
               end
               Gui.mes_c("activity.perform.sound.cha", "Blue")
            end
            if self.turns % 20 == 0 then
               Effect.make_sound(chara, chara.x, chara.y, 5, 1, 1)

               local gold_earned = 0
               for _, audience in chara:current_map():iter_charas() do
                  local gold = performance_apply(chara, self.instrument, audience, self) or 0
                  gold_earned = gold_earned + math.floor(gold)
                  if not Chara.is_alive(chara) then
                     return "turn_end"
                  end
               end

               if gold_earned > 0 then
                  self.tip_gold = self.tip_gold + gold_earned
                  if chara:is_in_fov() then
                     Gui.play_sound("base.getgold1", chara.x, chara.y)
                  end
               end
            end

            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:315 		} ..
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:318 	repeat 1 ..
            local quality = self.performance_quality

            if params.chara:is_player() then
               local mes
               if quality < 0 then
                  mes = 0
               elseif quality < 20 then
                  mes = 1
               elseif quality < 40 then
                  mes = 2
               elseif quality == 40 then
                  mes = 3
               elseif quality < 60 then
                  mes = 4
               elseif quality < 80 then
                  mes = 5
               elseif quality < 100 then
                  mes = 6
               elseif quality < 120 then
                  mes = 7
               elseif quality < 150 then
                  mes = 8
               else
                  mes = 9
               end
               Gui.mes("activity.perform.quality._" .. mes)
            end

            if quality > 40 then
               quality = math.floor(quality * (100 + (self.instrument:calc("performance_quality") or 0) / 5) / 100)
            end

            if self.tip_gold ~= 0 then
               Gui.mes_visible("activity.perform.tip", params.chara.x, params.chara.y, params.chara, self.tip_gold)
            end

            local exp = quality - params.chara:skill_level("elona.performer") + 50
            if exp > 0 then
               Skill.gain_skill_exp(params.chara, "elona.performer", exp, 0, 0)
            end
            -- <<<<<<<< shade2/proc.hsp:338 	return ..
         end
      }
   }
}

local function dig_random_site(activity, params)
   -- >>>>>>>> shade2/proc.hsp:10 *randomSite ..
   local feat = activity.feat
   local chara = params.chara

   local map = chara:current_map()
   local level = map:calc("level")
   local site = map:calc("material_type") or "elona.field"

   if map:has_type("world_map") then
      level = math.floor(chara:calc("level") / 2) + Rand.rnd(10)
      if level > 30 then
         level = 30 + Rand.rnd(Rand.rnd(level-30)+1)
      end
      local tile = map:tile(chara.x, chara.y)
      if tile.field_type then
         local field_type = data["elona.field_type"]:ensure(tile.field_type)
         if field_type.material_type then
            site = field_type.material_type
         end
      end
   end

   if feat then
      local ty = feat:calc("material_type")
      if ty then
         site = ty
      end
      local res = feat:emit("elona.calc_feat_materials", {}, {level=level,material_type=site})
      if res then
         level = res.level or level
         site = res.material_type or site
      end
   end

   local site_data = data["elona.material_spot"]:ensure(site)

   if Rand.one_in(7) then
      local choices = site_data.materials or {}
      local id, txt_type
      local amount = 1
      if site_data.on_search then
         id, txt_type = site_data:on_search({chara=chara,feat=feat,material_level=level,material_choices=choices})
      else
         id, txt_type = Material.random_material_id(level, 0, choices), nil
      end

      if id then
         Material.gain(chara, id, amount, txt_type)
      end
   end

   if Rand.one_in(50 + chara:trait_level("elona.perm_material")*20) then
      local id = "activity.searching.no_more"
      if site_data.on_finish then
         id = site_data.on_finish
      end
      Gui.mes(id)
      return true
   end

   return false
   -- <<<<<<<< shade2/proc.hsp:64 	return ..
end

data:add {
   _type = "base.activity",
   _id = "searching",
   elona_id = 105,

   params = { feat = "table", type = "string" },
   default_turns = 20,

   animation_wait = 15,
   auto_turn_anim = "base.searching",

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:996 	if cRowAct(cc)=false{ ..
            if not Feat.is_alive(self.feat) then
               return "stop"
            end
            Gui.mes("activity.dig_spot.start.other")
            -- <<<<<<<< shade2/proc.hsp:1002 		} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1004 	if rowActRE!false:gosub *randomSite:return ..
            local finished = dig_random_site(self, params)
            if finished then
               return self:finish()
            end
            if self.turns % 5 == 0 then
               Gui.mes_c("activity.dig_spot.sound", "Blue")
            end
            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:1009 		} ..
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1011:DONE 	txt lang("地面を掘り終えた。","You finish digging.") ..
            Gui.mes("activity.dig_spot.finish")
            -- <<<<<<<< shade2/proc.hsp:1012 	if mType=mTypeWorld{ ..

            -- >>>>>>>> shade2/proc.hsp:1035:DONE 	spillFrag refX,refY,1 ..
            if self.feat then
               self.feat:remove_ownership()
            end
            local map = params.chara:current_map()
            Map.spill_fragments(params.chara.x, params.chara.y, 1, map)
         end
         -- <<<<<<<< shade2/proc.hsp:1037 	return ..
      }
   }
}

data:add {
   _type = "base.activity",
   _id = "digging_spot",
   elona_id = 8,

   params = {},
   default_turns = 0,

   animation_wait = 15,
   auto_turn_anim = "base.searching",

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:996:DONE 	if cRowAct(cc)=false{ ..
            Gui.mes("activity.dig_spot.start.global")
            -- <<<<<<<< shade2/proc.hsp:1002 		} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1006:DONE 	if cActionPeriod(cc)>0{ ..
            if self.turns % 5 == 0 then
               Gui.mes_c("activity.dig_spot.sound", "Blue")
            end
            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:1009 		} ..
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1011:DONE 	txt lang("地面を掘り終えた。","You finish digging.") ..
            Gui.mes("activity.dig_spot.finish")
            local map = params.chara:current_map()
            map:emit("elona.on_search_finish", {chara=params.chara})
            Map.spill_fragments(params.chara.x, params.chara.y, 1, map)
            -- <<<<<<<< shade2/proc.hsp:1037:DONE 	return ..
         end
      }
   }
}

data:add {
   _type = "base.activity",
   _id = "reading_spellbook",
   elona_id = 2,

   params = { skill_id = "string", spellbook = "table", },
   default_turns = 10,

   animation_wait = 25,

   -- >>>>>>>> shade2/main.hsp:821 		if cc=pc:if (cRowAct(cc)!rowActEat)&(cRowAct(cc) ...
   on_interrupt = "prompt",
   -- <<<<<<<< shade2/main.hsp:821 		if cc=pc:if (cRowAct(cc)!rowActEat)&(cRowAct(cc) ..

   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1188 		if sync(cc) : txt lang(npcN(cc)+itemName(ci,1)+" ..
            Gui.mes_visible("activity.read.start", params.chara, self.spellbook:build_name(1))
            -- <<<<<<<< shade2/proc.hsp:1188 		if sync(cc) : txt lang(npcN(cc)+itemName(ci,1)+" ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1193 	if cActionPeriod(cc)>0{ ..
            Skill.gain_skill_exp(params.chara, "elona.literacy", 15, 10, 100)

            local skill_data = data["base.skill"]:ensure(self.skill_id)
            local difficulty = skill_data.difficulty
            local curse = self.spellbook:calc("curse_state")

            if curse == Enum.CurseState.Blessed then
               difficulty = difficulty * 100 / 120
            elseif Effect.is_cursed(curse) then
               difficulty = difficulty * 150 / 100
            end

            local skill_level = params.chara:skill_level(self.skill_id)
            local success = Magic.try_to_read_spellbook(params.chara, difficulty, skill_level)

            if not success then
               params.chara:remove_activity()
               self.spellbook.charges = math.max(self.spellbook.charges - 1, 0)
               if self.spellbook.charges <= 0 then
                  self.spellbook:remove(1)
                  if params.chara:is_in_fov() then
                     Gui.mes("action.read.book.falls_apart", self.spellbook:build_name(1))
                  end
               end
            end

            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:1211 		} ..
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1230 		skillGain cc,efId,1,(rnd(defSpellStock/2+1)+defS ..
            local chara = params.chara

            Gui.mes_visible("activity.read.finish", chara, self.spellbook:build_name(1))

            local function calc_gained_stock(memorization, current_stock)
               local BASE_STOCK = 100
               return (Rand.rnd(BASE_STOCK / 2 + 1) + BASE_STOCK / 2)
                  * (90 + memorization + ((memorization > 0) and 1 or 0) * 20)
                  / math.clamp((100 + current_stock) / 2, 50, 100)
                  + 1
            end

            local memorization = chara:skill_level("elona.memorization")
            local current_stock = chara:spell_stock(self.skill_id)
            local skill_data = data["base.skill"]:ensure(self.skill_id)
            local difficulty = skill_data.difficulty

            Skill.gain_skill(params.chara, self.skill_id, 1, calc_gained_stock(memorization, current_stock))
            Skill.gain_skill_exp(params.chara, "elona.memorization", 10 + difficulty / 5)
            save.elona_sys.reservable_spellbook_ids[self.spellbook._id] = true

            Effect.identify_item(self.spellbook, Enum.IdentifyState.Name)

            self.spellbook.charges = math.max(self.spellbook.charges - 1, 0)
            if self.spellbook.charges <= 0 then
               self.spellbook:remove(1)
               if params.chara:is_in_fov() then
                  Gui.mes("action.read.book.falls_apart", self.spellbook:build_name(1))
               end
            end
            -- <<<<<<<< shade2/proc.hsp:1232 		if iReserve(iId(ci))=0 : iReserve(iId(ci))=1 ..
         end
      }
   }
}

data:add {
   _type = "base.activity",
   _id = "reading_ancient_book",
   elona_id = 2,

   params = { ancient_book = "table", },
   default_turns = 10,

   animation_wait = 25,

   -- >>>>>>>> shade2/main.hsp:821 		if cc=pc:if (cRowAct(cc)!rowActEat)&(cRowAct(cc) ...
   on_interrupt = "prompt",
   -- <<<<<<<< shade2/main.hsp:821 		if cc=pc:if (cRowAct(cc)!rowActEat)&(cRowAct(cc) ..

   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1188 		if sync(cc) : txt lang(npcN(cc)+itemName(ci,1)+" ..
            Gui.mes_visible("activity.read.start", params.chara, self.ancient_book:build_name(1))
            -- <<<<<<<< shade2/proc.hsp:1188 		if sync(cc) : txt lang(npcN(cc)+itemName(ci,1)+" ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1193 	if cActionPeriod(cc)>0{ ..
            Skill.gain_skill_exp(params.chara, "elona.literacy", 15, 10, 100)

            local base_diff = self.ancient_book.params.ancient_book_difficulty
            local difficulty = 50 + base_diff * 50 + base_diff * base_diff * 20
            local curse = self.ancient_book:calc("curse_state")

            if curse == Enum.CurseState.Blessed then
               difficulty = difficulty * 100 / 120
            elseif Effect.is_cursed(curse) then
               difficulty = difficulty * 150 / 100
            end

            local stat_level = params.chara:skill_level("elona.stat_magic")
            local success = Magic.try_to_read_spellbook(params.chara, difficulty, stat_level)

            if not success then
               params.chara:remove_activity()
               self.ancient_book.charges = math.max(self.ancient_book.charges - 1, 0)
               if self.ancient_book.charges <= 0 then
                  self.ancient_book:remove(1)
                  if params.chara:is_in_fov() then
                     Gui.mes("action.read.book.falls_apart", self.ancient_book:build_name(1))
                  end
               end
            end

            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:1211 		} ..
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1230 		skillGain cc,efId,1,(rnd(defSpellStock/2+1)+defS ..
            local chara = params.chara

            Gui.mes_visible("activity.read.finish", chara, self.ancient_book:build_name(1))

            Effect.identify_item(self.ancient_book, Enum.IdentifyState.Full)
            Gui.mes("action.read.book.finished_decoding", self.ancient_book:build_name(1))
            self.ancient_book.params.ancient_book_is_decoded = true
            self.ancient_book.has_charge = false
            self.ancient_book.charges = 1

            -- TODO: shade2/proc.hsp:3118 ((iId(ci)=idMageBook)&(iParam2(ci)!0))

            self.ancient_book:stack()
            -- <<<<<<<< shade2/proc.hsp:1228 		item_stack pc,ci,1 ..
         end
      }
   }
}

data:add {
   _type = "base.activity",
   _id = "harvest",
   elona_id = 103,

   params = { item = "table", },
   default_turns = function(self, params, chara)
      -- >>>>>>>> shade2/proc.hsp:467 			cActionPeriod(cc)=10+limit(iWeight(ci)/(1+sSTR( ...
      local item = params.item
      return 10 + math.clamp(item:calc("weight") / (1 + chara:skill_level("elona.stat_strength") * 10 + chara:skill_level("elona.gardening") * 40), 1, 100)
      -- <<<<<<<< shade2/proc.hsp:467 			cActionPeriod(cc)=10+limit(iWeight(ci)/(1+sSTR( ..
   end,

   -- >>>>>>>> shade2/main.hsp:848 			if gRowAct=rowActHarvest:at 40:else:if gRowAct= ...
   animation_wait = 40,
   -- <<<<<<<< shade2/main.hsp:848 			if gRowAct=rowActHarvest:at 40:else:if gRowAct= ..

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:466 			txt lang(itemName(ci,1)+"を掘り始めた。","You start to ...
            Gui.mes("activity.harvest.start", self.item:build_name(1))
            -- <<<<<<<< shade2/proc.hsp:466 			txt lang(itemName(ci,1)+"を掘り始めた。","You start to ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:487 		if gRowAct=rowActHarvest{ ...
            local chara = params.chara

            if Rand.one_in(5) then
               Skill.gain_skill_exp(chara, "elona.gardening", 20, 4)
            end
            if Rand.one_in(6) and Rand.rnd(55) > chara:base_skill_level("elona.stat_strength") + 25 then
               Skill.gain_skill_exp(chara, "elona.stat_strength", 50)
            end
            if Rand.one_in(8) and Rand.rnd(55) > chara:base_skill_level("elona.stat_constitution") + 28 then
               Skill.gain_skill_exp(chara, "elona.stat_constitution", 50)
            end
            if Rand.one_in(10) and Rand.rnd(55) > chara:base_skill_level("elona.stat_will") + 30 then
               Skill.gain_skill_exp(chara, "elona.stat_will", 50)
            end
            if Rand.one_in(4) then
               Gui.mes_c("activity.harvest.sound", "SkyBlue")
            end
            -- <<<<<<<< shade2/proc.hsp:497 			} ..

            return "turn_end"
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:623 	if gRowAct=rowActHarvest{ ...
            Gui.mes("activity.harvest.finish", self.item:build_name(1), Ui.display_weight(self.item:calc("weight")))
            Action.get(params.chara, self.item)
            -- <<<<<<<< shade2/proc.hsp:626 		} ..
         end
      }
   }
}

data:add {
   _type = "base.activity",
   _id = "training",
   elona_id = 104,

   params = { skill_id = "string", item = "table" },

   -- >>>>>>>> shade2/proc.hsp:478 			cActionPeriod(cc)=50 ...
   default_turns = 50,
   -- <<<<<<<< shade2/proc.hsp:478 			cActionPeriod(cc)=50 ..

   -- >>>>>>>> shade2/main.hsp:848 			if gRowAct=rowActHarvest:at 40:else:if gRowAct= ...
   animation_wait = 40,
   -- <<<<<<<< shade2/main.hsp:848 			if gRowAct=rowActHarvest:at 40:else:if gRowAct= ..

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            local chara = params.chara

            if Item.is_alive(self.item) then
               chara:set_item_using(self.item)
            end

            -- >>>>>>>> shade2/proc.hsp:469 		if gRowAct=rowActTrain{ ...
            if not Weather.is_bad_weather() and save.elona.next_train_date > World.date_hours() then
               Gui.mes("activity.study.start.bored")
               return "stop"
            end

            save.elona.next_train_date = World.date_hours() + 48

            if self.skill_id == "random" then
               Gui.mes("activity.study.start.training")
            else
               data["base.skill"]:ensure(self.skill_id)
               Gui.mes("activity.study.start.studying", "ability." .. self.skill_id .. ".name")
            end

            -- TODO shelter
            local map = chara:current_map()
            local is_town_or_guild = map:has_type("player_owned") or map:has_type("town") or map:has_type("guild")
            local can_study_here = map._archetype == "elona.shelter" or (map:calc("is_indoor") and is_town_or_guild)
            if Weather.is_bad_weather() and can_study_here then
               Gui.mes("activity.study.start.weather_is_bad")
            end
            -- <<<<<<<< shade2/proc.hsp:477 				}		 ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:499 		if gRowAct=rowActTrain{ ...
            local chara = params.chara
            local map = chara:current_map()
            local is_town_or_guild = map:has_type("player_owned") or map:has_type("town") or map:has_type("guild")

            local chance = 25

            if Weather.is_bad_weather() then
               -- TODO shelter
               if map._archetype == "elona.shelter" then
                  chance = 5
               elseif map:calc("is_indoor") then
                  if is_town_or_guild then
                     chance = 5
                     World.pass_time_in_seconds(60 * 30)
                  end
               end
            end

            if Rand.one_in(chance) then
               if self.skill_id == "random" then
                  Skill.gain_skill_exp(chara, Skill.random_base_attribute(), 25)
               else
                  Skill.gain_skill_exp(chara, self.skill_id, 25)
               end
            end

            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:511 			} ..
         end
      },
      {
         id = "base.on_activity_cleanup",
         name = "cleanup",

         callback = function(self, params)
            params.chara:set_item_using(nil)
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:627 	if gRowAct=rowActTrain{ ...
            local item = params.chara.item_using
            if self.skill_id == "random" then
               Gui.mes("activity.study.finish.training")
            else
               Gui.mes("activity.study.finish.studying", "ability." .. self.skill_id .. ".name")
            end
            -- <<<<<<<< shade2/proc.hsp:629 		} ..
         end
      }
   }
}

local function calc_base_stealing_power(chara, item)
   local power = chara:skill_level("elona.pickpocket") * 5 + chara:skill_level("elona.stat_dexterity") + 25

   local hour = World.date().hour
   if hour >= 19 or hour < 7 then
      power = power * 15 / 10
   end
   if item:calc("quality") == Enum.Quality.Good then
      power = power * 8 / 10
   end
   if item:calc("quality") >= Enum.Quality.Great then
      power = power * 5 / 10
   end

   return power
end

local function calc_target_steal_power(base_steal_power, chara, other)
   -- >>>>>>>> shade2/proc.hsp:537 			p=rnd(i+1)*(80+(sync(cnt)=false)*50+dist(cX(cnt ...
   local power = Rand.rnd(base_steal_power+1)

   local factor = 80
   if not other:is_in_fov() then
      factor = factor + 50
   end

   factor = factor + Pos.dist(other.x, other.y, chara.x, chara.y) * 20

   return power + factor / 200
   -- <<<<<<<< shade2/proc.hsp:537 			p=rnd(i+1)*(80+(sync(cnt)=false)*50+dist(cX(cnt ..
end

local function calc_target_noticed_stealing(other, steal_power)
   -- >>>>>>>> shade2/proc.hsp:539 			if rnd(sPER(cnt)+1)>p{ ...
   return Rand.rnd(other:skill_level("elona.stat_perception") + 1) > steal_power
   -- <<<<<<<< shade2/proc.hsp:539 			if rnd(sPER(cnt)+1)>p{ ..
end

data:add {
   _type = "base.activity",
   _id = "pickpocket",
   elona_id = 105,

   params = { item = "table" },
   default_turns = function(self, params)
      -- >>>>>>>> shade2/proc.hsp:443:DONE 			cActionPeriod(cc)=2+limit(iWeight(ci)/500,0,50) ..
      return 2 + math.clamp(self.item:calc("weight") / 500, 0, 50)
      -- <<<<<<<< shade2/proc.hsp:444 		;	if develop:cActionPeriod(cc)=1 ..
   end,

   animation_wait = 15,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:441:DONE 		if gRowAct=rowActSteal{ ..
            if not Item.is_alive(self.item) then
               return "stop"
            end
            Gui.mes("activity.steal.start", self.item:build_name(1))
            -- <<<<<<<< shade2/proc.hsp:445 			} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:513 		if gRowAct=rowActSteal{ ..
            local chara = params.chara
            local map = chara:current_map()

            local result = self.item:emit("elona.on_item_steal_attempt", params)
            if result then
               return result
            end

            local owner = self.item:get_owning_chara()
            local from_enemy = owner and owner.relation == Enum.Relation.Enemy

            local base_steal_power = calc_base_stealing_power(chara, self.item)

            Effect.make_sound(chara, chara.x, chara.y, 5, 8)

            local caught_stealing = false

            local can_notice_stealing = function(other)
               return Chara.is_alive(other)
                  and not chara:has_effect("elona.sleep")
                  and Pos.dist(other.x, other.y, chara.x, chara.y) <= 5
                  and (not from_enemy or owner.uid == other.uid)
            end

            for _, other in Chara.iter_others(map):filter(can_notice_stealing) do
               local steal_power = calc_target_steal_power(base_steal_power, chara, other)

               if calc_target_noticed_stealing(other, steal_power) then
                  if other:is_in_fov() then
                     Gui.mes("activity.steal.notice.in_fov", other)
                  else
                     Gui.mes("activity.steal.notice.out_of_fov", other)
                  end

                  if other:find_role("elona.guard") then
                     Gui.mes("activity.steal.notice.dialog.guard")
                  else
                     Gui.mes("activity.steal.notice.dialog.other")
                  end
                  Skill.modify_impression(other, -5)

                  other:set_emotion_icon("elona.notice", 5)

                  caught_stealing = true
               end
            end

            if caught_stealing then
               Gui.mes("activity.steal.notice.you_are_found")
               Effect.modify_karma(chara, -5)

               if owner and owner._id ~= "elona.ebon" and not owner:has_effect("elona.sleep") then
                  owner:set_relation_towards(chara, Enum.Relation.Hate)
                  chara:act_hostile_towards(owner)
                  Skill.modify_impression(owner, -20)
               end

               Effect.turn_guards_hostile(map, chara)
            end

            local should_abort = caught_stealing or false

            if owner then
               if not should_abort and not Chara.is_alive(owner) then
                  Gui.mes("activity.steal.target_is_dead")
                  should_abort = true
               end
               -- TODO user custom chara
               if not should_abort and owner:find_role("elona.custom_chara") then
                  Gui.mes("activity.steal.cannot_be_stolen")
                  should_abort = true
               end
               if not should_abort and Pos.dist(chara.x, chara.y, owner.x, owner.y) >= 3 then
                  Gui.mes("activity.steal.you_lose_the_target")
                  should_abort = true -- XXX: was false in vanilla, bug?
               end
            end

            if not Item.is_alive(self.item) then
               should_abort = true
            end

            if not should_abort and self.item:calc("is_precious") then
               Gui.mes("activity.steal.cannot_be_stolen")
               should_abort = true
            end

            if not should_abort and self.item:calc("weight") >= chara:skill_level("elona.stat_strength") * 500 then
               Gui.mes("activity.steal.it_is_too_heavy")
               should_abort = true
            end

            local chara_using = self.item:get_chara_using()
            if not should_abort and Chara.is_alive(chara_using) then
               Gui.mes("action.someone_else_is_using")
               should_abort = true
            end

            if should_abort then
               Gui.mes("activity.steal.abort")
               chara:remove_activity()
            end

            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:569 			} ..
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:574 	if gRowAct=rowActSteal{ ..
            local chara = params.chara
            local owner = self.item:get_owning_chara()
            if (owner and not Chara.is_alive(owner)) or not Item.is_alive(self.item) then
               Gui.mes("activity.steal.abort")
               chara:remove_activity()
               return
            end

            local amount = 1
            if self.item._id == "elona.gold_piede" then
               amount = self.item.amount
            end

            self.item.always_drop = false

            if chara:is_inventory_full() then
               Gui.mes("action.pick_up.your_inventory_is_full")
            end

            if self.item:is_equipped() then
               assert(Chara.is_alive(owner))
               assert(owner:unequip_item(self.item))
               owner:refresh()
            end

            local sep = self.item:separate(amount)
            sep:remove_ownership()
            sep.is_stolen = true
            sep.own_state = Enum.OwnState.None

            Gui.mes("activity.steal.succeed", sep:build_name())

            if sep._id == "elona.gold_piece" then
               Gui.play_sound("base.getgold1", chara.x, chara.y)
               chara.gold = chara.gold + 1
            else
               assert(chara:take_item(sep))
               Gui.play_sound(Rand.choice({"base.get1", "base.get2"}), chara.x, chara.y)
            end
            chara:refresh_weight()

            Skill.gain_skill_exp(chara, "elona.pickpocket", math.clamp(sep:calc("weight")/25, 0, 450) + 50)

            if chara.karma >= Const.KARMA_BAD and Rand.one_in(3) then
               Gui.mes("activity.steal.guilt")
               Effect.modify_karma(chara, -1)
            end
            -- <<<<<<<< shade2/proc.hsp:606 		} ..
         end
      }
   }
}
