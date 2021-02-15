local UidTracker = class.class("UidTracker")

function UidTracker:init(uid)
   self.uid = uid or 1
end

function UidTracker:get_next()
   return self.uid
end

function UidTracker:get_next_and_increment()
   local uid = self:get_next()
   self.uid = self.uid + 1
   return uid
end

return UidTracker
