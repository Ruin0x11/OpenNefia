_CONSOLE = true
require("boot")

local cli = require("tools.cli")
local ok, err = xpcall(cli, debug.traceback, arg, {})

if not ok then
   print(err)
   os.exit(1)
end

os.exit(0)
