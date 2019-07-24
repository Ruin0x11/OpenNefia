local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Rand = require("api.Rand")

--
--
-- damage_hp events
--
--

local function retreat_in_fear(chara, params)
   if chara:calc("hp") < chara:calc("max_hp") / 5 then

      if chara:is_player() or chara:has_effect("elona.fear") then
         return
      end

      if chara:is_immune_to_effect("elona.fear") then
         return
      end

      local retreats = params.damage * 100 / chara:calc("max_hp") + 10 > Rand.rnd(200)

      if params.attacker and params.attacker:is_player() and false then
         retreats = false
      end

      if retreats then
         assert(chara:set_effect_turns("elona.fear", Rand.rnd(20) + 5))
         Gui.mes_visible(chara.uid .. " runs away in fear. ", chara.x, chara.y, "Blue")
      end
   end
end

Event.register("base.on_damage_chara",
               "Retreat in fear", retreat_in_fear)

local function disturb_sleep(chara, params)
   if not params.element or not params.element.preserves_sleep then
      if chara:has_effect("elona.sleep") then
         chara:remove_effect("elona.sleep")
         Gui.mes("sleep is disturbed " .. chara.uid)
      end
   end
end

Event.register("base.on_damage_chara",
               "Disturb sleep", disturb_sleep)

local function splits(chara, params)
   if chara:calc("splits") then
      if params.damage > chara:calc("max_hp") / 20 or Rand.one_in(10) then
         if not Map.is_world_map() then
            if chara:clone() then
               Gui.mes(chara.uid .. " splits.")
            end
         end
      end
   end
end

Event.register("base.on_damage_chara",
               "Split behavior", splits)

local split2_effects = {
   "elona.confusion",
   "elona.dimming",
   "elona.poison",
   "elona.paralysis",
   "elona.blindness",
}

local function splits2(chara, params)
   if chara:calc("splits2") then
      if Rand.one_in(3) then
         if not fun.iter(split2_effects)
            :any(function(e) return chara:has_effect(e) end)
         then
            if not Map.is_world_map() then
               if chara:clone() then
                  Gui.mes(chara.uid .. " splits.")
               end
            end
         end
      end
   end
end

Event.register("base.on_damage_chara",
               "Split behavior (2)", splits2)

local function is_quick_tempered(chara, params)
   if chara:calc("is_quick_tempered") then
      if not chara:has_effect("elona.fury") then
         if Rand.one_in(20) then
            Gui.mes_visible(chara.uid .. " engulfed in fury", chara.x, chara.y, "Blue")
            chara:set_effect_turns("elona.fury", Rand.rnd(30) + 15)
         end
      end
   end
end

Event.register("base.on_damage_chara",
               "Quick tempered", is_quick_tempered)
