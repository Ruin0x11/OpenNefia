print(inspect(types))

print(inspect(types.check(1, types.number)))
print(types.check(false, types.number))
print(types.check({a = 1}, types.fields { a = types.string }))
print(types.check({a = "b"}, types.fields { a = types.string }))

local InstancedMap = require("api.InstancedMap")
local m = InstancedMap:new(10, 10)

print(types.check({a = {b = m}}, types.fields { a = types.fields { b = types.string }}))
print(types.check({a = {b = m}}, types.fields { a = types.fields { b = types.instance_of(InstancedMap) }}))
print(types.check(m, types.instance_of(InstancedMap)))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
