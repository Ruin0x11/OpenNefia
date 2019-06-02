local Extend = {}

function Extend.extend(obj, name, key, data)
   obj.__ext = obj.__ext or {}
   obj.__ext[name] = obj.__ext[name] or {}
   obj.__ext[name][key] = data
end

function Extend.get(obj, name, key)
   return table.maybe(obj, "__ext", name, key)
end

return Extend
