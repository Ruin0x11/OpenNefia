local Gui = require("api.Gui")
local Talk = require("api.Talk")

local ICharaTalk = class.interface("ICharaTalk")

function ICharaTalk:init()
end

function ICharaTalk:mes_c(text, args, ...)
   local color
   if type(args) == "string" then
      color = args
   elseif type(args) == "table" then
      color = args.color or nil
   end

   Gui.mes_c(text, color, ...)

   self:emit("base.on_chara_say_message")
end

function ICharaTalk:mes(id, ...)
   return self:mes_c(id, "Talk", ...)
end

function ICharaTalk:say(talk_id, args, opts)
   return Talk.say(self, talk_id, args, opts)
end

return ICharaTalk
