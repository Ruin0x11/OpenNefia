local CoIter = {}

local function iter(co, i)
   local res = {coroutine.resume(co, i)}
   if coroutine.status(co) == "dead" then
      if not res[1] then
         error(res[2])
      end
      return nil
   end
   table.remove(res, 1)
   return i + 1, table.unpack(res)
end

function CoIter.iter(f)
   local co = coroutine.create(f)
   return fun.wrap(iter, co, 0)
end

return CoIter
