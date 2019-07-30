local Event = require("api.Event")
local Gui = require("api.Gui")
local Rand = require("api.Rand")

local function modify_weight(chara, delta, force)
   local height = chara.height
   local min = height * height * 18 / 25000
   local max = height * height * 24 / 10000

   if chara.weight < min then
      chara.weight = min
      return
   end
   if delta > 0 and chara.weight > max and not force then
      return
   end

   chara.weight = math.floor(chara.weight * (100 + delta) / 100 + (delta > 0) and 1 - (delta < 0) and 1)

   if chara.weight < 1 then
      chara.weight = 1
   end
   if delta >= 3 then
      Gui.mes_visible(chara.uid .. " weight gain")
   elseif delta <= -3 then
      Gui.mes_visible(chara.uid .. " weight lose")
   end
end

local function decrease_nutrition(chara, params, result)
   if not chara:is_player() then
      return result -- TODO nil counts as no modifying result
   end

   local nutrition = chara:calc("nutrition")
   if nutrition < 2000 then
      if nutrition < 1000 then
         chara:damage_hp(Rand.rnd(2) + chara:calc("max_hp") / 50, "elona.hunger")
         if save.elona_sys.awake_hours % 10 == 0 then
            -- interrupt action
            if Rand.one_in(50) then
               modify_weight(chara, -1)
            end
         end
      end
      result.regeneration = false
   end

   return result
end

Event.register("base.on_chara_turn_end",
               "Decrease nutrition",
               decrease_nutrition)
