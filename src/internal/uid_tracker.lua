local uid_tracker = class("uid_tracker")

function uid_tracker:init()
   self.uid = 1
end

function uid_tracker:get_next()
   return self.uid
end

function uid_tracker:get_next_and_increment()
   local uid = self:get_next()
   self.uid = self.uid + 1
   return uid
end

return uid_tracker
