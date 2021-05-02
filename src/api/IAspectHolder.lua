local AspectHolder = require("api.AspectHolder")
local Aspect = require("api.Aspect")

local IAspectHolder = class.interface("IAspectHolder")

function IAspectHolder:init()
   self._aspects = AspectHolder:new()
end

function IAspectHolder:normal_build(params)
   local aspect_opts = params and params.aspects

   local defaults = Aspect.build_defaults_for(self, aspect_opts)

   for iface, aspect in pairs(defaults) do
      self:set_aspect(iface, aspect)
   end
end

function IAspectHolder:on_refresh()
   for _, aspect in self:iter_aspects() do
      aspect:on_refresh()
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

function IAspectHolder:remove_all_aspects()
   self._aspects:remove_all_aspects()
end

function IAspectHolder:get_aspect_proto(iface)
   local _ext = self.proto._ext
   if not _ext then
      return nil
   end
   if _ext[iface] then
      return _ext[iface]
   end

   -- iterate list part of table
   for _, item in ipairs(_ext) do
      if item == iface then
         return {}
      end
   end

   return nil
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
