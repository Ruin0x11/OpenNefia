local AspectHolder = require("api.AspectHolder")
local IAspect = require("api.IAspect")
local Aspect = require("api.Aspect")
local IAspectModdable = require("api.IAspectModdable")

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
   IAspectModdable.init(aspect)
   obj:set_aspect(iface, aspect)
end

function IAspectHolder:normal_build(params)
   local params = params and params.aspects
   local _ext = self.proto._ext
   if _ext then
      for k, v in pairs(_ext) do
         if type(k) == "number" and is_aspect(v) then
            default_aspect(self, v, (params and params[v]) or {})
         elseif is_aspect(k) then
            local _params = (params and params[k]) or {}
            if type(v) == "table" then
               _params = table.merge_ex(table.deepcopy(v), _params)
            end
            default_aspect(self, k, _params)
         end
      end
   end
end

function IAspectHolder:on_refresh()
   for _, aspect in self:iter_aspects() do
      IAspectModdable.on_refresh(aspect)
   end
end

function IAspectHolder:get_aspect(iface)
   return self._aspects:get_aspect(self, iface)
end

function IAspectHolder:get_aspect_or_default(iface, and_set, ...)
   return self._aspects:get_aspect_or_default(self, iface, and_set, ...)
end

function IAspectHolder:set_aspect(iface, aspect)
   self._aspects:set_aspect(self, iface, aspect)
end

function IAspectHolder:iter_aspects(iface)
   if iface then
      return self:iter_aspects():filter(function(a) return class.is_an(iface, a) end)
   end

   return fun.wrap(self._aspects:iter())
end

function IAspectHolder:calc_aspect(iface, prop)
   local aspect = self:get_aspect(iface)
   if aspect == nil then
      return nil
   end
   return aspect:calc(self, prop)
end

function IAspectHolder:calc_aspect_base(iface, prop)
   local aspect = self:get_aspect(iface)
   if aspect == nil then
      return nil
   end
   return aspect:calc(self, prop, true)
end

function IAspectHolder:mod_aspect(iface, prop, v, method, params)
   local aspect = self:get_aspect(iface)
   if aspect == nil then
      error("Aspect is nil")
   end
   return aspect:mod(self, prop, v, method, params)
end

function IAspectHolder:mod_aspect_base(iface, prop, v, method, params)
   local aspect = self:get_aspect(iface)
   if aspect == nil then
      error("Aspect is nil")
   end
   return aspect:mod_base(self, prop, v, method, params)
end

return IAspectHolder
