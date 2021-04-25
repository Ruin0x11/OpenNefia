local IAspect = require("api.IAspect")

local IAquesTalkConfig = class.interface("IAquesTalkConfig",
                                  {
                                     bas = "string",
                                     spd = "number",
                                     vol = "number",
                                     pit = "number",
                                     acc = "number",
                                     lmd = "number",
                                     fsc = "number",
                                  },
                                  { IAspect })

IAquesTalkConfig.default_impl = "mod.aquestalk.api.aspect.AquesTalkConfigAspect"

return IAquesTalkConfig
