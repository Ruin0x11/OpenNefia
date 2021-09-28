local config_holder = require("internal.config_holder")
local SaveFs = require("api.SaveFs")
local Assert = require("api.test.Assert")
local data = require("internal.data")
local ISerializable = require("api.ISerializable")
local TestUtil = require("api.test.TestUtil")

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
