local env = require("internal.env")
local IAspect = require("api.IAspect")
local PriorityMap = require("api.PriorityMap")
local Aspect = require("api.Aspect")
local IComparable = require("api.IComparable")

local AspectHolder = class.class("AspectHolder", IComparable)

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

function AspectHolder:get_aspect_or_default(target, iface, and_set)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_is_an(IAspect, iface)

   local name = assert(iface.__name)
   local aspect = self._store:get(name)

   if aspect == nil then
      local default = Aspect.get_default_impl(iface)
      aspect = default:new(target, {})
      local priority = AspectHolder.DEFAULT_PRIORITY
      if and_set then
         self._store:set(name, aspect, priority)
      end
   end

   return aspect
end

function AspectHolder:set_aspect(target, iface, aspect, priority)
   if type(iface) == "string" then
      iface = env.safe_require(iface)
   end
   class.assert_is_an(IAspect, iface)
   class.assert_is_an(iface, aspect)

   aspect.temp = aspect.temp or {}

   local name = assert(iface.__name)
   self._store:set(name, aspect, priority or AspectHolder.DEFAULT_PRIORITY)
end

local function find_iface(aspect, name)
   return fun.iter(aspect.__interfaces):filter(function(i) return i.__name == name end):nth(1)
end

function AspectHolder:compare(other)
   local seen = table.set {}

   for _, aspect, name in self:iter() do
      seen[name] = true
      local other_aspect = other._store:get(name)
      if other_aspect == nil then
         return false
      end

      if aspect.__class ~= other_aspect.__class then
         return false
      end

      if class.is_an(IComparable, aspect) then
         if not aspect:compare(other_aspect) then
            return false
         end
      else
         -- Compare the values of the interface requirements of the two aspects.
         local iface = find_iface(aspect, name)
         if iface == nil then
            return false
         end

         local reqs = table.deepcopy(iface.reqs) or {}
         reqs["temp"] = "table"

         for key, req in pairs(reqs) do
            local our_value = aspect[key]
            local their_value = other_aspect[key]

            if class.is_an(IComparable, our_value) then
               if not our_value:compare(their_value) then
                  return false
               end
            else
               if (type(our_value) == "table" and type(their_value) == "table") then
                  if not table.deepcompare(our_value, their_value) then
                     return false
                  end
               else
                  if our_value ~= their_value then
                     return false
                  end
               end
            end
         end
      end
   end

   for _, _, name in other:iter() do
      if not seen[name] then
         return false
      end
   end

   return true
end

return AspectHolder
