local ItemMemory = {}

function ItemMemory.on_generated(id)
   local memory = save.elona_sys.item_memory
   memory.generated[id] = (memory.generated[id] or 0) + 1
end

function ItemMemory.set_known(id, known)
   local memory = save.elona_sys.item_memory
   memory.known[id] = not not known
end

function ItemMemory.generated(id)
   local memory = save.elona_sys.item_memory
   return memory.generated[id] or 0
end

function ItemMemory.is_known(id)
   local memory = save.elona_sys.item_memory
   return not not memory.known[id]
end

return ItemMemory
