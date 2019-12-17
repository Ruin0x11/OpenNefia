local sound_manager = require("internal.sound_manager")

local data = require("internal.data")
local lists = {
   sound = data["base.sound"],
   music = data["base.music"]
}

return sound_manager:new(lists)
