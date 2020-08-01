local Event = require("api.Event")


-- TODO
-- local function archetype_on_spawn_monster(map)
-- end
--
-- Event.register("base.on_map_restock", "Archetype callback (on_map_renew)", archetype_on_map_renew)

local function archetype_on_map_restock(map)
end

Event.register("base.on_map_renew", "Archetype callback (on_map_renew)", archetype_on_map_restock)

local function archetype_on_map_renew(map)
end

Event.register("base.on_map_renew", "Archetype callback (on_map_renew)", archetype_on_map_renew)
