local serial_TestClass_reference = class.class("serial_TestClass_reference")
serial_TestClass_reference.__serial_opts = { load_type = "reference" }

local instances = {}

function serial_TestClass_reference:init(foo, bar)
   self.foo = foo
   self.bar = bar
   self.serializing = false
   self.piyo = 42

   instances[self.foo] = instances[self.foo] or {}
   instances[self.foo][self.bar] = self
end

function serial_TestClass_reference:hoge(serializing)
   self.serializing = serializing
   if self.serializing then
      self.piyo = self.piyo / 2
   else
      self.piyo = self.piyo * 2
   end
end

function serial_TestClass_reference:serialize()
   self:hoge(true)

   return self.foo, self.bar
end

function serial_TestClass_reference.deserialize(foo, bar)
   local ref = instances[foo][bar]
   ref:hoge(false)
   return ref
end

return serial_TestClass_reference
