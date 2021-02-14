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

Event.register("elona.on_dig_success", "Create item", function(map, params)
   if map:calc("cannot_mine_items") then
      return
   end

   local x = params.dig_x
   local y = params.dig_y
   local chara = params.chara

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
      local params = Calc.filter(map:calc("level"), 2, nil, map)
      params.categories = { "elona.ore" }

      Itemgen.create(x, y, params, map)
   end
end)

local function do_dig_success(chara, x, y)
   local map = chara:current_map()
   local tile = MapTileset.get("elona.mapgen_tunnel", map)
   map:set_tile(x, y, tile)
   Map.spill_fragments(x, y, 2, map)
   Gui.play_sound("base.crush1")
   local anim = Anim.breaking(x, y)
   Gui.start_draw_callback(anim)

   -- TODO hidden path

   Gui.mes("activity.dig_mining.finish.wall")

   map:emit("elona.on_dig_success", {chara=chara, dig_x=x, dig_y=y})

   Skill.gain_skill_exp(chara, "elona.mining", 100)
end

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
         Gui.mes("common.too_exhausted")
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
   params = { food = "table", no_message = "boolean" },
   default_turns = 8,

   animation_wait = 100,

   on_interrupt = "prompt",

   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            -- TODO error handling
            local chara = params.chara
            if chara:is_in_fov() then
               Gui.play_sound("base.eat1")
               if self.food.own_state == Enum.OwnState.NotOwned and chara:is_ally() then
                  Gui.mes("activity.eat.start.in_secret", chara, self.food)
               else
                  Gui.mes("activity.eat.start.normal", chara, self.food)
               end
            end

            self.food.chara_using = chara
            self.food:emit("elona.on_eat_item_begin", {chara=chara})
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            if not Item.is_alive(self.food) then
               params.chara:remove_activity()
               return "turn_end"
            end

            -- TODO cargo check

            self.food.chara_using = params.chara

            return "turn_end"
         end
      },
      {
         id = "base.on_activity_cleanup",
         name = "start",

         callback = function(self)
            if not Item.is_alive(self.food) then
               return
            end
            self.food.chara_using = nil
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            local chara = params.chara
            if not self.no_message then
               if chara:is_in_fov() then
                  Gui.mes("activity.eat.finish", chara, self.food)
               end
            end

            Effect.eat_food(chara, self.food)
         end
      }
   }
}
data:add {
   _type = "base.activity",
   _id = "fishing",

   params = {},
   default_turns = 100,

   animation_wait = 40,

   on_interrupt = "stop",
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
data:add {
   _type = "base.activity",
   _id = "dig_wall",

   params = { x = "number", y = "number", chara = "IChara" },
   default_turns = 40,

   animation_wait = 15,

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

   params = { bed = "table" },
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

            if save.elona_sys.awake_hours >= 30 then
               local do_sleep = false
               if save.elona_sys.awake_hours >= 50 then
                  do_sleep = true
               elseif Rand.one_in(2) then
                  do_sleep = true
               end
               if do_sleep then
                  Gui.mes("activity.rest.drop_off_to_sleep")
                  ElonaCommand.do_sleep(chara, self.bed)
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

   params = { bed = "table" },
   default_turns = 20,

   animation_wait = 5,

   on_interrupt = "stop",
   events = {
      {
         id = "base.on_activity_start",
         name = "start",

         callback = function(self, params)
            Gui.mes("start resting")
            -- TODO
            local is_town_or_guild = false
            if is_town_or_guild then
               Gui.mes("sleep start other")
               self.turns = 5
            else
               Gui.mes("sleep start global")
               self.turns = 20
            end
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            return "turn_end"
         end
      },
      {
         id = "base.on_activity_finish",
         name = "finish",

         callback = function(self, params)
            Gui.mes("finish preparations")
            ElonaCommand.do_sleep(params.chara, self.bed)
         end
      }
   }
}
data:add {
   _type = "base.activity",
   _id = "sex",

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
               Gui.mes("activity.sex.take_clothes_off", params.chara.x, params.chara.y, params.chara)
               self.partner:start_activity("elona.sex", {partner=params.chara}, self.turns * 2)
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

            Gui.mes_c_visible("activity.sex.after_dialog", params.chara.x, params.chara.y)

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

   if instrument:find_enchantment("elona.strad") then
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

   if instrument:find_enchantment("elona.gould") and Rand.one_in(15) then
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
   _id = "performer",

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
            Gui.mes_visible("activity.perform.start", params.chara.x, params.chara.y, params.chara, self.instrument)
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
               Calc.make_sound(chara.x, chara.y, 5, 1, 1, chara)

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

data:add {
   _type = "base.activity",
   _id = "stealing",

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
            Gui.mes("action.look.target", self.item)
            -- <<<<<<<< shade2/proc.hsp:445 			} ..
         end
      },
      {
         id = "base.on_activity_pass_turns",
         name = "pass turns",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:513 		if gRowAct=rowActSteal{ ..
            local chara = params.chara

            local result = self.item:emit("elona.on_steal_attempt", params)
            if result then
               return result
            end

            local from_enemy = false
            local owner = self.item:current_owner()
            if owner and owner:relation_towards(chara) <= Enum.Relation.Enemy then
               from_enemy = true
            end

            local chance = chara:skill_level("elona.pickpocket") * 5 + chara:skill_level("elona.stat_dexterity") + 25

            local hour = World.date().hour
            if hour >= 19 or hour < 7 then
               chance = chance * 15 / 10
            end
            if self.item:calc("quality") == 3 then
               chance = chance * 8 / 10
            end
            if self.item:calc("quality") >= 4 then
               chance = chance * 5 / 10
            end

            Calc.make_sound(chara.x, chara.y, 5, 8)

            local found = false

            for _, other in chara:current_map():iter_charas() do
               local dist = Pos.dist(other.x, other.y, chara.x, chara.y)
               local do_apply = Chara.is_alive(other)
                  and not chara:has_effect("elona.sleep")
                  and dist <= 5

               if owner then
                  do_apply = do_apply and owner.uid == other.uid
               end

               if do_apply then
                  local coef = 80 + dist * 20
                  if other:is_in_fov() then
                     coef = coef + 50
                  end
                  local p = Rand.rnd(chance + 1) * (coef / 100)

                  -- TODO adventurer

                  if Rand.rnd(other:skill_level("elona.stat_perception") + 1) > p then
                     if other:is_in_fov() then
                        Gui.mes("steal notice in fov")
                     else
                        Gui.mes("steal notice out of fov")
                     end

                     -- TODO guard
                     -- TODO modify_impression

                     found = true
                  end
               end
            end

            local succeeded = true

            if found then
               succeeded = false

               Gui.mes("you are found")
               -- TODO modify_karma
               if owner then
                  -- TODO ebon
                  if not owner:has_effect("elona.sleep") then
                     -- TODO relationship = -2
                     chara:act_hostile_towards(owner)
                     -- TODO modify_impression
                  end
               end

               Calc.make_guards_hostile()
            end

            if owner then
               if not Chara.is_alive(owner) then
                  if succeeded then
                     Gui.mes("target is dead")
                     succeeded = false
                  end
               end

               -- TODO character role

               if Pos.dist(chara.x, chara.y, owner.x, owner.y) >= 3 then
                  if succeeded then
                     Gui.mes("target is lost")
                     succeeded = false -- NOTE: was true in vanilla?
                  end
               end
            end

            if not Item.is_alive(self.item) then
               succeeded = false
            end
            if self.item:calc("is_precious") then
               if succeeded then
                  Gui.mes("cannot be stolen")
                  succeeded = false
               end
            end
            if self.item:calc("weight") >= chara:skill_level("elona.stat_strength") * 500 then
               if succeeded then
                  Gui.mes("too heavy")
                  succeeded = false
               end
            end
            if Chara.is_alive(self.item.chara_using) then
               if succeeded then
                  Gui.mes("someone else is using")
                  succeeded = false
               end
            else
               self.item.chara_using = nil
            end

            if not succeeded then
               Gui.mes("you stop stealing")
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
               Gui.mes("you stop stealing")
               chara:remove_activity()
               return
            end

            Gui.mes("steal")
            -- TODO
            -- <<<<<<<< shade2/proc.hsp:606 		} ..
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
      local choices = nil -- TODO
      local id, txt_type
      local amount = 1
      if site_data.on_search then
         id, txt_type = site_data:on_search({chara=chara,feat=feat,material_level=level,material_choices=choices})
      else
         id, txt_type = Material.random_material_id(level, 0, choices), nil
      end

      if id then
         Material.obtain(chara, id, amount, txt_type)
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

   params = { feat = "table", type = "string" },
   default_turns = 20,

   animation_wait = 15,

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

   params = {},
   default_turns = 0,

   animation_wait = 15,

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
   _id = "read_spellbook",

   params = { skill_id = "string", spellbook = "table", },
   default_turns = 10,

   animation_wait = 25,

   on_interrupt = "prompt",
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
   _id = "read_ancient_book",

   params = { ancient_book = "table", },
   default_turns = 10,

   animation_wait = 25,

   on_interrupt = "prompt",
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

   on_interrupt = "prompt",
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
