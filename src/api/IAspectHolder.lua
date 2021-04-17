local AspectHolder = require("api.AspectHolder")
local IAspect = require("api.IAspect")
local Aspect = require("api.Aspect")

local IAspectHolder = class.interface("IAspectHolder")

function IAspectHolder:init()
   self._aspects = AspectHolder:new()
end

local function is_aspect(v)
   return class.is_interface(v) and class.is_an(IAspect, v)
end

local function default_aspect(obj, iface, params)
   local default = Aspect.get_default_impl(iface)
   local aspect = default:new(obj, params)
   obj:set_aspect(iface, aspect)
end

function IAspectHolder:normal_build(params)
   local ext = self.proto.ext
   if ext then
      for k, v in pairs(ext) do
         print("Is aspect",k,v,is_aspect(k),is_aspect(v))
         if type(k) == "number" and is_aspect(v) then
            default_aspect(self, v, params)
         elseif is_aspect(k) then
            local _params = params
            if type(v) == "table" then
               _params = table.merge_ex(table.deepcopy(v), params)
            end
            default_aspect(self, k, _params)
         end
      end
   end
end

function IAspectHolder:get_aspect(iface)
   return self._aspects:get_aspect(self, iface)
end

function IAspectHolder:get_aspect_or_default(iface, ...)
   return self._aspects:get_aspect_or_default(self, iface, ...)
end

function IAspectHolder:set_aspect(iface, aspect)
   self._aspects:set_aspect(self, iface, aspect)
end

function IAspectHolder:iter_aspects()
   return fun.wrap(self._aspects:iter())
end

return IAspectHolder
