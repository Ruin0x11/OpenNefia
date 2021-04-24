local env = require("internal.env")
local IAspect = require("api.IAspect")
local aspect_state = require("internal.global.aspect_state")

local Aspect = {}

function Aspect.get_default_impl(iface)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_implements(IAspect, iface)
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
   class.assert_implements(IAspect, iface)
   assert(class.is_interface(iface))

   if type(impl) == "string" then
      impl = env.safe_require(impl)
   end
   class.assert_implements(iface, impl)
   assert(class.is_class(impl))

   aspect_state.default_impls[iface.__name] = impl
end

function Aspect.new_default(iface, obj, params)
   return Aspect.get_default_impl(iface):new(obj, params)
end

-- Queries the player for an aspect action to use if there is more than one
-- aspect on an item that fulfills a specific interface.
function Aspect.query_aspect(obj, iface, filter, mes_cb)
   local aspects = obj:iter_aspects(iface):filter(function(a) return filter(a, obj) end):to_list()

   if #aspects == 0 then
      return nil
   elseif #aspects == 1 then
      return aspects[1]
   else
      local map = function(aspect)
         return aspect:localize_action(obj, iface)
      end

      local choices = fun.iter(aspects):map(map):to_list()

      -- TODO disambiguate serialization ID and __name for classes
      if mes_cb then
         mes_cb(obj, iface)
      end
      local Prompt = require("api.gui.Prompt")
      local result, canceled = Prompt:new(choices):query()

      if canceled then
         return nil
      end

      return aspects[result.index]
   end
end

return Aspect
