local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Pos = require("api.Pos")
local Mef = require("api.Mef")
local Effect = require("mod.elona.api.Effect")

local function make_web(opts)
   local type = opts.type or "spell"
   local id = opts._id
   data:add {
      _id = type .. "_" .. id,
      _type = "base.skill",
      elona_id = opts.elona_id,

      type = type,
      effect_id = "elona." .. id,
      related_skill = "elona.stat_magic",
      cost = opts.cost,
      range = 0,
      difficulty = opts.difficulty,
      target_type = "location"
   }
   data:add {
      _id = id,
      _type = "elona_sys.magic",
      elona_id = opts.elona_id,

      params = {
         "source",
      },

      cast = function(self, params)
         local source = params.source
         local map = params.source:current_map()

         Gui.mes(opts.message)
         Gui.play_sound("base.web", params.x, params.y)

         local attempts = opts.attempts(params.power)
         local i = 0
         while i < attempts do
            local x = params.x + Rand.rnd(opts.spread) - Rand.rnd(opts.spread)
            local y = params.y + Rand.rnd(opts.spread) - Rand.rnd(opts.spread)

            local success = map:is_floor(x, y) and Pos.dist(params.x, params.y, x, y) < opts.spread
            if success then
               Mef.create(opts.mef_id, x, y, { duration = opts.mef_turns(params.power), power = opts.mef_power(params.power) })
               if opts.on_success then
                  opts.on_success(x, y, source)
               end
            else
               if Rand.one_in(2) then
                  attempts = attempts + 1
               end
            end
            i = i + 1
         end

         return true
      end
   }
end

make_web {
   _id = "web",
   elona_id = 436,

   cost = 10,
   difficulty = 150,

   message = "magic.map_effect.web",
   spread = 3,
   attempts = function(p) return 2 + Rand.rnd(p/50+1) end,
   mef_id = "elona.web",
   mef_turns = function(p) return -1 end,
   mef_power = function(p) return p*2 end,
}

make_web {
   _id = "mist_of_darkness",
   elona_id = 437,

   cost = 12,
   difficulty = 320,

   message = "magic.map_effect.fog",
   spread = 3,
   attempts = function(p) return 2 + Rand.rnd(p/50+1) end,
   mef_id = "elona.mist",
   mef_turns = function(p) return 8 + Rand.rnd(15+p/25) end,
   mef_power = function(p) return p end,
}


make_web {
   _id = "acid_ground",
   elona_id = 455,

   cost = 18,
   difficulty = 480,

   message = "magic.map_effect.acid",
   spread = 2,
   attempts = function(p) return 2 + Rand.rnd(p/50+1) end,
   mef_id = "elona.acid",
   mef_turns = function(p) return Rand.rnd(10) + 5 end,
   mef_power = function(p) return p end,
}

make_web {
   _id = "fire_wall",
   elona_id = 456,

   cost = 24,
   difficulty = 640,

   message = "magic.map_effect.fire",
   spread = 2,
   attempts = function(p) return 2 + Rand.rnd(p/50+1) end,
   mef_id = "elona.fire",
   mef_turns = function(p) return Rand.rnd(10) + 5 end,
   mef_power = function(p) return p end,
   on_success = function(x, y, chara) Effect.damage_map_fire(x, y, chara) end
}

make_web {
   _id = "ether_ground",
   elona_id = 634,

   type = "action",
   cost = 18,
   difficulty = 480,

   message = "magic.map_effect.ether_mist",
   spread = 2,
   attempts = function(p) return 1 + Rand.rnd(p/100+2) end,
   mef_id = "elona.ether",
   mef_turns = function(p) return Rand.rnd(4) + 2 end,
   mef_power = function(p) return p end,
}
