local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")
local Action = require("api.Action")
local Ai = require("api.Ai")

local npc_ai = {}

function npc_ai.choose_action(npc)
   -- EVENT: before_npc_act
   -- RETURN: sandbag
   -- RETURN: leash
   -- RETURN: explode

   -- attempt to use item
   --   eat
   --   drink
   --   read

   return npc.ai:decide_action()
end

local handlers = {}

handlers["base.move"] = function(chara, params)
   return Action.move(chara, params.x, params.y)
end

handlers["base.melee"] = function(chara, params)
   return "turn_end"
end

handlers["base.ranged"] = function(chara, params)
   return "turn_end"
end

function npc_ai.decide_action(chara)
   return chara.ai:decide_action(chara)
end

-- TODO: decouple
function npc_ai.handle_ai_action(chara, action)
   local id = action[1]
   local params = action[2]

   local handler = handlers[id]
   if handler then
      return handler(chara, params)
   end

   Log.warn("No AI handler for %s", id)

   return "turn_end"
end

return npc_ai
