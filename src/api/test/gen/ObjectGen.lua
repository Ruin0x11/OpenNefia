local IGenerator = require("api.test.gen.IGenerator")
local Rand = require("api.Rand")

local ObjectGen = class.class("ObjectGen", IGenerator)

function ObjectGen:init(cb, ignore)
   self.bases = {}
   self.cb = cb
   self.ignore = ignore or {}
   ignore.uid = true
   ignore.location = true
end

local function random_string(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
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
            new[prop] = random_string(size)
         elseif ty == "number" then
            if math.floor(v) == v then
               new[prop] = Rand.rnd(1, 1000000)
            else
               new[prop] = Rand.rnd_float()
            end
         elseif ty == "boolean" then
            new[prop] = Rand.one_in(2)
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
