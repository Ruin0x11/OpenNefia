local Extend = {}

function Extend.get(obj, id)
   return obj._ext[id]
end

function Extend.get_or_create(obj, id)
   local _ext = obj._ext
   if _ext then
      obj._ext[id] = obj._ext[id] or {}
      return _ext[id]
   end

   obj._ext = {}
   obj._ext[id] = obj._ext[id] or {}
   return obj._ext[id]
end

return Extend
