Gui = require("api.Gui")
Mx = require("mod.tools.api.Mx")

test = {}
function test.test()
   Gui.mes("test")
end

Mx.add_function("test", function(...) test.test(...) end)
Mx.start()

-- Local Variables:
-- elona-next-always-send-to-repl: t
-- End:
