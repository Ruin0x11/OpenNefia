local config_holder = require("internal.config_holder")
local SaveFs = require("api.SaveFs")
local Assert = require("api.test.Assert")
local data = require("internal.data")
local TestUtil = require("api.test.TestUtil")
local serial_TestClass_self = require("test.serial_TestClass_self")
local serial_TestClass_freeform = require("test.serial_TestClass_freeform")
local serial_TestClass_reference = require("test.serial_TestClass_reference")

function test_serial_ISerializable_callbacks()
   local holder = config_holder:new("base")
   Assert.eq(config_holder, getmetatable(holder))
   Assert.eq("800x600", holder.screen_resolution)

   local new = SaveFs.deserialize(SaveFs.serialize(holder))
   Assert.eq(config_holder, getmetatable(holder))
   Assert.eq("800x600", holder.screen_resolution)

   Assert.eq(config_holder, getmetatable(new))
   Assert.eq("800x600", new.screen_resolution)
end

function test_serial_data_proxies()
   local proxy = data["base.chara"]
   Assert.eq("data_proxy", proxy.__serial_id)

   local new = SaveFs.deserialize(SaveFs.serialize(proxy))
   Assert.eq(proxy, new)
end

function test_serial_data_entries()
   local entry = data["base.chara"]["base.player"]
   Assert.eq("data_entry", entry.__serial_id)

   local new = SaveFs.deserialize(SaveFs.serialize(entry))
   Assert.eq(entry, new)
end

function test_serial_nested_map_object_reference()
   local a = TestUtil.stripped_chara("elona.putit")
   local b = TestUtil.stripped_chara("elona.putit")
   a.b = b
   b.a = a
   local t = { a }

   Assert.eq(t[1], t[1].b.a) -- by reference

   local t2 = SaveFs.deserialize(SaveFs.serialize(t))
   Assert.eq(t2[1], t2[1].b.a)
end

function test_serial_class_self()
   local test = serial_TestClass_self:new(123.456, true)

   Assert.eq(123.456, test.foo)
   Assert.eq(true, test.bar)
   Assert.eq(false, test.serializing)
   Assert.eq(42, test.piyo)

   local data = SaveFs.serialize(test)

   Assert.eq(123.456, test.foo)
   Assert.eq(true, test.bar)
   Assert.eq(false, test.serializing)
   Assert.eq(42, test.piyo)

   local new = SaveFs.deserialize(data)

   Assert.eq(123.456, new.foo)
   Assert.eq(true, new.bar)
   Assert.eq(false, new.serializing)
   Assert.eq(42, test.piyo)
   Assert.not_eq(test, new)
end

function test_serial_class_freeform()
   local test = serial_TestClass_freeform:new(123.456, true)

   Assert.eq(123.456, test.foo)
   Assert.eq(true, test.bar)
   Assert.eq(false, test.serializing)
   Assert.eq(42, test.piyo)

   local data = SaveFs.serialize(test)

   Assert.eq(123.456, test.foo)
   Assert.eq(true, test.bar)
   Assert.eq(true, test.serializing)
   Assert.eq(21, test.piyo)

   local new = SaveFs.deserialize(data)

   Assert.eq(123.456, new.foo)
   Assert.eq(true, new.bar)
   Assert.eq(false, new.serializing)
   Assert.eq(84, new.piyo)
   Assert.not_eq(test, new)
end

function test_serial_class_reference()
   local test = serial_TestClass_reference:new(123.456, true)

   Assert.eq(123.456, test.foo)
   Assert.eq(true, test.bar)
   Assert.eq(false, test.serializing)
   Assert.eq(42, test.piyo)

   local data = SaveFs.serialize(test)

   Assert.eq(123.456, test.foo)
   Assert.eq(true, test.bar)
   Assert.eq(true, test.serializing)
   Assert.eq(21, test.piyo)

   local new = SaveFs.deserialize(data)

   Assert.eq(123.456, new.foo)
   Assert.eq(true, new.bar)
   Assert.eq(false, new.serializing)
   Assert.eq(42, test.piyo)
   Assert.eq(test, new)
end
