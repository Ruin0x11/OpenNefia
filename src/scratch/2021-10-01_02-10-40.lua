TestUtil = require("api.test.TestUtil")
fs = require("util.fs")
SaveFs = require("api.SaveFs")

local a = TestUtil.stripped_chara("elona.putit")
local b = TestUtil.stripped_chara("elona.putit")
a.b = b
b.a = a
local t = { a }

fs.write(fs.join(fs.get_save_directory(), "test"), SaveFs.serialize(t))

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
