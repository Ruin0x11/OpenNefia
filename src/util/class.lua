local binser = require("thirdparty.binser")

-- OOP wrapper. Based on 30log (https://github.com/Yonaba/30log)
--
-- TODOs:
-- + Delegation is far too complex and confusing. It should not be
--   possible to delegate non-function fields and they should be
--   functions instead. Delegating function fields should be the same
--   as generating a new function that preserves the current self of
--   the object.
-- + Hotloading is overly complicated, buggy and unreliable, because
--   of the need for manually copying all combined interface fields.
--   There could be a toggle for development which will use lookup
--   tables (the same tables as contained on the interface itself) to
--   find the correct function to call, so there is no need to copy
--   anything.
local class = {}

local _interfaces = setmetatable({}, { __mode = "k" })
local _classes = setmetatable({}, { __mode = "k" })
local _iface_children = setmetatable({}, { __mode = "k" })

local function make_tostring(kind, tbl)
   return function(self)
      local addr = string.gsub(string.tostring_raw(self), "^table: (.*)", "%1")
      if self.__class then
         return string.format("instance of '%s' (%s)",
                              rawget(self.__class,'__name') or '?', addr)
      end
      return tbl[self]
         and string.format("%s '%s' (%s)", kind, rawget(self, "__name") or "?", addr)
         or string.tostring_raw(self)
   end
end

local iface_mt = {
   __tostring = make_tostring("Interface", _interfaces),
   __index = function(t, k)
      local m = rawget(t, "all_methods")
      if m then
         local meth = rawget(m, k)
         if meth then
            return meth
         end
      end
      return rawget(t, k)
   end,
   __newindex = function(t, k, v)
      if type(v) == "function" then
         t.methods[k] = v
         t.all_methods[k] = v
         return
      end
      rawset(t, k ,v)
   end
}

_interfaces[iface_mt] = tostring(iface_mt)
setmetatable(iface_mt,
             {
                __tostring = iface_mt.__tostring,
                __inspect = tostring
             })

function class.interface(name, reqs, parents)
   local i = {}
   _interfaces[i] = tostring(i)

   i.__index = i
   i.__name = name
   i.reqs = reqs or {}
   i.methods = {}
   i.all_methods = {}

   i.delegate = function(i, field, params)
      if params == nil or _classes[params] then error("Invalid delegate parameter for " .. c.__name .. "." .. field .. ": " .. tostring(params)) end
      if _interfaces[params] or type(params) == "string" then params = {params} end
      for _, k in ipairs(params) do
         i.methods[k] = function(self, ...)
            local delegate_self = self[field]
            if delegate_self == nil then
               error("Cannot find method " .. k)
            end
            return delegate_self[k](delegate_self, ...)
         end
         i.all_methods[k] = i.methods[k]
      end
   end

   i.add_interface = function(p)
      if not _interfaces[p] then
         error(string.format("%s must be an interface", tostring(p)))
      end
      i.reqs = table.merge(table.deepcopy(p.reqs), i.reqs)
      i.all_methods = table.merge(table.deepcopy(p.all_methods), i.all_methods)
      i.__parents[#i.__parents+1] = p
      _iface_children[p][i] = true
   end

   i.__parents = {}
   if parents then
      if _interfaces[parents] then parents = {parents} end
      if parents[1] == nil then
         error("Parent interface list must be a list")
      end
      for _, p in ipairs(parents) do
         i.add_interface(p)
      end
   end

   i.__tostring = iface_mt.__tostring

   _iface_children[i] = _iface_children[i] or setmetatable({}, { __mode = "k" })

   if not binser.hasResource(name) and not binser.hasRegistry(name) then
      binser.registerClass(i, name)
   end

   return setmetatable(i, iface_mt)
end

local class_mt = {
   __tostring = make_tostring("Class", _classes),
   __inspect = tostring
}

_classes[class_mt] = tostring(class_mt)
setmetatable(class_mt, { __tostring = class_mt.__tostring })

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
      local optional = false
      if type(kind) == "table" then
         -- Default prototype parameter. If none exists on the
         -- instance, set it now.
         if instance[name] == nil then
            instance[name] = kind.default
         end
         -- If the type differs from the default, produce an error.
         required_type = type(kind.default)
         optional = kind.optional
      else
         required_type = kind
      end

      if type(instance[name]) ~= required_type and not optional then
         err = (err or "") .. string.format("\n    %s (%s)", name, required_type)
      end
   end

   return err
end

-- TODO: this system is really bloated and doesn't preserve "self" inside nested
-- delegated calls (object schizophrenia), leading to much confusion. All that
-- is actually needed is generating a function call that calls the delegate's
-- version of the method, but instead passing the parent "self".
local function delegate(c, field, params)
   assert(type(field) == "string", "Must pass field name")

   if params == nil or _classes[params] then error("Invalid delegate parameter for " .. c.__name .. "." .. field .. ": " .. tostring(params)) end
   if _interfaces[params] or type(params) == "string" then params = {params} end
   for _, v in ipairs(params) do
      if _interfaces[v] then
         for r, _ in pairs(v.reqs) do
            c.__delegates[r] = field
         end
      end

      -- BUG: doesn't respect hotloading
      c.__delegates[v] = field
   end
end

function class.is_an(interface, obj)
   if type(interface) == "string" then
      interface = require(interface)
   end

   if type(obj) ~= "table" then
      return false, ("Needed class '%s', got value of type '%s'"):format(tostring(interface), type(obj))
   end

   if _classes[interface] then
      local result = obj.__class == interface
      if not result then
         local name = obj.__class
         if type(name) == "table" then
            name = tostring(obj.__class)
         end
         return false, ("Needed class '%s', got '%s'"):format(tostring(interface), tostring(name))
      end

      return true
   end

   local err = verify(obj, interface)

   return err == nil, err
end

function class.assert_is_an(interface, obj)
   local ok, err = class.is_an(interface, obj)
   if not ok then
      error(string.format("%s (%s) is not an instance of %s: %s", obj, type(obj), interface, err))
   end
end

local function copy_all_interface_methods_to_class(klass)
   klass.__interface_methods = {}

   for _, iface in ipairs(klass.__interfaces) do
      for k, v in pairs(iface.all_methods) do
         if not klass.__interface_methods[k] then
            klass.__interface_methods[k] = v
         end
      end
   end
end

function class.class(name, ifaces, opts)
   opts = opts or {}

   local c = {}

   _classes[c] = tostring(c)

   if opts.no_inspect then
      c.__inspect = tostring
   end

   c.__tostring = class_mt.__tostring

   c.__delegates = {}
   c.__memoized = setmetatable({}, { __mode = "v" })
   c.__index = function(t, k)
      local i = c[k]
      if i then return i end
      local im = rawget(c, "__interface_methods")
      if im then
         local imf = rawget(im, k)
         if imf then
            return imf
         end
      end
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
               -- TODO: this will not play well with hotloading.
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

      if k == "new" then
         error("Cannot overwrite 'new' method")
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

   c.__name = name

   if _interfaces[ifaces] then ifaces = {ifaces} end
   c.__interfaces = ifaces or {}
   c.__interface_methods = {}

   copy_all_interface_methods_to_class(c)

   c.delegate = delegate

   c._serialize = function(self)
      if type(self.serialize) == "function" then
         self:serialize()
      end
      return self
   end

   c._deserialize = function(self)
      self.__memoized = {}
      self.__class = c
      setmetatable(self, c)
      if type(self.deserialize) == "function" then
         self:deserialize()
      end
      return self
   end

   c.new = function(self, ...)
      if type(self) ~= "table" or self.__name ~= name then
         error("Call new() with colon (:) syntax.")
      end

      local instance = {__class = c}

      instance.__memoized = {}

      setmetatable(instance, c)

      if c.init then
         c.init(instance, ...)
      end

      if c.__verify and c.__interfaces then
         for _, i in ipairs(c.__interfaces) do
            class.assert_is_an(i, instance)
         end
      end

      return instance
   end

   if not binser.hasResource(name) and not binser.hasRegistry(name) then
      binser.registerClass(c, name)
   end

   return setmetatable(c, class_mt)
end

function class.is_class_or_interface(tbl)
   return _classes[tbl] or _interfaces[tbl]
end

function class.is_class_instance(tbl)
   return _classes[tbl.__class]
end

function class.uses_interface(klass_or_iface, iface)
   local ifaces
   if _interfaces[klass_or_iface] then
      ifaces = klass_or_iface.__parents
   else
      ifaces = klass_or_iface.__interfaces
   end

   for _, i in ipairs(ifaces) do
      if iface == i then
         print("find " .. " " .. klass_or_iface.__name .. " " .. iface.__name .. " " .. i.__name)
         return true
      end

      local children = _iface_children[iface] or {}
      for _, child in ipairs(children) do
         if class.uses_interface(klass_or_iface, child) then
            print("find " .. " " .. klass_or_iface.__name .. " " .. iface.__name .. " " .. i.__name)
            return true
         end
      end
   end

   return false
end

local function copy_all_interface_methods_to_children(iface)
   -- NOTE: order may become important in the future
   for child, _ in pairs(_iface_children[iface]) do
      child.reqs = table.merge(table.deepcopy(iface.reqs), child.reqs)

      child.all_methods = {}
      for _, parent in ipairs(child.__parents) do
         for k, v in pairs(parent.all_methods) do
            child.all_methods[k] = v
         end
      end
      child.all_methods = table.merge(child.all_methods, table.deepcopy(child.methods))

      copy_all_interface_methods_to_children(child)
   end
end

function class.hotload(old, new)
   if _classes[old] then
      -- These functions capture the class table inside the hotloaded
      -- chunk. To make sure they point to the hotloaded methods,
      -- discard the ones in the hotloaded chunk since they reference
      -- the newly created table internal to the hotloaded chunk.
      -- Example:
      --
      -- - File is loaded, producing a chunk with Class v1.
      -- - File is hotloaded, producing another chunk with Class v2.
      -- - All methods from Class v2 are merged onto Class v1.
      --   However, Class v2's :new() captures the Class v2 metatable
      --   in the :new() closure when using setmetatable.
      -- - When calling :new on Class v1 after merging, it will set
      --   the metatable of Class v2 on the created table instead of
      --   Class v1. The changes merged onto Class v1 will not be
      --   reflected in this object.
      --
      -- TODO: actually you can use a function called debug.setupvalue
      -- to modify upvalues. it should be used instead.
      local method_new = old.new
      local method___index = old.__index
      local method___newindex = old.__newindex

      for k, _ in pairs(old) do
         rawset(old, k, nil)
      end
      for k, v in pairs(new) do
         rawset(old, k, v)
      end

      -- BUG: This means when you hotload the class, the "new" function will
      -- never get updated. We'd have to regenerate another "new" function for
      -- the class here.
      rawset(old, "new", method_new)
      rawset(old, "__index", method___index)
      rawset(old, "__newindex", method___newindex)
   elseif _interfaces[old] then
      -- The interface system works in a sort of abstract class/mixin
      -- manner. Interfaces can specify parent interfaces, and on
      -- creation each parent's declared methods are copied to the
      -- interface's `all_methods` table. This is to prevent having to
      -- look up the method all the way up the inheritance tree every
      -- time an interface method is used. (In hindsight, likely a
      -- premature optimization...) In this way, interfaces with
      -- parents can choose to define methods of the same name,
      -- overwriting any methods inherited from any parent. Due to
      -- this, the copied functions can't be modified directly with
      -- hotloading as it is a value copy into a different table and
      -- the order of copying is important (parent-to-child). Instead
      -- all of them have to be copied again to see changes.
      --
      -- For classes, all methods from used interfaces are collected
      -- in an __interface_methods table by copying. The principle is
      -- similar.
      --
      -- When hotloading an interface, the current mechanism is to
      -- first update the inheritance tree of parent/child interfaces,
      -- update the interface table in-place, then to copy and
      -- overwrite all methods for all the children of the hotloaded
      -- interface recursively. Afterwards, any classes that use
      -- interfaces will also have the methods from each interface
      -- they use regenerated from scratch also.

      for _, iface in ipairs(old.__parents) do
         _iface_children[iface][old] = nil
      end

      for k, _ in pairs(old) do
         rawset(old, k, nil)
      end
      for k, v in pairs(new) do
         rawset(old, k, v)
      end

      for _, iface in ipairs(old.__parents) do
         _iface_children[iface][old] = true
      end

      copy_all_interface_methods_to_children(old)

      local iface_classes = {}
      -- NOTE: the ordering of pairs is unspecified
      for klass, _ in pairs(_classes) do
         if klass ~= class_mt then
            if class.uses_interface(klass, old) then
               iface_classes[#iface_classes] = klass
            end
         end
      end

      for _, c in ipairs(iface_classes) do
         copy_all_interface_methods_to_class(c)
      end
   end
end

function class._iter_classes()
   return fun.iter(_classes)
end

function class._iter_interfaces()
   return fun.iter(_interfaces)
end

return class
