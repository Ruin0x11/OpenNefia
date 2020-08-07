--- @module IModdable

local IModdable = class.interface("IModdable")

function IModdable:init()
   self.temp = {}
end

--- Refreshes this object, resetting its temporary values.
function IModdable:on_refresh()
   self.temp = {}
end

--- Obtains a property or calls a function to compute something. Using
--- this function instead of plain access (obj.prop) means the
--- property will support the value refresh system.
--- @tparam string key
--- @param ...
function IModdable:calc(key, ...)
   if self.temp[key] ~= nil then
      return self.temp[key]
   end

   return self[key]
end


--- Modifies a temporary value. This will be cleared when refresh() is
--- called on the object.
--- @tparam string prop
--- @tparam any v
--- @tparam[opt] string method
--- @tparam[opt] table params
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
--- @tparam string prop
--- @tparam any v
--- @tparam[opt] string method
--- @tparam[opt] table params
function IModdable:mod_base(prop, v, method, params)
   local defaults = self.proto
   if params and params.no_default then
      defaults = nil
   end
   table.merge_ex_single(self, v, method or "add", defaults, prop)
   return self[prop]
end

-- Modifies this object's temporary values by merging them with `tbl`.
--- @tparam table tbl
--- @tparam[opt] string method
--- @tparam[opt] table params
function IModdable:mod_with(tbl, method, params)
   local defaults = self
   if params and params.no_default then
      defaults = nil
   end
   return table.merge_ex(self.temp, tbl, defaults, method or "add")
end

-- Modifies this object's base values by merging them with `tbl`.
--- @tparam table tbl
--- @tparam[opt] string method
--- @tparam[opt] table params
function IModdable:mod_base_with(tbl, method, params)
   local defaults = self.proto
   if params and params.no_default then
      defaults = nil
   end
   return table.merge_ex(self, tbl, defaults, method or "add")
end

--- Clears a temporary value and sets a base value at the same time.
--- @tparam string prop
--- @tparam any v
--- @tparam[opt] string method
function IModdable:reset(prop, v, method)
   self.temp[prop] = nil
   return self:mod_base(prop, v, method or "set")
end

return IModdable
