data:add {
   _type = "base.chara",
   _id = "player",

   name = "player",
   image = 4,
   max_hp = 50,
   max_mp = 10
}

data:add {
   _type = "base.map_tile",
   _id = "floor",

   image = 451,
   is_solid = false
}

data:add {
   _type = "base.map_tile",
   _id = "wall",

   image = 300,
   is_solid = true
}

data:add_multi(
   "base.event",
   {
      _id = "before_ai_decide_action"
   },
   {
      _id = "after_apply_damage"
   },
   {
      _id = "on_calc_damage"
   },
   {
      _id = "after_damage_hp"
   },
   {
      _id = "on_player_bumped_into_nonhostile_chara"
   },
   {
      _id = "before_player_map_leave"
   },
   {
      _id = "on_player_bumped_into_object"
   },
   {
      _id = "on_chara_hostile_action"
   },
   {
      _id = "on_chara_killed"
   },
   {
      _id = "on_calc_kill_exp"
   },
   {
      _id = "on_turn_end"
   }
)

-- TODO: emotion icon as field
data:add_multi(
   "base.status_effect",
   {
      _id = "blindness",

      related_element = "base.darkness",
      before_apply = nil,
      power_reduction_factor = 6,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.blindness", 1)
         if StatusEffect.get_turns(p.victim, "base.blindness" > 1) then
            -- emotion icon
         end
      end,
      elona_ai_handler = function(p)
         local ElonaAi = require("api.ElonaAi")
         local Rand = require("api.Rand")
         if Rand.percent_chance(70) then
            return { action = ElonaAi.do_idle_action(p.ai, p.chara, p.target) }
         end
      end,
      elona_ai_priority = 7000
   },
   {
      _id = "confusion",

      related_element = "base.mind",
      before_apply = nil,
      power_reduction_factor = 7,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.confusion", 1)
         if StatusEffect.get_turns(p.victim, "base.confusion" > 1) then
            -- emotion icon
         end
      end,
      elona_ai_handler = function(p)
         local ElonaAi = require("api.ElonaAi")
         local Rand = require("api.Rand")
         if Rand.percent_chance(60) then
            return { action = ElonaAi.do_idle_action(p.ai, p.chara, p.target) }
         end
      end,
      elona_ai_priority = 8000
   },
   {
      _id = "paralysis",

      related_element = "base.darkness",
      before_apply = nil,
      power_reduction_factor = 6,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.paralysis", 1)
         if StatusEffect.get_turns(p.victim, "base.paralysis" > 1) then
            -- emotion icon
         end
         p.regeneration = false
      end
   },
   {
      _id = "poison",

      related_element = "base.poison",
      before_apply = nil,
      power_reduction_factor = 5,
      additive_power = function(p) return p.turns / 3 + 3 end,
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")
         local StatusEffect = require("api.StatusEffect")
         local constitution = 100
         -- TODO: acts as damage source (self?)
         Chara.damage_hp(p.victim, Rand.rnd(2 + math.floor(constitution / 10)), { kind = -4 })
         StatusEffect.heal(p.victim, "base.poison", 1)
         if StatusEffect.get_turns(p.victim, "base.poison") > 1 then
            -- emotion icon
         end

         p.regeneration = false
      end
   },
   {
      _id = "choked",

      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")
         local Map = require("api.Map")
         local Gui = require("api.Gui")
         local StatusEffect = require("api.StatusEffect")
         if p.turns % 3 == 0 then
            if Map.is_in_fov(p.victim.x, p.victim.y) then
               Gui.mes(p.victim.uid .. ": Being choked.")
            end
         end
         StatusEffect.apply(p.victim, "base.choked", 1)
         if StatusEffect.get_turns(p.victim, "base.choked") > 15 then
            Chara.damage_hp(p.victim, 500, { kind = -21 })
         end

         p.regeneration = false
      end
   },
   {
      _id = "sleep",

      related_element = "base.nerve",
      before_apply = nil,
      power_reduction_factor = 4,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.sleep", 1)
         if StatusEffect.get_turns(p.victim, "base.sleep") > 1 then
            -- emotion icon
         end
         Chara.heal_hp(p.victim, 1)
         Chara.heal_mp(p.victim, 1)
      end
   },
   {
      _id = "gravity",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.gravity", 1)
      end
   },
   {
      _id = "furious",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.furious", 1)
      end
   },
   {
      _id = "fear",

      related_element = "base.mind",
      before_apply = nil,
      power_reduction_factor = 7,
      additive_power = 0,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.fear", 1)
         -- emotion icon
      end,
      elona_ai_handler = function(p)
         local ElonaAi = require("api.ElonaAi")
         local Chara = require("api.Chara")
         if not (Chara.is_ally(p.chara) and Chara.is_player(p.target)) then
            return { action = ElonaAi.do_noncombat_action(p.ai, p.chara, p.target, true) }
         end
      end,
      elona_ai_priority = 11000
   },
   {
      _id = "dimming",

      related_element = "base.sound",
      before_apply = nil,
      power_reduction_factor = 8,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.dimming", 1)
         -- emotion icon
      end
   },
   {
      _id = "bleeding",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 25,
      additive_power = function(p) return p.turns end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")

         Chara.damage_hp(p.victim, Rand.rnd(math.floor(p.victim.hp * (1 + p.turns / 4) / 100 + 3) + 1), { kind = -13 })
         StatusEffect.heal(p.victim, "base.bleeding", 1)
         -- emotion icon
         p.regeneration = false
      end
   },
   {
      _id = "wetness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.wetness", 1)
      end
   },
   {
      _id = "drunkeness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 10,
      additive_power = function(p) return p.turns end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         StatusEffect.heal(p.victim, "base.drunkenness", 1)
         -- emotion icon
      end
   },
   {
      _id = "insanity",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 8,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         local Gui = require("api.Gui")
         local Rand = require("api.Rand")
         local Map = require("api.Map")
         if Map.is_in_fov(p.victim.x, p.victim.y) then
            if Rand.one_in(3) then
               Gui.txt("Insane.")
            end
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.confusion", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.dimming", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.sleep", Rand.rnd(5))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.victim, "base.fear", Rand.rnd(10))
         end
         StatusEffect.heal(p.victim, "base.insanity", 1)
         -- emotion icon
      end
   },
   {
      _id = "sickness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 10,
      additive_power = function(p) return p.turns / 10 + 1 end,
      on_turn_end = function(p)
         local StatusEffect = require("api.StatusEffect")
         local Rand = require("api.Rand")
         local Chara = require("api.Chara")
         if Rand.one_in(80) then
            -- local random_stat = ...
            -- Chara.debuff()
         end
         if Rand.one_in(5) then
            p.regeneration = false
         end
         if not Chara.is_ally(p.victim) then
            -- if p.victim.quality >= "miracle"
            if Rand.one_in(200) then
               StatusEffect.heal(p.victim, "base.sickness")
            end
         end
      end
   }
)

local ElonaAi = require("api.ElonaAi")
ElonaAi.install()

local EmotionIcon = require("mod.emotion_icons.api.EmotionIcon")

data:add {
   _type = "base.emotion_icon",
   _id = "paralysis",

   image = "mod/content/graphic/paralysis.bmp"
}

EmotionIcon.install("base.default")

local Event = require("api.Event")
-- Event.register(
-- "base.before_ai_decide_action",
-- "nope",
-- function(params)
--    params.action = "turn_end"
--    return true
-- end)

-- TODO: if set, prevent hooks with 'name' being run:
--   params.blocked = { "other_hook" }

Event.register(
"base.on_player_bumped_into_chara",
"nande POISON nan dayo",
function(params)
   local StatusEffect = require("api.StatusEffect")
   local EmotionIcon = require("mod.emotion_icons.api.EmotionIcon")
   StatusEffect.apply(params.on_cell, "base.fear", 100)
   EmotionIcon.set(params.on_cell, "base.paralysis")
   return true
end)
