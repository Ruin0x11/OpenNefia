local BooleanGen = require("api.test.gen.BooleanGen")
local StringGen = require("api.test.gen.StringGen")
local IntGen = require("api.test.gen.IntGen")
local FloatGen = require("api.test.gen.FloatGen")
local IGenerator = require("api.test.gen.IGenerator")
local Rand = require("api.Rand")

local ObjectGen = class.class("ObjectGen", IGenerator)

function ObjectGen:init(cb, ignore)
   self.bases = {}
   self.cb = cb
   self.ignore = ignore or {}
   self.ignore._type = true
   self.ignore._id = true
   self.ignore.uid = true
   self.ignore.location = true

   self.gen_string = StringGen:new()
   self.gen_int = IntGen:new()
   self.gen_float = FloatGen:new()
   self.gen_boolean = BooleanGen:new()
end

function ObjectGen:pick(size)
   local base = self.cb(size)
   local new = table.deepcopy(base)
   self.bases[new] = base

   local props = table.keys(base)
   for k, _ in pairs(self.ignore) do
      table.iremove_value(props, k)
   end

   for _ = 1, size do
      local done
      repeat
         done = true
         local prop = Rand.choice(props)
         local v = new[prop]
         local ty = type(v)
         if ty == "string" then
            new[prop] = self.gen_string:pick(size)
         elseif ty == "number" then
            if math.floor(v) == v then
               new[prop] = self.gen_int:pick(size)
            else
               new[prop] = self.gen_float:pick(size)
            end
         elseif ty == "boolean" then
            new[prop] = self.gen_boolean:pick(size)
         else
            done = false
         end
      until done
   end
   return new
end

function ObjectGen:shrink(tbl)
   local t = {}
   local base = self.bases[tbl]

   for k, v in pairs(tbl) do
      local fb = base[k]
      if fb and v ~= fb then
         local new = table.shallow_copy(tbl)
         local mt = getmetatable(tbl)
         setmetatable(new, mt)
         self.bases[new] = base
         rawset(new, k, fb)
         t[#t+1] = new
      end
   end

   return t
end

return ObjectGen
