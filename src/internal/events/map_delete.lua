local save = require("internal.global.save")
local Event = require("api.Event")

local function remove_staying_charas_in_map(_, params)
   save.base.staying_charas:unregister_for_map(params.map_uid)
end
Event.register("base.on_map_deleted", "Remove staying characters from deleted map", remove_staying_charas_in_map)
