local sound_manager = require("internal.sound_manager")

local data = require("internal.data")
local lists = {
   ["base.sound"] = data["base.sound"],
   ["base.music"] = data["base.music"]
}

return sound_manager:new(lists)
