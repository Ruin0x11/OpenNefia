local Event = require("api.Event")
local VisualAI = require("mod.visual_ai.api.VisualAI")

local function run_visual_ai(chara, params, result)
   local ext = chara:get_mod_data("visual_ai")

   if ext.visual_ai_enabled and ext.visual_ai_plan then
      VisualAI.run(chara, ext.visual_ai_plan)
      return true
   end

   return result
end
Event.register("elona.on_default_ai_action", "Run Visual AI", run_visual_ai, {priority = 5000})
