local IAspectModdable = class.interface("IAspectModdable", {
                                           -- on_refresh = "function",
                                           -- calc = "function",
                                           -- mod = "function",
                                           -- mod_base = "function"
                                                           })

function IAspectModdable:init()
   self.temp = {}
end

function IAspectModdable:on_refresh()
   self.temp = {}
end

function IAspectModdable:calc(target, key)
   self.temp = self.temp or {}

   if self.temp[key] ~= nil then
      return self.temp[key]
   end

   return self[key]
end

function IAspectModdable:mod(target, prop, v, method, params)
   local defaults = self
   if params and params.no_default then
      defaults = nil
   end
   table.merge_ex_single(self.temp, v, method or "add", defaults, prop)
   return self.temp[prop]
end

function IAspectModdable:mod_base(target, prop, v, method, params)
   local defaults = self.proto
   if params and params.no_default then
      defaults = nil
   end
   table.merge_ex_single(self, v, method or "add", defaults, prop)
   return self[prop]
end

return IAspectModdable
