InstancedMap = require("api.InstancedMap")
Calc = require("mod.elona.api.Calc")
Advice = require("api.Advice")

Advice.remove_all(Calc.calc_object_level)

map = InstancedMap:new(20, 20)

print(Calc.calc_object_level(10, map))

function before(base, map)
   print("I'm in your before!")
end
Advice.add("before", Calc.calc_object_level, "I'm in your before!", before)
assert(Advice.is_advised(Calc.calc_object_level))
print(Calc.calc_object_level(10, map))

function before_before(base, map)
   print("I'm BEFORE your before!")
end
Advice.add("before", Calc.calc_object_level, "I'm BEFORE your before!", before_before, { priority = 9000 })

hotload.hotload("mod.elona.api.Calc")
print(Calc.calc_object_level(10, map))

Advice.remove(Calc.calc_object_level, "I'm in your before!")
print(Calc.calc_object_level(10, map))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
