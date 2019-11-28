local DeferredEvent = {}

function DeferredEvent.add(cb, priority)
   priority = priority or 100000
   save.elona_sys.deferred_events:insert(priority, cb)
end

function DeferredEvent.clear()
   save.elona_sys.deferred_events:clear()
end

return DeferredEvent
