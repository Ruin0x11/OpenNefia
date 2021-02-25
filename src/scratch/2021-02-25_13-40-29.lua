local nbt = require("thirdparty.nbt")

local Thing = class.class("Thing")
Thing.__serial_id = "Thing"

function Thing:init(x, y, t)
   self.x = x
   self.y = y
   self.t = t
end

function Thing:serialize_nbt()
   return {
      x = nbt.newInt(self.x),
      y = nbt.newInt(self.y),
      t = nbt.newString(self.t),
   }
end

function Thing:deserialize_nbt(t)
   self.x = t["x"]:getInteger()
   self.y = t["y"]:getInteger()
   self.t = t["t"]:getString()
end

function Thing:__tostring()
   return ("%d %d!  %s"):format(self.x, self.y, inspect(self.t))
end

do
   local t = Thing:new(1, 54, { dood = "hey", asd = 42.222222 })
   print(inspect(t))
   print(t)

   local values = t:serialize_nbt()
   local compound = nbt.newCompound(values, "thing")

   -- ==========

   local instance = Thing:new()
   instance:deserialize_nbt(compound:getValue())
   print(inspect(instance))
   print(instance)
end

local Parent = class.class("Parent")
Parent.__serial_id = "Parent"

function Parent:new(p1, p2)
   self.p1 = p1
   self.p2 = p2
end

function Parent:serialize_nbt()
   return {
      p1 = self.p1:serialize_nbt(),
      p2 = self.p2:serialize_nbt()
   }
end

function Parent:deserialize_nbt(t)
end

do
   local t = Thing:new(1, 54, { dood = "hey", asd = 42.222222 })
   local p = Parent:new(p, p)
   print(inspect(p))

   local values = p:serialize_nbt()
   local compound = nbt.newCompound(values, "thing")

   -- ==========

   local instance = Thing:new()
   instance:deserialize_nbt(compound:getValue())
   print(inspect(instance))
   print(instance)
end
