local Pos = require("api.Pos")
local Enum = require("api.Enum")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local Rand = require("api.Rand")

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
         Gui.mes_visible("magic.gravity", chara)
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
   _id = "gravity",
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

data:add {
   _id = "spell_web",
   _type = "base.skill",
   elona_id = 436,

   type = "spell",
   effect_id = "elona.web",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = RANGE_BOLT,
   difficulty = 150,
   target_type = "location"
}
data:add {
   _id = "web",
   _type = "elona_sys.magic",
   elona_id = 436,

   params = {
      "source",
   },

   cast = function(self, params)
      local source = params.source

      error("TODO")

      return true
   end
}
