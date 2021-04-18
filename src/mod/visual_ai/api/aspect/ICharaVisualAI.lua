local IAspect = require("api.IAspect")
local World = require("api.World")

local ICharaVisualAI = class.interface("IItemFood",
                                  {
                                     plan = { type = "table", optional = true },
                                     enabled = "boolean",
                                     stored_target = { type = "table", optional = true },
                                  },
                                  { IAspect })

ICharaVisualAI.default_impl = "mod.visual_ai.api.aspect.CharaVisualAIAspect"

return ICharaVisualAI
