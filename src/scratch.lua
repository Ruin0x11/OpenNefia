local Map = require("api.Map")
local SaveFs = require("api.SaveFs")

print("===== normal")
for i, v, c in Map.current():iter():take(4) do
   print(i, tostring(v), tostring(c))
end

local _, m = SaveFs.read("map/3")

print("===== iter")
for i, v, c in m:iter() do
   print(i, tostring(v), tostring(c))
end

print("===== multi pool")
for i, v, c in fun.iter(m._multi_pool.refs) do
   print(i, tostring(v), tostring(c))
end

print("===== pairs")
for i, v, c in pairs(m._multi_pool.refs) do
   print(i, tostring(v), tostring(c))
end
