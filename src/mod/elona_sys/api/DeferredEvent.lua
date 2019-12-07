local DeferredEvent = {}

function DeferredEvent.add(cb, priority)
   priority = priority or 100000
   save.elona_sys.deferred_events:insert(priority, cb)
end

function DeferredEvent.clear()
   save.elona_sys.deferred_events:clear()
end

function DeferredEvent.is_pending()
   return save.elona_sys.deferred_events:length() > 0
end

return DeferredEvent
