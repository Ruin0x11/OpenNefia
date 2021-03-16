--- A function that can be serialized, by saving its source code
--- alongside the compiled function.
local LazyFunction = class.class("LazyFunction")

function LazyFunction:init(src)
   self.src = src
   self.compiled = nil
end

function LazyFunction:__call(...)
   if not self.compiled then
      local chunk, err = loadstring(self.src)
      if not chunk then
         error("Error compiling function: " .. err)
      end
      -- local ret = chunk()
      -- local ty = type(ret)
      -- if ty ~= "function" then
      --    error(("Lua source should return function, got %s"):format(ty))
      -- end
      self.compiled = chunk
   end

   return self.compiled(...)
end

function LazyFunction:serialize()
   self.compiled = nil
end

return LazyFunction
