local Chara = require("api.Chara")
local Effect = require("mod.elona_sys.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")

local function indicator_nutrition(player)
   local nutrition = math.clamp(math.floor(player:calc("nutrition") / 1000), 0, 12)
   if 5 <= nutrition and nutrition <= 9 then
      return nil
   end

   return { text = "hunger " .. nutrition }
end
data:add {
   _type = "base.ui_indicator",
   _id = "nutrition",

   ordering = 10000,
   indicator = indicator_nutrition
}

local function indicator_stamina(player)
   local sp = player:calc("stamina")

   if sp < 25 then
      return { text = "tired" }
   elseif sp < 0 then
      return { text = "very tired" }
   end

   return nil
end
data:add {
   _type = "base.ui_indicator",
   _id = "stamina",

   ordering = 180000,
   indicator = indicator_stamina
}

local function indicator_awake_hours()
   local hours = save.elona_sys.awake_hours

   if hours >= 50 then
      return { text = "very sleepy" }
   elseif hours >= 30 then
      return { text = "sleepy" }
   end

   return nil
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

      on_turn_end = function(chara)
         local result

         if Rand.one_in(80) then
            -- decrement attribute adjust
         end
         if Rand.one_in(5) then
            result = { regeneration = false }
         end
         if not chara:is_in_party() then
            if chara.quality == "miracle" or chara.quality == "special" then
               if Rand.one_in(200) then
                  chara:heal_effect("elona.sick")
               end
            end
         end

         return result
      end
   },
   {
      _id = "poison",

      ordering = 30000,

      stops_activity = true,

      on_turn_end = function(chara)
         chara:damage_hp(Rand.rnd(2 + chara:skill_level("elona.stat_constitution") / 10), "elona.poison")
         return { regeneration = false }
      end
   },
   {
      _id = "sleep",

      ordering = 40000,

      stops_activity = true,

      on_turn_end = function(chara)
         chara:heal_hp(1)
         chara:heal_mp(1)
      end
   },
   {
      _id = "blindness",
      ordering = 50000,

      stops_activity = true,
   },
   {
      _id = "paralysis",
      ordering = 60000,

      stops_activity = true,
   },
   {
      _id = "choking",
      ordering = 70000,

      on_turn_end = function(chara)
         if chara:effect_turns("elona.choking") % 3 == 0 then
            Gui.mes_visible(chara.uid .. " is choked", chara.x, chara.y)
         end

         chara:add_effect_turns("elona.choking", 2)

         if chara:effect_turns("elona.choking") > 15 then
            chara:damage_hp(500, "elona.choking")
         end

         return { regeneration = false }
      end
   },
   {
      _id = "confusion",
      ordering = 80000,

      stops_activity = true,
   },
   {
      _id = "fear",
      ordering = 90000,
   },
   {
      _id = "dimming",
      ordering = 100000,

      stops_activity = true,
   },
   {
      _id = "fury",
      ordering = 110000,
   },
   {
      _id = "bleeding",
      ordering = 120000,

      stops_activity = true,

      on_turn_end = function(chara)
         local turns = chara:effect_turns("elona.bleeding")
         chara:damage_hp(Rand.rnd(chara.hp * (1 + turns / 4) / 100 + 3) + 1, "elona.bleeding")
         if chara:calc("cures_bleeding_quickly") then
            chara:heal_effect("elona.bleeding", 3)
         end

         return { regeneration = false }
      end
   },
   {
      _id = "insanity",
      ordering = 130000,

      stops_activity = true,

      on_turn_end = function(chara)
         if Rand.one_in(3) then
            Gui.mes_visible(chara.uid .. " is insane ", chara.x, chara.y)
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
      end
   },
   {
      _id = "drunkenness",
      ordering = 140000,
   },
   {
      _id = "wet",
      ordering = 150000,
   },
   {
      _id = "gravity",
      ordering = 160000,
   },
}

data:add_multi("base.effect", effect)
