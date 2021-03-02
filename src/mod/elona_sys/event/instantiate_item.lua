local Event = require("api.Event")

-- The following events are necessary to run on every object each time
-- a map is loaded because event callbacks are not serialized.

Event.register("base.on_item_instantiated", "Connect item events",
               function(item)
                  -- This is where the callbacks on item prototypes
                  -- like "on_use" and "on_drink" get used. It might
                  -- be a bit difficult to find with the function name
                  -- generation.
                  --
                  -- The reason there are boolean flags indicating if
                  -- an action can be taken ("can_eat", "can_open") is
                  -- because it makes it easier to temporarily disable
                  -- the action. Without this the check relies on
                  -- whether or not the event handler is present, and
                  -- it is difficult to preserve the state of event
                  -- handlers across serialization.
                  local actions = {
                     "use",        -- on_use,        can_use,        elona_sys.on_item_use
                     "eat",        -- on_eat,        can_eat,        elona_sys.on_item_eat
                     "drink",      -- on_drink,      can_drink,      elona_sys.on_item_drink
                     "read",       -- on_read,       can_read,       elona_sys.on_item_read
                     "zap",        -- on_zap,        can_zap,        elona_sys.on_item_zap
                     "open",       -- on_open,       can_open,       elona_sys.on_item_open
                     "dip_source", -- on_dip_source, can_dip_source, elona_sys.on_item_dip_source
                     "throw",      -- on_throw,      can_throw,      elona_sys.on_item_throw
                     "descend",    -- on_descend,    can_descend,    elona_sys.on_item_descend
                     "ascend",     -- on_ascend,     can_ascend,     elona_sys.on_item_ascend
                  }

                  for _, action in ipairs(actions) do
                     local event_id = "elona_sys.on_item_" .. action
                     local event_name = "Item prototype on_" .. action .. " handler"

                     -- If a handler is left over from previous instantiation
                     if item:has_event_handler(event_id) then
                        item:disconnect_self(event_id, event_name)
                     end

                     if item.proto["on_" .. action] then
                        item:connect_self(event_id, event_name, item.proto["on_" .. action])
                     end

                     if item:has_event_handler("elona_sys.on_item_" .. action) then
                        item["can_" .. action] = true
                     else
                        item["can_" .. action] = nil
                     end
                  end
end)

Event.register("base.on_item_instantiated", "Permit item actions",
               function(item)
                  if item:has_category("elona.container") then
                     item.can_open = true
                  end

                  if item:has_category("elona.food")
                     or item:has_category("elona.cargo_food")
                  then
                     item.can_eat = true
                  end

                  if item:has_category("elona.drink") then
                     item.can_throw = true
                  end
end)

local IItem = require("api.item.IItem")
Event.register("base.on_hotload_object", "reload events for item", function(obj)
                  if class.is_an(IItem, obj) then
                     obj:instantiate()
                  end
end)
