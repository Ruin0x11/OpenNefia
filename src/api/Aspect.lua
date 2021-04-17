local env = require("internal.env")
local IAspect = require("api.IAspect")
local aspect_state = require("internal.global.aspect_state")

local Aspect = {}

function Aspect.get_default_impl(iface)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_is_an(IAspect, iface)
   assert(class.is_interface(iface))

   local impl = aspect_state.default_impls[iface.__name]
   if impl == nil and iface.default_impl then
      Aspect.set_default_impl(iface, iface.default_impl)
   end

   return aspect_state.default_impls[iface.__name] or nil
end

function Aspect.set_default_impl(iface, impl)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_is_an(IAspect, iface)
   assert(class.is_interface(iface))

   if type(impl) == "string" then
      impl = env.safe_require(impl)
   end
   class.assert_is_an(IAspect, impl)
   assert(class.is_class(impl))

   aspect_state.default_impls[iface.__name] = impl
end

return Aspect
