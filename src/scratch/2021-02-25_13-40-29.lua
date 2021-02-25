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
      t = nbt.newArbitraryTable(self.t),
   }
end

function Thing:deserialize_nbt(t)
   self.x = t["x"]:getInteger()
   self.y = t["y"]:getInteger()
   self.t = t["t"]:getArbitraryTable()
end

function Thing:__tostring()
   return ("%d %d!  %s"):format(self.x, self.y, inspect(self.t))
end


local Parent = class.class("Parent")
Parent.__serial_id = "Parent"

function Parent:init(p1, p2)
   self.p1 = p1
   self.p2 = p2
end

function Parent:serialize_nbt()
   return {
      p1 = nbt.newClassCompound(self.p1),
      p2 = nbt.newClassCompound(self.p2)
   }
end

function Parent:deserialize_nbt(t)
   self.p1 = t["p1"]:getClassCompound()
   self.p2 = t["p2"]:getClassCompound()
end

nbt.registerClass(Thing)
nbt.registerClass(Parent)

do
   local t = Thing:new(1, 54, { dood = "hey", asd = 42.222222 })
   local p = Parent:new(t, t)
   print(inspect(p))

   local compound = nbt.newClassCompound(p, "parent")

   -- ==========

   local instance = compound:getClassCompound()
   print(inspect(instance))
   print(instance.p1 == instance.p2)
end
