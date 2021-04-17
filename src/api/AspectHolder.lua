local env = require("internal.env")
local IAspect = require("api.IAspect")
local PriorityMap = require("api.PriorityMap")
local Aspect = require("api.Aspect")

local AspectHolder = class.class("AspectHolder")

AspectHolder.DEFAULT_PRIORITY = 100000

function AspectHolder:init()
   self._store = PriorityMap:new()
end

function AspectHolder:iter()
   return self._store:iter()
end

function AspectHolder:get_aspect(target, iface)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_is_an(IAspect, iface)

   local name = assert(iface.__name)
   return self._store:get(name)
end

function AspectHolder:get_aspect_or_default(target, iface, ...)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_is_an(IAspect, iface)

   local name = assert(iface.__name)
   local aspect = self._store:get(name)

   if aspect == nil then
      local default = Aspect.get_default_impl(iface)
      aspect = default:new(target, ...)
      local priority = AspectHolder.DEFAULT_PRIORITY
      self._store:set(name, aspect, priority)
   end

   return aspect
end

function AspectHolder:set_aspect(target, iface, aspect, priority)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_is_an(IAspect, iface)
   class.assert_is_an(iface, aspect)

   local name = assert(iface.__name)
   self._store:set(name, aspect, priority or AspectHolder.DEFAULT_PRIORITY)
end

return AspectHolder
