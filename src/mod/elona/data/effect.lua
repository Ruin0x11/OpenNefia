local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Skill = require("mod.elona_sys.api.Skill")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Const = require("api.Const")

local function indicator_nutrition(player)
   local nutrition_level = math.clamp(math.floor(player:calc("nutrition") / 1000), 0, 12)
   if 5 <= nutrition_level and nutrition_level <= 9 then
      return nil
   end

   return {
      text = ("effect.indicator.hunger._%d"):format(nutrition_level)
   }
end
data:add {
   _type = "base.ui_indicator",
   _id = "nutrition",

   ordering = 10000,
   indicator = indicator_nutrition
}

local function indicator_burden(player)
   -- >>>>>>>> shade2/screen.hsp:313 	if cBurden(pc)!0{ ...
   local burden = math.clamp(player:calc("inventory_weight_type"), Enum.Burden.None, Enum.Burden.Max)

   if burden > 0 then
      local color = {0, math.min(burden * 40, 255), math.min(burden * 40, 255)}
      return { text = ("effect.indicator.burden._%d"):format(burden), color = color }
   end

   return nil
   -- <<<<<<<< shade2/screen.hsp:316 		} ..
end
data:add {
   _type = "base.ui_indicator",
   _id = "burden",

   ordering = 190000,
   indicator = indicator_burden
}

local COLOR_FATIGUE_HEAVY = {120, 120, 0}
local COLOR_FATIGUE_MODERATE = {80, 80, 0}
local COLOR_FATIGUE_LIGHT = {60, 60, 0}

local function indicator_stamina(player)
   local stamina = player:calc("stamina")

   if stamina < Const.FATIGUE_THRESHOLD_HEAVY then
      return { text = "effect.indicator.tired._2", color = COLOR_FATIGUE_HEAVY }
   elseif stamina < Const.FATIGUE_THRESHOLD_MODERATE then
      return { text = "effect.indicator.tired._1", color = COLOR_FATIGUE_MODERATE }
   elseif stamina < Const.FATIGUE_THRESHOLD_LIGHT then
      return { text = "effect.indicator.tired._0", color = COLOR_FATIGUE_LIGHT }
   end

   return nil
end
data:add {
   _type = "base.ui_indicator",
   _id = "stamina",

   ordering = 180000,
   indicator = indicator_stamina
}

local COLOR_SLEEP_HEAVY = {255, 0, 0}
local COLOR_SLEEP_MODERATE = {100, 100, 0}
local COLOR_SLEEP_LIGHT = {0, 0, 0}

local function indicator_awake_hours()
   -- >>>>>>>> shade2/screen.hsp:306 	if gSleep>=sleepLight{ ...
   local hours = save.elona_sys.awake_hours

   if hours >= Const.SLEEP_THRESHOLD_HEAVY then
      return { text = "effect.indicator.sleepy._2", color = COLOR_SLEEP_HEAVY }
   elseif hours >= Const.SLEEP_THRESHOLD_MODERATE then
      return { text = "effect.indicator.sleepy._1", color = COLOR_SLEEP_MODERATE }
   elseif hours >= Const.SLEEP_THRESHOLD_LIGHT then
      return { text = "effect.indicator.sleepy._0", color = COLOR_SLEEP_LIGHT }
   end

   return nil
   -- <<<<<<<< shade2/screen.hsp:308 		} ..
end
data:add {
   _type = "base.ui_indicator",
   _id = "awake_hours",

   ordering = 170000,
   indicator = indicator_awake_hours
}

