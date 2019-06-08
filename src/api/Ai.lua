local Ai = {}

function Ai.send_event(chara, event, params)
   return chara.ai:send_event(event, params)
end

function Ai.set_target(chara, target)
   return chara.ai:set_target(target)
end

function Ai.get_target(chara)
   return chara.ai:target()
end

function Ai.relation_towards(chara, target)
   return chara.ai:relation_towards(target)
end

return Ai
