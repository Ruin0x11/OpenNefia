local Assert = require("api.test.Assert")
local Env = require("api.Env")

function test_Env_get_module_of_member__api()
   local Rand = require("api.Rand")
   Assert.eq(Rand, Env.get_module_of_member(Rand.rnd))
   Assert.eq(nil, Env.get_module_of_member(Rand))
end

function test_Env_get_module_of_member__interface()
   local IOwned = require("api.IOwned")
   Assert.eq(IOwned, Env.get_module_of_member(IOwned.remove_ownership))
   Assert.eq(nil, Env.get_module_of_member(IOwned))

   local IMef = require("api.mef.IMef")
   Assert.eq(IOwned, Env.get_module_of_member(IMef.remove_ownership))
end
