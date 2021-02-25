local nbt = require("thirdparty.nbt")
local ISerializable = require("api.ISerializable")
local Fs = require("api.Fs")

local Thing = class.class("Thing", ISerializable)

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


local Parent = class.class("Parent", ISerializable)

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

function Parent:__tostring()
   return ("(%s, %s)"):format(self.p1, self.p2)
end

do
   local t = Thing:new(1, 54, { dood = "hey", asd = 42.222222 })
   local p = Parent:new(t, t)
   print(p)

   local compound = nbt.newClassCompound(p, "parent")

   -- ==========

   local instance = compound:getClassCompound()
   print(instance)
   print(instance.p1 == instance.p2)
end

local Option = class.class("Option", ISerializable)

function Option:init(value)
   if value then
      assert(value.__class)
   end
   self.value = value
end

function Option:serialize_nbt()
   local result = {}

   local exists = (self.value ~= nil and 1) or 0
   result.__exists = nbt.newByte(exists)
   if self.value ~= nil then
      result.__value = nbt.newClassCompound(self.value, "__value")
   end

   return result
end

function Option:deserialize_nbt(t)
   local exists = t["__exists"]:getInteger()
   if exists == 1 then
      self.value = t["__value"]:getClassCompound()
   end
end

do
   local opt1 = Option:new(Thing:new(1, 54, { dood = "hey", asd = 42.222222 }))
   local opt2 = Option:new(nil)

   local compound1 = nbt.newClassCompound(opt1, "opt1")
   local compound2 = nbt.newClassCompound(opt2, "opt2")
   print(inspect(compound1))
   print(inspect(compound2))

   -- ==========

   local instance1 = compound1:getClassCompound()
   local instance2 = compound2:getClassCompound()
   print(inspect(instance1))
   print(inspect(instance2))
end

do
   local t = Thing:new(1, 54, { dood = "hey", asd = 42.222222 })
   local p = Parent:new(t, t)
   local opt = Option:new(p)

   local compound = nbt.newClassCompound(opt, "option")

   local obj = assert(Fs.open("test.nbt", "wb"))
   assert(obj:write(compound:encode()))
   obj:close()
end
