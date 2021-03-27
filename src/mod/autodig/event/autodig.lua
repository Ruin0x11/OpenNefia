local Event = require("api.Event")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Autodig = require("mod.autodig.api.Autodig")

local function proc_autodig(chara, params, result)
   if chara:is_player() and not chara:has_effect("elona.confusion") then
      if Autodig.is_enabled() then
         local map = chara:current_map()
         if not map:has_type("world_map")
            and map:is_in_bounds(params.x, params.y)
            and not map:is_floor(params.x, params.y)
         then
            ElonaAction.dig(chara, params.x, params.y)
            result.blocked = true
            result.turn_result = "turn_end" -- TODO
            return result, Event.Result.Blocked
         end
      end
   end
end
Event.register("base.before_chara_moved", "Proc autodig", proc_autodig, { priority = 300000 })
