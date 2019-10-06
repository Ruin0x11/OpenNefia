local NpcMemory = {}

function NpcMemory.on_killed(id)
   local memory = save.elona_sys.npc_memory
   if not memory.killed[id] then
      memory.killed[id] = 0
   end
   memory.killed[id] = memory.killed[id] + 1
end

function NpcMemory.on_generated(id)
   local memory = save.elona_sys.npc_memory
   if not memory.generated[id] then
      memory.generated[id] = 0
   end
   memory.generated[id] = memory.generated[id] + 1
end

function NpcMemory.forget_generated(id)
   local memory = save.elona_sys.npc_memory
   if not memory.generated[id] then
      memory.generated[id] = 0
   end
   memory.generated[id] = memory.generated[id] - 1
end

function NpcMemory.killed(id)
   local memory = save.elona_sys.npc_memory
   return memory.killed[id] or 0
end

function NpcMemory.generated(id)
   local memory = save.elona_sys.npc_memory
   return memory.generated[id] or 0
end

return NpcMemory
