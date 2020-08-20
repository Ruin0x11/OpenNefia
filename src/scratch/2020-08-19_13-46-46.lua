InstancedMap = require("api.InstancedMap")
Calc = require("mod.elona.api.Calc")
Advice = require("api.Advice")
Benchmark = require("mod.tools.api.Benchmark")

Advice.remove_all(Calc.calc_object_level)

map = InstancedMap:new(20, 20)

print(Calc.calc_object_level(10, map))
Benchmark.run(Calc.calc_object_level, nil, 10, map)

function override(base, map)
   return 1234
end
Advice.add("override", Calc.calc_object_level, "Overide calc_object_level", override)
print(Calc.calc_object_level(10, map))

function around(orig_fn, base, map)
   return orig_fn(base, map) / 2
end
Advice.add("around", Calc.calc_object_level, "Around calc_object_level", around)
print(Calc.calc_object_level(10, map))
Benchmark.run(Calc.calc_object_level, nil, 10, map)

Advice.remove_all(Calc.calc_object_level)
print(Calc.calc_object_level(10, map))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
