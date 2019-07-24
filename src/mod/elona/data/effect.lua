local Chara = require("api.Chara")
local Effect = require("mod.elona_sys.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")

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

   indicator = indicator_stamina
}

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

   indicator = indicator_nutrition
}

local effect = {
   {
      _id = "sick",

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

      on_turn_end = function(chara)
         chara:damage_hp(Rand.rnd(2 + chara:skill_level("elona.stat_constitution") / 10), "elona.poison")
         return { regeneration = false }
      end
   },
   {
      _id = "sleep",

      on_turn_end = function(chara)
         chara:heal_hp(1)
         chara:heal_mp(1)
      end
   },
   {
      _id = "blindness",
   },
   {
      _id = "paralysis",
   },
   {
      _id = "choking",

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
   },
   {
      _id = "fear",
   },
   {
      _id = "dimming",
   },
   {
      _id = "fury",
   },
   {
      _id = "bleeding",

      on_turn_end = function(chara)
         local turns = chara:effect_turns("elona.bleeding")
         chara:damage_hp(Rand.rnd(chara:calc("hp") * (1 + turns / 4) / 100 + 3) + 1, "elona.bleeding")
         if chara:calc("cures_bleeding_quickly") then
            chara:heal_effect("elona.bleeding", 3)
         end

         return { regeneration = false }
      end
   },
   {
      _id = "insanity",

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
   },
   {
      _id = "wet",
   },
   {
      _id = "gravity",
   },
}

data:add_multi("elona_sys.effect", effect)
