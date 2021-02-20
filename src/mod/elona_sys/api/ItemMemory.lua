local Event = require("api.Event")

local ItemMemory = {}

-- itemMemory(0, ci)
function ItemMemory.on_generated(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   memory.generated[id] = (memory.generated[id] or 0) + 1
   Event.trigger("elona_sys.on_item_memorize_generated", {_id = id, generated_count = memory.generated[id]})
end

function ItemMemory.forget_generated(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   memory.generated[id] = math.max((memory.generated[id] or 0) - 1, 0)
end

function ItemMemory.generated(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   Event.trigger("elona_sys.on_item_check_generated", {_id = id, generated_count = memory.generated[id] or 0})
   return memory.generated[id] or 0
end

-- itemMemory(1, ci)
function ItemMemory.set_known(id, known)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   memory.known[id] = not not known
   Event.trigger("elona_sys.on_item_memorize_known", {_id = id, is_known = memory.known[id]})
end

function ItemMemory.is_known(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   Event.trigger("elona_sys.on_item_check_known", {_id = id, is_known = memory.known[id]})
   return memory.known[id]
end

return ItemMemory
