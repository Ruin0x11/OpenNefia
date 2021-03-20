local save = require("internal.global.save")
local Event = require("api.Event")
local Area = require("api.Area")

local function remove_staying_charas_in_map(_, params)
   local area, floor = Area.for_map(params.map_uid)
   if area then
      save.base.staying_charas:unregister_for_area(area, floor)
   end
end
Event.register("base.on_map_deleted", "Remove staying characters from deleted map", remove_staying_charas_in_map)

local function remove_staying_charas_in_area(_, params)
   save.base.staying_charas:unregister_all_for_area(params.area)
end
Event.register("base.on_area_deleted", "Remove staying characters from deleted area", remove_staying_charas_in_area)