local effect = {
   {
      _id = "sick",

      ordering = 20000,
      color = {80, 120, 0},
      indicator = function(chara)
         local turns = chara:effect_turns("elona.sick")
         if turns >= Const.CON_SICK_HEAVY then
            return {
               text = "effect.elona.sick.indicator._1"
            }
         else
            return {
               text = "effect.elona.sick.indicator._0"
            }
         end
      end,

      -- >>>>>>>> shade2/proc.hsp:682 	healCon tc,conSick,7+rnd(7) ...
      on_sleep = function(chara)
         chara:heal_effect("elona.sick", 7 + Rand.rnd(7))
      end,
      auto_heal = false,
      -- <<<<<<<< shade2/proc.hsp:682 	healCon tc,conSick,7+rnd(7) ..

      on_turn_end = function(chara)
         -- >>>>>>>> elona122/shade2/calculation.hsp:1201:DONE 	if cSick(r1)>0{ ..
         local result

         if Rand.one_in(80) then
            local stat = Skill.random_attribute()
            if not Effect.has_sustain_enchantment(chara, stat) then
               local delta = -chara:base_skill_level(stat) / 25 + 1
               chara:add_stat_adjustment(stat, delta)
               chara:refresh()
            end
         end
         if Rand.one_in(5) then
            result = { regeneration = false }
         end
         if not chara:is_in_player_party() then
            if chara.quality >= Enum.Quality.Great then
               if Rand.one_in(200) then
                  chara:heal_effect("elona.sick")
               end
            end
         end

         return result
         -- <<<<<<<< elona122/shade2/calculation.hsp:1211 		} ..
      end,
   },
   {
      _id = "poison",

      ordering = 30000,
      color = { 0, 150, 0 },
      emotion_icon = "elona.skull",
      indicator = function(chara)
         local turns = chara:effect_turns("elona.poison")
         if turns >= Const.CON_POISON_HEAVY then
            return {
               text = "effect.elona.poison.indicator._1",
            }
         else
            return {
               text = "effect.elona.poison.indicator._0",
            }
         end
      end,

      stops_activity = true,

      -- >>>>>>>> shade2/proc.hsp:670 	cPoison(tc)	=0 ...
      on_sleep = "remove",
      -- <<<<<<<< shade2/proc.hsp:670 	cPoison(tc)	=0 ..

      on_turn_end = function(chara)
         -- >>>>>>>> shade2/calculation.hsp:1182 	if cPoison(r1)>0{ ...
         chara:set_emotion_icon("elona.skull")
         chara:damage_hp(Rand.rnd(2 + chara:skill_level("elona.stat_constitution") / 10), "elona.poison")
         return { regeneration = false }
         -- <<<<<<<< shade2/calculation.hsp:1186 	} ..
      end,
   },
   {
      _id = "sleep",

      ordering = 40000,
      color = {0, 50, 50},
      emotion_icon = "elona.sleep",
      indicator = function(chara)
         local turns = chara:effect_turns("elona.sleep")
         if turns >= Const.CON_SLEEP_HEAVY then
            return {
               text = "effect.elona.sleep.indicator._1"
            }
         else
            return {
               text = "effect.elona.sleep.indicator._0"
            }
         end
      end,

      stops_activity = true,

      -- >>>>>>>> shade2/proc.hsp:671 	cSleep(tc)	=0 ...
      on_sleep = "remove",
      -- <<<<<<<< shade2/proc.hsp:671 	cSleep(tc)	=0 ..

      on_turn_start = function(chara)
         local result = { blocked = true }
         if chara:is_player() then
            result.wait = 60
         end
         return result, "blocked"
      end,

      on_turn_end = function(chara)
         -- >>>>>>>> shade2/calculation.hsp:1176 	if cSleep(r1)>0{ ...
         chara:set_emotion_icon("elona.sleep")
         chara:heal_hp(1, true)
         chara:heal_mp(1, true)
         -- <<<<<<<< shade2/calculation.hsp:1180 		} ..
      end,
   },
   {
      _id = "blindness",
      ordering = 50000,
      color = {100, 100, 0},
      indicator = "effect.elona.blindness.indicator",
      emotion_icon = "elona.blind",

      stops_activity = true,

      -- >>>>>>>> shade2/proc.hsp:673 	cBlind(tc)	=0 ...
      on_sleep = "remove",
      -- <<<<<<<< shade2/proc.hsp:673 	cBlind(tc)	=0 ..

      on_add = function(chara)
         -- >>>>>>>> shade2/screen.hsp:1028 	if cBlind(pc)!0 : if (sx!cX(pc)) or (sy!cY(pc)):: ...
         chara:mod("fov", 2, "set")
         -- <<<<<<<< shade2/screen.hsp:1028 	if cBlind(pc)!0 : if (sx!cX(pc)) or (sy!cY(pc)):: ..
      end,

      on_turn_start = function(chara)
         -- >>>>>>>> shade2/screen.hsp:1028 	if cBlind(pc)!0 : if (sx!cX(pc)) or (sy!cY(pc)):: ...
         chara:mod("fov", 2, "set")
         -- <<<<<<<< shade2/screen.hsp:1028 	if cBlind(pc)!0 : if (sx!cX(pc)) or (sy!cY(pc)):: ..
      end,

      on_remove = function(chara)
         chara.temp["fov"] = nil
      end,

   },
   {
      _id = "paralysis",
      ordering = 60000,
      color = {0, 100, 100},
      indicator = "effect.elona.paralysis.indicator",
      emotion_icon = "elona.paralyze",

      on_turn_start = function(chara)
         local result = { blocked = true }
         if chara:is_player() then
            result.wait = 60
         end
         return result, "blocked"
      end,

      stops_activity = true,

      -- >>>>>>>> shade2/proc.hsp:674 	cParalyze(tc)	=0 ...
      on_sleep = "remove"
      -- <<<<<<<< shade2/proc.hsp:674 	cParalyze(tc)	=0 ..
   },
   {
      _id = "choking",
      ordering = 70000,
      color = {0, 100, 100},
      indicator = "effect.elona.choking.indicator",

      on_turn_start = function(chara)
         local result = { blocked = true }
         if chara:is_player() then
            result.wait = 180
         end
         return result, "blocked"
      end,

      auto_heal = false,

      on_turn_end = function(chara)
         if chara:effect_turns("elona.choking") % 3 == 0 then
            if chara:is_in_fov() then
               Gui.mes("misc.status_ailment.choked", chara)
            end
         end

         chara:add_effect_turns("elona.choking", 1)

         if chara:effect_turns("elona.choking") > 15 then
            chara:damage_hp(500, "elona.choking")
         end

         return { regeneration = false }
      end
   },
   {
      _id = "confusion",
      ordering = 80000,
      color = {100, 0, 100},
      indicator = "effect.elona.confusion.indicator",
      emotion_icon = "elona.confuse",

      stops_activity = true,

      -- >>>>>>>> shade2/proc.hsp:672 	cConfuse(tc)	=0 ...
      on_sleep = "remove"
      -- <<<<<<<< shade2/proc.hsp:672 	cConfuse(tc)	=0 ..
   },
   {
      _id = "fear",
      ordering = 90000,
      color = {100, 0, 100},
      indicator = "effect.elona.fear.indicator",
      emotion_icon = "elona.fear"
   },
   {
      _id = "dimming",
      ordering = 100000,
      color = {0, 100, 100},
      emotion_icon = "elona.dim",

      indicator = function(chara)
         local turns = chara:effect_turns("elona.dimming")
         if turns >= Const.CON_DIM_HEAVY then
            return {
               text = "effect.elona.dimming.indicator._2"
            }
         elseif turns >= Const.CON_DIM_MODERATE then
            return {
               text = "effect.elona.dimming.indicator._1"
            }
         else
            return {
               text = "effect.elona.dimming.indicator._0"
            }
         end
      end,

      on_turn_start = function(chara)
         -- >>>>>>>> shade2/main.hsp:784 	if (cMochi(cc)>0)or(cSleep(cc)>0)or(cParalyze(cc) ...
         local result = { blocked = true }
         if chara:is_player() then
            result.wait = 60
         end
         if chara:effect_turns("elona.dimming") > 60 then
            return result, "blocked"
         end
         -- <<<<<<<< shade2/main.hsp:790 		} ..
      end,

      stops_activity = true,

      -- >>>>>>>> shade2/proc.hsp:674 	cParalyze(tc)	=0 ...
      on_sleep = "remove"
      -- <<<<<<<< shade2/proc.hsp:674 	cParalyze(tc)	=0 ..
   },
   {
      _id = "fury",
      ordering = 110000,
      color = {150, 0, 0},
      indicator = function(chara)
         local turns = chara:effect_turns("elona.fury")
         if turns >= Const.CON_ANGRY_HEAVY then
            return {
               text = "effect.elona.fury.indicator._1"
            }
         else
            return {
               text = "effect.elona.fury.indicator._0"
            }
         end
      end,
   },
   {
      _id = "bleeding",
      ordering = 120000,
      color = {150, 0, 0},
      emotion_icon = "elona.bleed",
      indicator = function(chara)
         local turns = chara:effect_turns("elona.bleeding")
         if turns >= Const.CON_BLEED_HEAVY then
            return {
               text = "effect.elona.bleeding.indicator._2"
            }
         elseif turns >= Const.CON_BLEED_MODERATE then
            return {
               text = "effect.elona.bleeding.indicator._1"
            }
         else
            return {
               text = "effect.elona.bleeding.indicator._0"
            }
         end
      end,

      stops_activity = true,

      -- >>>>>>>> shade2/proc.hsp:677 	cBleed(tc)	=0 ...
      on_sleep = "remove",
      -- <<<<<<<< shade2/proc.hsp:677 	cBleed(tc)	=0 ..

      on_turn_end = function(chara)
         local turns = chara:effect_turns("elona.bleeding")
         chara:damage_hp(Rand.rnd(chara.hp * (1 + turns / 4) / 100 + 3) + 1, "elona.bleeding")
         if chara:calc("cures_bleeding_quickly") then
            chara:heal_effect("elona.bleeding", 3)
         end

         return { regeneration = false }
      end,
   },
   {
      _id = "insanity",
      ordering = 130000,
      color = {150, 100, 0},
      emotion_icon = "elona.insane",
      indicator = function(chara)
         local turns = chara:effect_turns("elona.bleeding")
         if turns >= Const.CON_INSANE_HEAVY then
            return {
               text = "effect.elona.insanity.indicator._2"
            }
         elseif turns >= Const.CON_INSANE_MODERATE then
            return {
               text = "effect.elona.insanity.indicator._1"
            }
         else
            return {
               text = "effect.elona.insanity.indicator._0"
            }
         end
      end,

      stops_activity = true,

      on_turn_end = function(chara)
         -- >>>>>>>> shade2/calculation.hsp:1253 		if sync(r1) : if rnd(3)=0{ ...
         if Rand.one_in(3) then
            if chara:is_in_fov() then
               Gui.mes("misc.status_ailment.insane", chara)
            end
         end
         if Rand.one_in(5) then
            chara:add_effect_turns("elona.confusion", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            chara:add_effect_turns("elona.dimming", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            chara:add_effect_turns("elona.sleep", Rand.rnd(5))
         end
         if Rand.one_in(5) then
            chara:add_effect_turns("elona.fear", Rand.rnd(10))
         end
         -- <<<<<<<< shade2/calculation.hsp:1272 		if rnd(5)=0:cFear(r1)+=rnd(10) ..
      end
   },
   {
      _id = "drunk",
      ordering = 140000,
      color = {100, 0, 100},
      indicator = "effect.elona.drunk.indicator",
      emotion_icon = "elona.happy",

      -- >>>>>>>> shade2/proc.hsp:676 	cDrunk(tc)	=0 ...
      on_sleep = "remove"
      -- <<<<<<<< shade2/proc.hsp:676 	cDrunk(tc)	=0 ..
   },
   {
      _id = "wet",
      ordering = 150000,
      color = {0, 0, 160},
      indicator = "effect.elona.wet.indicator",

      -- >>>>>>>> shade2/proc.hsp:669 	cWet(tc)	=0 ...
      on_sleep = "remove"
      -- <<<<<<<< shade2/proc.hsp:669 	cWet(tc)	=0 ..
   },
   {
      _id = "gravity",
      ordering = 160000,
      color = {0, 80, 80},
      indicator = "effect.elona.gravity.indicator"
   },
}

data:add_multi("base.effect", effect)
