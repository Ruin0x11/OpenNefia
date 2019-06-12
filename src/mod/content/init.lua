data:add {
   _type = "base.chara",
   _id = "player",

   name = "player",
   image = 4,
   max_hp = 50,
   max_mp = 10
}

data:add {
   _type = "base.chara",
   _id = "ally",

   name = "ally",
   image = 10,
   max_hp = 100,
   max_mp = 20
}

data:add {
   _type = "base.chara",
   _id = "enemy",

   name = "enemy",
   image = 50,
   max_hp = 10,
   max_mp = 2
}

data:add {
   _type = "base.map_tile",
   _id = "floor",

   image = "graphic/temp/map_tile/1_221.png",
   is_solid = false,
   is_opaque = false
}

data:add {
   _type = "base.map_tile",
   _id = "wall",

   image = "graphic/temp/map_tile/1_399.png",
   is_solid = true,
   is_opaque = true
}

local function prevent_turn(threshold)
   threshold = threshold or 1
   return function(p)
      if p.turns < threshold then
         return
      end

      local Chara = require("api.Chara")
      local Gui = require("api.Gui")

      if Chara.is_player(p.chara) then
         if p.status_ailment._type == "base.choked" then
            Gui.wait(9 * 30)
         else
            Gui.wait(3 * 30)
         end
         Gui.update_screen()
      end

      return { turn_result = "turn_end" }
   end
end

local Event = require("api.Event")

local ElonaAi = require("mod.elona_ai.api.ElonaAi")
local Ai = require("api.Ai")
ElonaAi.install()
Ai.set_default_module(ElonaAi)

local StatusEffect = require("mod.status_effects.api.StatusEffect")
StatusEffect.install()

data:add_multi(
   "base.status_effect",
   {
      _id = "blindness",

      related_element = "base.darkness",
      before_apply = nil,
      power_reduction_factor = 6,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.blindness", 1)
         if StatusEffect.get_turns(p.chara, "base.blindness" > 1) then
            -- emotion icon
         end
      end,
      elona_ai_handler = function(p)
         local Rand = require("api.Rand")
         if Rand.percent_chance(70) then
            return { action = ElonaAi.do_idle_action(p.ai, p.chara, p.target) }
         end
      end,
      elona_ai_priority = 7000,
      ui_indicator = { text = "Blind", color = {100, 100, 0} },
   },
   {
      _id = "confusion",

      related_element = "base.mind",
      before_apply = nil,
      power_reduction_factor = 7,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.confusion", 1)
         if StatusEffect.get_turns(p.chara, "base.confusion" > 1) then
            -- emotion icon
         end
      end,
      elona_ai_handler = function(p)
         local Rand = require("api.Rand")
         if Rand.percent_chance(60) then
            return { action = ElonaAi.do_idle_action(p.ai, p.chara, p.target) }
         end
      end,
      elona_ai_priority = 8000,
      ui_indicator = { text = "Confused", color = {100, 0, 100} },
   },
   {
      _id = "paralysis",

      related_element = "base.darkness",
      before_apply = nil,
      power_reduction_factor = 6,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_begin = prevent_turn(),
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.paralysis", 1)

         return {
            regeneration = false
         }
      end,
      emotion_icon = "base.paralysis",
      ui_indicator = { text = "Paralyzed", color = {0, 100, 100} },
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
         local constitution = 100
         -- TODO: acts as damage source (self?)
         Chara.damage_hp(p.chara, Rand.rnd(2 + math.floor(constitution / 10)), { kind = -4 })
         StatusEffect.heal(p.chara, "base.poison", 1)
         if StatusEffect.get_turns(p.chara, "base.poison") > 1 then
            -- emotion icon
         end

         return {
            regeneration = false
         }
      end
   },
   {
      _id = "choked",

      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_begin = prevent_turn(),
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")
         local Map = require("api.Map")
         local Gui = require("api.Gui")
         if p.turns % 3 == 0 then
            if Map.is_in_fov(p.chara.x, p.chara.y) then
               Gui.mes(p.chara.uid .. ": Being choked.")
            end
         end
         StatusEffect.apply(p.chara, "base.choked", 1)
         if StatusEffect.get_turns(p.chara, "base.choked") > 15 then
            Chara.damage_hp(p.chara, 500, { kind = -21 })
         end

         return {
            regeneration = false
         }
      end,
      ui_indicator = { text = "Choked", color = {0, 100, 100} },
   },
   {
      _id = "sleep",

      related_element = "base.nerve",
      before_apply = nil,
      power_reduction_factor = 4,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_begin = prevent_turn(),
      on_turn_end = function(p)
         local Chara = require("api.Chara")
         StatusEffect.heal(p.chara, "base.sleep", 1)
         if StatusEffect.get_turns(p.chara, "base.sleep") > 1 then
            -- emotion icon
         end
         Chara.heal_hp(p.chara, 1)
         Chara.heal_mp(p.chara, 1)
      end
   },
   {
      _id = "gravity",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.gravity", 1)
      end,
      ui_indicator = { text = "Gravity", color = {0, 80, 80} },
   },
   {
      _id = "furious",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.furious", 1)
      end,
   },
   {
      _id = "fear",

      related_element = "base.mind",
      before_apply = nil,
      power_reduction_factor = 7,
      additive_power = 0,
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.fear", 1)
      end,
      elona_ai_handler = function(p)
         local Chara = require("api.Chara")
         if not (Chara.is_ally(p.chara) and Chara.is_player(p.target)) then
            return { action = ElonaAi.do_noncombat_action(p.ai, p.chara, p.target, true) }
         end
      end,
      elona_ai_priority = 11000,
      ui_indicator = { text = "Fear", color = {100, 0, 100} },
   },
   {
      _id = "dimming",

      related_element = "base.sound",
      before_apply = nil,
      power_reduction_factor = 8,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_begin = prevent_turn(60),
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.dimming", 1)
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
         local Chara = require("api.Chara")
         local Rand = require("api.Rand")

         Chara.damage_hp(p.chara, Rand.rnd(math.floor(p.chara.hp * (1 + p.turns / 4) / 100 + 3) + 1), { kind = -13 })
         StatusEffect.heal(p.chara, "base.bleeding", 1)
         return {
            regeneration = false
         }
      end,
   },
   {
      _id = "wetness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = nil,
      additive_power = nil,
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.wetness", 1)
      end,
      ui_indicator = { text = "Wet", color = {0, 0, 160} },
   },
   {
      _id = "drunkeness",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 10,
      additive_power = function(p) return p.turns end,
      on_turn_begin = function(p)
         local Gui = require("Gui")
         Gui.mes("*hic* ")
      end,
      on_turn_end = function(p)
         StatusEffect.heal(p.chara, "base.drunkenness", 1)
         -- emotion icon
      end,
      ui_indicator = { text = "Drunk", color = {100, 0, 100} },
   },
   {
      _id = "insanity",

      related_element = nil,
      before_apply = nil,
      power_reduction_factor = 8,
      additive_power = function(p) return p.turns / 3 + 1 end,
      on_turn_end = function(p)
         local Gui = require("api.Gui")
         local Rand = require("api.Rand")
         local Map = require("api.Map")
         if Map.is_in_fov(p.chara.x, p.chara.y) then
            if Rand.one_in(3) then
               Gui.txt("Insane.")
            end
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.chara, "base.confusion", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.chara, "base.dimming", Rand.rnd(10))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.chara, "base.sleep", Rand.rnd(5))
         end
         if Rand.one_in(5) then
            StatusEffect.apply(p.chara, "base.fear", Rand.rnd(10))
         end
         StatusEffect.heal(p.chara, "base.insanity", 1)
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
         local Rand = require("api.Rand")
         local Chara = require("api.Chara")
         local result = {}
         if Rand.one_in(80) then
            -- local random_stat = ...
            -- Chara.debuff()
         end
         if Rand.one_in(5) then
            result.regeneration = false
         end
         if not Chara.is_ally(p.chara) then
            -- if p.chara.quality >= "miracle"
            if Rand.one_in(200) then
               StatusEffect.heal(p.chara, "base.sickness")
            end
         end
         return result
      end
   }
)

