local Pos = require("api.Pos")
local Enum = require("api.Enum")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")
local Item = require("api.Item")
local Anim = require("mod.elona_sys.api.Anim")

local RANGE_BOLT = 6
local RANGE_BALL = 2
local RANGE_BREATH = 5

data:add {
   _id = "return",
   _type = "elona_sys.magic",
   elona_id = 428,

   type = "skill",
   params = {
      "source"
   },

   related_skill = "elona.stat_perception",
   cost = 20,
   range = 10000,
   difficulty = 550,

   cast = function(self, params)
      local source = params.source
      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local s = save.elona
      if s.turns_until_cast_return ~= 0 then
         Gui.mes("magic.return.cancel")
         s.turns_until_cast_return = 0
      else
         local map_uid = Effect.query_return_location(source)

         if Effect.is_cursed(params.curse_state) and Rand.one_in(3) then
            Gui.mes("jail") -- TODO
         end

         if map_uid then
            s.return_destination_map_uid = map_uid
            s.turns_until_cast_return = 15 + Rand.rnd(15)
         end
      end

      return true
   end
}


data:add {
   _id = "spell_gravity",
   _type = "base.skill",
   elona_id = 466,

   type = "spell",
   effect_id = "elona.gravity",
   related_skill = "elona.stat_magic",
   cost = 24,
   range = RANGE_BALL,
   difficulty = 750,
   target_type = "self_or_nearby"
}
data:add {
   _id = "gravity",
   _type = "elona_sys.magic",
   elona_id = 466,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      local filter = function(chara)
         return chara ~= source
            and not chara:calc("is_immune_to_mines")
            and Pos.dist(source.x, source.y, chara.x, chara.y) <= params.range * 2
      end

      for _, chara in Chara.iter():filter(filter) do
         Gui.mes_visible("magic.gravity", chara.x, chara.y)
         chara:apply_effect("elona.gravity", 100 + Rand.rnd(100))
      end

      return true
   end
}

data:add {
   _id = "spell_dominate",
   _type = "base.skill",
   elona_id = 435,

   type = "spell",
   effect_id = "elona.dominate",
   related_skill = "elona.stat_charisma",
   cost = 125,
   range = RANGE_BOLT,
   difficulty = 2000,
   target_type = "enemy"
}
data:add {
   _id = "dominate",
   _type = "elona_sys.magic",
   elona_id = 435,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      if not source:is_player() or target:is_allied() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      -- TODO dominate restriction
      -- TODO item: monster heart

      local success = Rand.rnd(params.power / 15 + 5) < target:calc("level")

      if target:calc("quality") >= Enum.Quality.Great then
         Gui.mes("magic.domination.cannot_be_charmed")
      elseif success then
         target:recruit_as_ally()
      else
         Gui.mes("magic.common.resists")
      end

      return true
   end
}

local function do_curse(self, params)
   local source = params.source
   local target = params.target

   local chance = params.power / 2
   if Effect.is_cursed(params.curse_state) then
      chance = chance * 100
   end
   local resistance = 75 + target:skill_level("elona.stat_luck")
   -- TODO enchantment: resist curse
   if Rand.rnd(resistance) > chance then
      return true
   end

   if target:is_allied() then
      if target:has_trait("elona.res_curse") and Rand.one_in(3) then
         Gui.mes("magic.curse.no_effect")
         return true
      end
   end

   local filter = function(item)
      if not Item.is_alive(item) then
         return false
      end
      if item:calc("curse_state") == "blessed" and Rand.one_in(10) then
         return false
      end
      return true
   end

   local considering = target:iter_equipment():filter(filter):to_list()
   require("api.Log").info("%d %d", #considering, target:iter_equipment():length())

   if #considering == 0 then
      local items = target:iter_inventory():to_list()
      for _ = 1, 200 do
         local item = Rand.choice(items)
         if filter(item) then
            considering[#considering+1] = item
            break
         end
      end
   end

   if #considering == 0 then
      Gui.mes("common.nothing_happens")
      return true, { obvious = false }
   end

   local item = Rand.choice(considering)

   Gui.mes_visible("magic.curse.apply", target.x, target.y, target, item)
   if item.curse_state == "cursed" then
      item.curse_state = "doomed"
   else
      item.curse_state = "cursed"
   end
   target:refresh()
   Gui.play_sound("base.curse3")
   local cb = Anim.load("elona.anim_curse", target.x, target.y)
   Gui.start_draw_callback(cb)
   item:stack()

   return true
end

data:add {
   _id = "action_curse",
   _type = "base.skill",
   elona_id = 645,

   type = "action",
   effect_id = "elona.curse",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = 4,
   difficulty = 100,
   target_type = "enemy"
}
data:add {
   _id = "curse",
   _type = "elona_sys.magic",
   elona_id = 645,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      Gui.mes_visible("magic.curse.spell", params.target.x, params.target.y, params.source, params.target)

      return do_curse(self, params)
   end
}

data:add {
   _id = "effect_curse",
   _type = "elona_sys.magic",
   elona_id = 1114,

   params = {
      "source",
      "target"
   },

   cast = do_curse
}
