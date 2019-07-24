local Event = require("api.Event")

--
--
-- turn sequence events
--
--

-- local function proc_effects_turn_start(chara, params, result)
--    for effect_id, _ in pairs(chara.effects) do
--       local effect = data["elona_sys.effect"]:ensure(effect_id)
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
      local effect = data["elona_sys.effect"]:ensure(effect_id)
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
