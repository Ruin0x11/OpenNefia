local Talk = require("api.Talk")

local ICharaTalk = interface("ICharaTalk")

function ICharaTalk:init()
   self:set_talk(self.talk)
   self.is_talk_silenced = false
end

function ICharaTalk:set_talk(talk)
   self.talk = talk
   Talk.setup(self)
end

function ICharaTalk:say(talk_id, args)
   Talk.say(self, talk_id, args)
end

return ICharaTalk
