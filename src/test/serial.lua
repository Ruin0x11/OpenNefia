local config_holder = require("internal.config_holder")
local SaveFs = require("api.SaveFs")
local Assert = require("api.test.Assert")
local data = require("internal.data")
local ISerializable = require("api.ISerializable")

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
