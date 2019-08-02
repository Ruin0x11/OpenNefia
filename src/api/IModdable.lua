local IModdable = class.interface("IModdable")

function IModdable:init()
   self.temp = {}
end

function IModdable:on_refresh()
   self.temp = {}
end

--- Obtains a property or calls a function to compute something. Using
--- this function instead of plain access (obj.prop) means the
--- property will support the value refresh system.
function IModdable:calc(key, ...)
   if self.temp[key] ~= nil then
      return self.temp[key]
   elseif self[key] ~= nil then
      local can_call = type(self[key]) == "function"
      if can_call then
         return self[key](self, ...)
      else
         return self[key]
      end
   else
      return nil
   end
end


--- Modifies a temporary value. This will be cleared when refresh() is
--- called on the object.
function IModdable:mod(prop, v, method, params)
   local defaults = self
   if params and params.no_default then
      defaults = nil
   end
   table.merge_ex_single(self.temp, v, method or "add", defaults, prop)
   return self.temp[prop]
end

-- Modifies a base value. This will persist if refresh() is called,
-- and is the same as regular assignment.
function IModdable:mod_base(prop, v, method, params)
   local defaults = self.proto
   if params and params.no_default then
      defaults = nil
   end
   table.merge_ex_single(self, v, method or "add", defaults, prop)
   return self[prop]
end

-- Modifies this object's temporary values by merging them with `tbl`.
function IModdable:mod_with(tbl, method, params)
   local defaults = self
   if params and params.no_default then
      defaults = nil
   end
   return table.merge_ex(self.temp, tbl, defaults, method or "add")
end

-- Modifies this object's base values by merging them with `tbl`.
function IModdable:mod_base_with(tbl, method, params)
   local defaults = self.proto
   if params and params.no_default then
      defaults = nil
   end
   return table.merge_ex(self, tbl, defaults, method or "add")
end

--- Clears a temporary value and sets a base value at the same time.
function IModdable:reset(prop, v, method)
   self.temp[prop] = nil
   return self:mod_base(prop, v, method or "set")
end

return IModdable
