local IAspectModdable = require("api.IAspectModdable")

local IAspect = class.interface("IAspect", { localize_action = "function" }, { IAspectModdable })

function IAspect:localize_action(obj, iface)
   return "???"
end

function IAspect.__on_require(t)
   -- HACK Require the aspect's default impl so its deserializer will get loaded on startup.
   -- See #162.
   if t.default_impl then
      require(t.default_impl)
   end
end

return IAspect
