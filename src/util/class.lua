local class = {}

local _instances = setmetatable({}, { __mode = "k"})
local _interfaces = setmetatable({}, { __mode = "k"})
local _classes = setmetatable({}, { __mode = "k"})

local function make_tostring(kind, tbl)
   return function(self, ...)
      if _instances[self] then
         return string.format("instance of '%s' (%s)",
                              rawget(self.__class,'name') or '?',
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
      if parents[1] == nil then
         error("Parent interface list must be a list")
      end
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

   -- At this point the instance must have all the fields specified in
   -- the interface. It is nothing but a dumb runtime type check and
   -- can be easily subverted after the fact.
   for name, kind in pairs(interface.reqs) do
      local required_type
      if type(kind) == "table" then
         -- Default prototype parameter. If none exists on the
         -- instance, set it now.
         if instance[name] == nil then
            instance[name] = kind.default
         end
         -- If the type differs from the default, produce an error.
         required_type = type(kind.default)
      else
         required_type = kind
      end

      if type(instance[name]) ~= required_type then
         err = (err or "") .. string.format("\n    %s (%s)", name, kind)
      end
   end

   return err
end

local function delegate(c, field, params)
   local set = {}

   if params == nil or _classes[params] then error("Invalid delegate parameter for " .. c.name .. "." .. field .. ": " .. tostring(params)) end
   if _interfaces[params] or type(params) == "string" then params = {params} end
   for _, v in ipairs(params) do
      if _interfaces[v] then
         for r, _ in pairs(v.reqs) do
            c.__delegates[r] = field
         end
      end

      c.__delegates[v] = field
   end
end

function is_an(interface, obj)
   if _classes[interface] then
      return type(obj) == "table" and obj.__class == interface
   end

   return verify(obj, interface) == nil
end

function assert_is_an(interface, obj)
   if _classes[interface] then
      if type(obj) ~= "table" or obj.__class ~= interface then
         error(string.format("%s is not an instance of %s", obj, interface))
      end
      return
   end

   local err = verify(obj, interface)
   if err then
      error(string.format("%s should implement %s: %s", obj, interface, err))
   end
end

function class.class(name, ifaces)
   local c = {}
   _classes[c] = tostring(c)

   c.__tostring = root_mt.__tostring

   c.__delegates = {}
   c.__memoized = setmetatable({}, { __mode = "v" })
   c.__index = function(t, k)
      local i = c[k]
      if i then return i end
      local d = rawget(c, "__delegates")
      if not d then
         return rawget(c, k)
      end

      local field_name = d[k]
      if field_name then
         local going = true
         local field = t
         -- recurse trying to find the delegate at the very bottom of
         -- the chain
         while going do
            if field_name == nil then break end
            t = field
            field = t[field_name]
            if field == nil then break end
            local cl = rawget(field, "__class")
            if cl then
               d = rawget(cl, "__delegates")
               if d and d[k] then
                  field_name = d[k]
               else
                  going = false
               end
            else
               going = false
            end
         end

         if field then
            if type(field[k]) == "function" then
               local f = field[k]
               local __memoized = rawget(t, "__memoized")
               __memoized[k] = __memoized[k] or function(self, ...) return f(field, ...) end
               return __memoized[k]
            else
               -- print("rawget " .. k .. " " .. tostring(field[k]) .. " " .. name .. " " .. field_name)
               return field[k]
            end
         end
      end

      return rawget(c, k)
   end

   c.__newindex = function(t, k, v)
      local d = rawget(c, "__delegates")
      if not d then
         rawset(t, k, v)
         return
      end

      local field_name = d[k]
      if field_name then
         local going = true
         local field = t
         -- recurse trying to find the delegate at the very bottom of
         -- the chain
         while going do
            if field_name == nil then break end
            t = field
            field = t[field_name]
            if field == nil then break end
            local cl = rawget(field, "__class")
            if cl then
               d = rawget(cl, "__delegates")
               if d and d[k] then
                  field_name = d[k]
               else
                  going = false
               end
            else
               going = false
            end
         end

         if field then
            if type(field[k]) == "function" then
               rawset(field, k, v)
               local f = field[k]
               local __memoized = rawget(t, "__memoized")
               __memoized[k] = v
            else
               -- print("rawset " .. k .. " " .. tostring(v) .. " " .. name .. " " .. field_name .. " " .. tostring(field))
               rawset(field, k, v)
            end
            return
         end
      end

      rawset(t, k, v)
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

      local instance = {__class = c}
      _instances[instance] = tostring(instance)

      instance.__memoized = {}

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

   c.get_fq_name = function(self)
      local class = self
      if self.__class then class = self.__class end
      for k, v in pairs(package.loaded) do
         if class == v then
            return k
         end
      end
      return nil
   end

   return setmetatable(c, root_mt)
end

return class
