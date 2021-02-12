local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Event = require("api.Event")

local function on_act_hostile_towards(chara, params)
   local other = params.target

   if other:reaction_towards(chara) >= 0 then
      other:set_emotion_icon("elona.angry", 4)
   end

   if other:reaction_towards(chara) >= 1000 then
      Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", other)
   else
      if other:reaction_towards(chara) >= 100 then
         Effect.modify_karma(chara, -2)
      end

      if other._id == "elona.fire_giant" then
         Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", other)
         return
      end

      if other:reaction_towards(chara) > 0 then
         Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", other)
         other:set_reaction_at(chara, 0) -- reaction towards "base.friendly" is 100
      else
         if other:reaction_towards(chara) >= 0 then
            Gui.mes_c("misc.hostile_action.gets_furious", "Purple", other)
         end
         other:set_reaction_at(chara, -100)
         other.ai_state.hate = 80
         other:set_target(chara)
      end
   end

   if other.is_livestock and Rand.one_in(50) then
      Gui.mes_c("misc.hostile_action.get_excited", "Red")
      local anger = function(cc)
         cc:set_reaction_at(chara, -100)
         cc:set_target(chara)
         cc.ai_state.hate = 20
         other:set_emotion_icon("elona.angry", 3)
      end
      Chara.iter():filter(function(c) return other.is_livestock end):each(anger)
   end
end

Event.register("base.on_act_hostile_towards", "Default impl", on_act_hostile_towards)
