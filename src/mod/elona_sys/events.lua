local Event = require("api.Event")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Rand = require("api.Rand")

--
--
-- turn sequence events
--
--

-- local function proc_effects_turn_start(chara, params, result)
--    for effect_id, _ in pairs(chara.effects) do
--       local effect = data["base.effect"]:ensure(effect_id)
--       if effect.on_turn_start then
--          result = effect.on_turn_start(chara, params, result) or result
--       end
--    end
--    return result
-- end
--
-- Event.register("base.on_turn_start", "Proc effect on_turn_start", proc_effects_turn_start)

local function proc_effects_turn_end(chara, params, result)
   for effect_id, _ in pairs(chara.effects) do
      local effect = data["base.effect"]:ensure(effect_id)
      if effect.on_turn_end then
         result = effect.on_turn_end(chara, params, result) or result
      end
   end
   for effect_id, _ in pairs(chara.effects) do
      chara:add_effect_turns(effect_id, -1)
   end
   return result
end

Event.register("base.on_chara_turn_end", "Proc effect on_turn_end", proc_effects_turn_end)

local function update_awake_hours()
   local s = save.elona_sys
   local map = Map.current()
   if map:calc("is_world_map") then
      if Rand.one_in(3) then
         s.awake_hours = s.awake_hours + 1
      end
      if Rand.one_in(15) then
         Gui.mes("move global map awake hours")
         s.awake_hours = math.max(0, s.awake_hours - 3)
      end
   end
   if map:calc("adds_awake_hours") then
      s.awake_hours = s.awake_hours + 1
   end
end

Event.register("base.on_hour_passed", "Update awake hours", update_awake_hours)

local function init_save()
   local s = save.elona_sys
   s.awake_hours = 0
end

Event.register("base.on_init_save", "Init save", init_save)

local function init_map(map)
   local fallbacks = {
      adds_awake_hours = true
   }
   map:mod_base_with(fallbacks, "merge")
end

Event.register("base.on_build_map", "Init map", init_map)

local function show_element_text_damage()
end

local function show_damage_text(chara, weapon, target, damage_level, was_killed, tense, element, extra_attacks)
   if not Map.is_in_fov(target.x, target.y) then
      return
   end

   if extra_attacks > 0 then
      Gui.mes("Furthermore, ")
      Gui.mes_continue_sentence()
   end

   local source = chara

   if tense == "ally" and chara then
      if weapon then
         Gui.mes(chara.uid .. " attacks " .. target.uid .. " with " .. weapon:build_name() .. " and ")
      else
         Gui.mes(chara.uid .. " attacks " .. target.uid .. " unarmed and ")
      end

      Gui.mes_continue_sentence()

      if was_killed then
         Gui.mes("kills it. ")
      else
         if element then
            show_element_text_damage(target, source, target, element)
         else
            if damage_level == -1 then
               Gui.mes("scratches it. ")
            elseif damage_level == 0 then
               Gui.mes("slightly wounds it. ")
            elseif damage_level == 1 then
               Gui.mes("moderately wounds it. ")
            elseif damage_level == 2 then
               Gui.mes("severely wounds it. ")
            elseif damage_level >= 3 then
               Gui.mes("critically wounds it. ")
            end
         end
      end
   else
      if tense == "enemy" and chara then
         if weapon then
            Gui.mes(chara.uid .. " attacks with " .. weapon:build_name() .. ". ")
         else
            Gui.mes(chara.uid .. " attacks unarmed. ")
         end
      end

      if was_killed then
         Gui.mes(target.uid .. " was killed. ")
      else
         if element then
            show_element_text_damage(target, source, target, element)
         else
            if damage_level == -1 then
               Gui.mes(target.uid .. " is scratched. ")
            elseif damage_level == 0 then
               Gui.mes(target.uid .. " is slightly wounded. ", "Orange")
            elseif damage_level == 1 then
               Gui.mes(target.uid .. " is moderately wounded. ", "Gold")
            elseif damage_level == 2 then
               Gui.mes(target.uid .. " is severely wounded. ", "LightRed")
            elseif damage_level >= 3 then
               Gui.mes(target.uid .. " is critically wounded. ", "Red")
            end
         end

         if damage_level == 1 then
            Gui.mes(target.uid .. " screams. ")
         elseif damage_level == 2 then
            Gui.mes(target.uid .. " writhes in pain. ")
         elseif damage_level >= 3 then
            Gui.mes(target.uid .. " is severely hurt! ")
         elseif damage_level == -2 then
            Gui.mes(target.uid .. " is healed. ")
         end
      end
   end
end
local function get_damage_level(base_damage, damage, chara)
   local damage_level
   if base_damage < 0 then
      damage_level = -2
   elseif damage <= 0 then
      damage_level = -1
   else
      damage_level = math.floor(damage * 6 / chara:calc("max_hp"))
   end
   return damage_level
end
Event.register("base.on_damage_chara", "Damage text", function(chara, params)
                  local damage_level = get_damage_level(params.base_damage, params.damage, chara)
                  show_damage_text(params.attacker, params.weapon, chara, damage_level, false, params.message_tense, params.element, params.extra_attacks)

                  -- If an event causes character death, switch to
                  -- passive tense or messages like "kills it. kills
                  -- it. " will print.
                  params.message_tense = "passive"
end)
Event.register("base.on_kill_chara", "Damage text", function(chara, params)
                  local damage_level = get_damage_level(params.base_damage, params.damage, chara)
                  show_damage_text(params.attacker, params.weapon, chara, damage_level, true, params.message_tense, params.element, params.extra_attacks)
end)
