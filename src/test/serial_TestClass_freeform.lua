local serial_TestClass_freeform = class.class("serial_TestClass_freeform",
                                              {},
                                              { serial_opts = { load_type = "freeform" } })


function serial_TestClass_freeform:init(foo, bar)
   self.foo = foo
   self.bar = bar
   self.serializing = false
   self.piyo = 42
end

function serial_TestClass_freeform:hoge(serializing)
   self.serializing = serializing
   if self.serializing then
      self.piyo = self.piyo / 2
   else
      self.piyo = self.piyo * 2
   end
end

function serial_TestClass_freeform:serialize()
   self:hoge(true)

   return self.foo, self.bar
end

function serial_TestClass_freeform.deserialize(foo, bar)
   local new = serial_TestClass_freeform:new(foo, bar)
   new:hoge(false)
   return new
end

return serial_TestClass_freeform
