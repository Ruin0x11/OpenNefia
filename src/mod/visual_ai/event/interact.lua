local VisualAI = require("mod.visual_ai.api.VisualAI")
local Event = require("api.Event")

local function add_interact_action(chara, params, actions)
   local function add_option(text, callback)
      table.insert(actions, { text = text, callback = callback })
   end

   if chara:is_in_player_party() and not chara:is_player() then
      add_option("visual_ai.interact_action", VisualAI.edit)
   end

   return actions
end
Event.register("elona_sys.on_build_interact_actions", "Add Visual AI option", add_interact_action, { priority = 500000 })
