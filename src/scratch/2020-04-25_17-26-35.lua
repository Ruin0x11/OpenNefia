SaveFs = require("api.SaveFs")

--- A function that can be serialized, by saving its source code
--- alongside the compiled function.
local LazyFunction = class.class("LazyFunction")

function LazyFunction:init(src)
   self.src = src
   self.compiled = nil
end

function LazyFunction:__call(...)
   if not self.compiled then
      local code = ("return %s"):format(self.src)
      local chunk, err = loadstring(code)
      if not chunk then
         error("Error compiling function: " .. err)
      end
      local ret = chunk()
      local ty = type(ret)
      if ty ~= "function" then
         error(("Lua source should return function, got %s"):format(ty))
      end
      self.compiled = ret
   end

   return self.compiled(...)
end

local func = LazyFunction:new [[
function(a, b)
  return a + b
end
]]
print(func(1, 2))

s = SaveFs.serialize(func)
d = SaveFs.deserialize(s)

print(d(1, 2))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
