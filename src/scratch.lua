local Item = require("api.Item")
local Event = require("api.Event")

local callback = function(chara, _, result)
   Item.create("elona.gold_piece", chara.x, chara.y)
   chara:current_map():set_tile(chara.x, chara.y, "elona.cobble_caution")
   return result
end

local event = "base.before_chara_moved"
Event.unregister(event, "test event")
--Event.register(event, "test event", callback)
