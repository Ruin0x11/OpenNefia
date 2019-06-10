local Event = require("api.Event")
local Gui = require("api.Gui")

local Ai = {}

function Ai.send_event(chara, event, params)
   return chara.ai:event(event, params)
end

function Ai.set_target(chara, target)
   return chara.ai:set_target(target)
end

function Ai.get_target(chara)
   return chara.ai:get_target()
end

function Ai.relation_towards(chara, target)
   return chara.ai:relation_towards(chara, target)
end

function Ai.hate_towards(chara, target)
   return chara.ai:hate_towards(chara, target)
end

function Ai.act_hostile_towards(chara, target)
   local relation = Ai.relation_towards(chara, target)

   if relation == "friendly" then
      Gui.mes(target.uid .. " glares at " .. chara.uid)
   else
      if relation == "neutral" then
         -- TODO: modify karma
      end
      if relation ~= "enemy" and relation ~= "angered" then
         Gui.mes(target.uid .. " glares at " .. chara.uid)
         target.relation = "angered"
      elseif relation ~= "enemy" then
         Gui.mes(target.uid .. " gets furious at " .. chara.uid)
         -- TODO: Ai.set_relation_towards(chara, target, "enemy")
         target.relation = "enemy"
         Ai.send_event(chara, "base.turn_hostile", {target = chara, hate = 80})
      end
   end

   Event.trigger("base.on_chara_hostile_action", {chara=chara,target=target})
end

return Ai
