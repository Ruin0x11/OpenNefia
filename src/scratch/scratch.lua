ElonaPos = require("mod.elona.api.ElonaPos")
Anim = require("mod.elona_sys.api.Anim")
Gui = require("api.Gui")
Chara = require("api.Chara")
Tools = require("mod.tools.api.Tools")

p = Chara.player()
t = Tools.enemy()
map = Chara.player():current_map()
breath = ElonaPos.make_breath(p.x, p.y, t.x, t.y, 20, map)
anim = Anim.breath(breath, "elona.lightning", p.x, p.y, t.x, t.y, map)
Gui.start_draw_callback(anim)

function dood()
   do
      print "dood"
   end
end

do
   do
      dood()
   end
end

local test = {}
function test.test()
   Gui.mes("test")
end

Mx = require("mod.tools.api.Mx")
Mx.add_function("test", function(...) test.test(...) end)
Mx.start()

-- Local Variables:
-- opennefia-always-send-to-repl: t
-- End:
