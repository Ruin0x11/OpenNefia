local ICharaVisualAI = require("mod.visual_ai.api.aspect.ICharaVisualAI")
local VisualAIPlan = require("mod.visual_ai.api.plan.VisualAIPlan")

local CharaVisualAIAspect = class.class("CharaVisualAIAspect", ICharaVisualAI)

function CharaVisualAIAspect:init(item, params)
   if params.plan then
      class.assert_is_an(VisualAIPlan, params.plan)
   end

   self.plan = params.plan or nil
   self.enabled = params.enabled or false
   self.stored_target = nil
end

return CharaVisualAIAspect
