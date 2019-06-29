require("boot")

local IEffects = require("api.IEffects")
local Object = require("api.Object")
local IObject = require("api.IObject")

local o = Object.mock_interface(IEffects)

o:mod("dood", 2)
o:mod("dood", -12, "add")

o.flags = { test = { dood = true }}
o.it = 50
o.dood = 24
o:refresh()

local OEffect = require("api.OEffect")

local e2 = Object.mock(OEffect)

e2.method = "set"
e2.delta = {
   delta = {
      dood = 1100
   }
}

local e = Object.mock(OEffect)

e.method = "add"
e.delta = {
   dood = 11,
   it = -10,
   flags = {
      test = {
         dood = false
      }
   }
}

e:add_effect(e2)
e:refresh()
_p(e:calc("delta"))

o:add_effect(e)
o:add_effect(e)
o:refresh()

print(inspect(o.temp))
print()

local buff = Object.mock(OEffect)

buff.method = "add"
buff.delta = { stats = {} }
buff.power = 120
buff.stat = "base.test"
buff.on_refresh = function(self)
   self.delta.stats[self.stat] = self.power * 4
end

local c = Object.mock(OEffect)
IObject.init(c)

c.stats = { ["base.test"] = 20 }
c:add_effect(buff)
c:add_effect(buff)
c:add_effect(buff)
c:remove_effect(1)
c:remove_effect(2)
c:add_effect(buff)
c:refresh()

print(inspect(c:calc("stats")))
