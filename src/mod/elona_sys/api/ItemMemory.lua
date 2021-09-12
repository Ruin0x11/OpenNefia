local Event = require("api.Event")

local ItemMemory = {}

-- itemMemory(0, ci)
function ItemMemory.set_known(id, known)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   if memory == nil then
      return
   end
   memory.known[id] = not not known
   Event.trigger("elona_sys.on_item_memorize_known", {_id = id, is_known = memory.known[id]})
end

function ItemMemory.is_known(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   if memory == nil then
      return false
   end
   Event.trigger("elona_sys.on_item_check_known", {_id = id, is_known = memory.known[id]})
   return memory.known[id]
end

-- itemMemory(1, ci)
function ItemMemory.on_generated(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   if memory == nil then
      return
   end
   memory.generated[id] = (memory.generated[id] or 0) + 1
   Event.trigger("elona_sys.on_item_memorize_generated", {_id = id, generated_count = memory.generated[id]})
end

function ItemMemory.forget_generated(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   if memory == nil then
      return
   end
   memory.generated[id] = math.max((memory.generated[id] or 0) - 1, 0)
end

function ItemMemory.generated(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   if memory == nil then
      return 0
   end
   Event.trigger("elona_sys.on_item_check_generated", {_id = id, generated_count = memory.generated[id] or 0})
   return memory.generated[id] or 0
end

local RESERVE_STATES = table.set {
   "not_reserved",
   "reserved"
}

-- itemMemory(2, ci)
function ItemMemory.set_reserved_state(id, reserved)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   if memory == nil then
      return
   end
   if not (RESERVE_STATES[reserved] or reserved == nil) then
      error(("Unknown spellbook reserve state %s"):format(reserved))
   end
   memory.reserved[id] = reserved
end

function ItemMemory.reserved_state(id)
   data["base.item"]:ensure(id)
   local memory = save.elona_sys.item_memory
   if memory == nil then
      return "not_reserved"
   end
   return memory.reserved[id]
end

return ItemMemory
