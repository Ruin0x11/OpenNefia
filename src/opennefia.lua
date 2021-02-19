_CONSOLE = true
require("boot")

local cli = require("tools.cli")
local ok, stat = xpcall(cli, debug.traceback, arg, {})

if not ok then
   print(stat)
   os.exit(1)
end

os.exit(stat or 0)
