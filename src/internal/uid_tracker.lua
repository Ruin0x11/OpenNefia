local uid_tracker = class("uid_tracker")

function uid_tracker:init()
   self.uids = {}
end

function uid_tracker:get_next(type_id)
   self.uids[type_id] = self.uids[type_id] or 1
   return self.uids[type_id]
end

function uid_tracker:get_next_and_increment(type_id)
   local uid = self:get_next(type_id)
   self.uids[type_id] = self.uids[type_id] + 1
   return uid
end

return uid_tracker
