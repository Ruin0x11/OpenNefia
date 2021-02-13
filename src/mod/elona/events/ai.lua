local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Enum = require("api.Enum")

local function on_act_hostile_towards(chara, params)
   local other = params.target

   if other:relation_towards(chara) > Enum.Relation.Enemy then
      other:set_emotion_icon("elona.angry", 4)
   end

   if other:relation_towards(chara) >= Enum.Relation.Ally then
      Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", other)
   else
      if other:relation_towards(chara) == Enum.Relation.Neutral then
         Effect.modify_karma(chara, -2)
      end

      if other._id == "elona.fire_giant" then
         Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", other)
         return
      end

      if other:relation_towards(chara) > Enum.Relation.Hate then
         Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", other)
         other:set_relation_towards(chara, Enum.Relation.Hate)
      else
         if other:relation_towards(chara) > Enum.Relation.Enemy then
            Gui.mes_c("misc.hostile_action.gets_furious", "Purple", other)
         end
         other:set_relation_towards(chara, Enum.Relation.Enemy)
         other:set_target(chara, 80)
      end
   end

   if other.is_livestock and Rand.one_in(50) then
      Gui.mes_c("misc.hostile_action.get_excited", "Red")
      local anger = function(cc)
         cc:set_relation_towards(chara, Enum.Relation.Enemy)
         cc:set_target(chara, 20)
         other:set_emotion_icon("elona.angry", 3)
      end
      Chara.iter():filter(function(c) return other.is_livestock end):each(anger)
   end
end

Event.register("base.on_act_hostile_towards", "Default impl", on_act_hostile_towards)