local EmotionIcon = require("mod.emotion_icons.api.EmotionIcon")

data:add {
   _type = "base.emotion_icon",
   _id = "paralysis",

   image = "mod/content/graphic/paralysis.bmp"
}

EmotionIcon.install("base.default")


local DamagePopup = require("mod.damage_popups.api.DamagePopup")

DamagePopup.install()

Event.register("base.after_damage_hp",
"damage popups",
function(p)
   local Map = require("api.Map")
   if Map.is_in_fov(p.chara.x, p.chara.y) then
      DamagePopup.add(p.chara.x, p.chara.y, tostring(p.damage))
   end
end)

-- Event.register(
-- "base.before_ai_decide_action",
-- "nope",
-- function(params)
--    params.action = "turn_end"
--    return true
-- end)

-- TODO: if set, prevent hooks with 'name' being run:
--   params._blocked = { "other_hook" }

Event.register(
   "base.on_player_bumped_into_chara",
   "nande POISON nan dayo",
   function(params)
      if params.relation == "enemy" then
         local StatusEffect = require("mod.status_effects.api.StatusEffect")
         local EmotionIcon = require("mod.emotion_icons.api.EmotionIcon")
         StatusEffect.apply(params.on_cell, "base.poison", 100)
      end
end)

data:add {
   _type = "base.map_generator",
   _id = "test",

   generate = function(self, p)
      local InstancedMap = require("api.InstancedMap")
      local Map = require("api.Map")

      local width = p.width or 30
      local height = p.height or 50
      local map = InstancedMap:new(width, height)

      for y=0,width-1 do
         for x=0,height-1 do
            if x == 0 or y == 0 or x == width-1 or y == height-1 then
               map:set_tile(x, y, "base.wall")
            end
         end
      end

      map.player_start_pos = { x = math.floor(width / 2), y = math.floor(height / 2)}

      return map
   end
}
