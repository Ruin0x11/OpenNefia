local config_holder = require("internal.config_holder")
local holder = config_holder:new("base")
local SaveFs = require("api.SaveFs")

print(holder.screen_resolution)
local a = SaveFs.deserialize(SaveFs.serialize(holder))
print(holder.screen_resolution)
print(a.screen_resolution)

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
