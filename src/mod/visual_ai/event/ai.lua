local Event = require("api.Event")
local VisualAI = require("mod.visual_ai.api.VisualAI")
local Log = require("api.Log")
local ICharaVisualAI = require("mod.visual_ai.api.aspect.ICharaVisualAI")

local function run_visual_ai(chara, params, result)
   local aspect = chara:get_aspect(ICharaVisualAI)

   if aspect and aspect.enabled then
      local plan = aspect:calc(chara, "plan")
      if plan then
         local ok, err = VisualAI.run(chara, aspect.plan)
         if not ok then
            Log.error("Visual AI: %s", err)
         else
            return true
         end
      end
   end

   return result
end
Event.register("elona.on_default_ai_action", "Run Visual AI", run_visual_ai, {priority = 5000})
