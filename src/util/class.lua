local class = {}

local _instances = setmetatable({}, { __mode = "k"})
local _interfaces = setmetatable({}, { __mode = "k"})
local _classes = setmetatable({}, { __mode = "k"})

local function make_tostring(kind, tbl)
   return function(self, ...)
      if _instances[self] then
         return string.format("instance of '%s' (%s)",
                              rawget(self.class,'name') or '?',
                              _instances[self])
      end
      return tbl[self]
         and string.format("%s '%s'", kind, rawget(self, "name") or "?")
         or self
   end
end

local iface_mt = {
   __tostring = make_tostring("Interface", _interfaces)
}

_interfaces[iface_mt] = tostring(iface_mt)
setmetatable(iface_mt, { __tostring = iface_mt.__tostring })

function class.interface(name, reqs, parents)
   local i = {}
   _interfaces[i] = tostring(i)

   i.__index = i
   i.name = name
   i.reqs = reqs

   if parents then
      if _interfaces[parents] then parents = {parents} end
      for _, p in ipairs(parents) do
         if not _interfaces[p] then
            error(string.format("%s must be an interface", tostring(p)))
         end
         i.reqs = table.merge(table.deepcopy(p.reqs), i.reqs)
      end
      i.parents = parents
   end

   i.__tostring = iface_mt.__tostring

   return setmetatable(i, iface_mt)
end

local root_mt = {
   __tostring = make_tostring("Class", _classes)
}

_classes[root_mt] = tostring(root_mt)
setmetatable(root_mt, { __tostring = root_mt.__tostring })

local function verify(instance, interface)
   if not _interfaces[interface] then
      return string.format("%s must be an interface", tostring(interface))
   end
   local err
   for name, kind in pairs(interface.reqs) do
      if type(instance[name]) ~= kind then
         err = (err or "") .. string.format("\n    %s (%s)", name, kind)
      end
   end

   return err
end

local function delegate(c, field, params)
   local set = {}
   if type(params) == "string" then params = {params} end
   for _, v in ipairs(params) do
      c._delegates[v] = field
   end
end

function is_an(interface, obj)
   return verify(obj, interface) == nil
end

function assert_is_an(interface, obj)
   local err = verify(obj, interface)
   if err then
      error(string.format("%s should implement %s: %s", obj, interface, err))
   end
end

function class.class(name, ifaces)
   local c = {}
   _classes[c] = tostring(c)

   c.__tostring = root_mt.__tostring

   c._delegates = {}
   c._memoized = setmetatable({}, { __mode = "v" })
   c.__index = function(t, k)
      local d = rawget(c, "_delegates")
      if not d then
         return rawget(c, k)
      end

      local field_name = d[k]
      if field_name then
         local field = t[field_name]
         if field then
            if type(field[k]) == "function" then
               local f = field[k]
               local _memoized = rawget(t, "_memoized")
               _memoized[k] = _memoized[k] or function(self, ...) return f(field, ...) end
               return _memoized[k]
            else
               return field[k]
            end
         end
      end

      return rawget(c, k)
   end

   c.__verify = true

   c.name = name

   if _interfaces[ifaces] then ifaces = {ifaces} end
   c.interfaces = ifaces

   c.delegate = delegate

   c.new = function(self, ...)
      if type(self) ~= "table" or self.name ~= name then
         error("Call new() with colon (:) syntax.")
      end

      local instance = {class = c}
      _instances[instance] = tostring(instance)

      instance._memoized = {}

      setmetatable(instance, c)

      if c.init then
         c.init(instance, ...)
      end

      if c.__verify and c.interfaces then
         for _, i in ipairs(c.interfaces) do
            assert_is_an(i, instance)
         end
      end

      return instance
   end

   return setmetatable(c, root_mt)
end

return class
