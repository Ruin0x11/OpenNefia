local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Enum = require("api.Enum")
local Feat = require("api.Feat")
local I18N = require("api.I18N")
local Magic = require("mod.elona_sys.api.Magic")

local function on_act_hostile_towards(chara, params)
   local other = params.target

   if other:is_in_player_party() then
      other:set_relation_towards(chara, Enum.Relation.Enemy)
      other:set_target(chara)
      return
   end

   if other:relation_towards(chara) > Enum.Relation.Enemy then
      other:set_emotion_icon("elona.angry", 4)
   end

   if other:relation_towards(chara) >= Enum.Relation.Ally then
      Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", other)
   else
      if other:relation_towards(chara) == Enum.Relation.Neutral then
         Effect.modify_karma(chara, -2)
      end

      if other._id == "elona.ebon" and not save.elona.is_fire_giant_released then
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

local function on_ai_dir_check(chara, params, result)
   for _, feat in Feat.at(params.x, params.y, chara:current_map()) do
      if feat._id ~= "elona.door" then
         return result
      end
      if feat.opened then
         return result
      end
   end
   return true
end
Event.register("elona.on_ai_dir_check", "Count closed doors as open spaces", on_ai_dir_check)

local function check_if_sandbag(chara, params, result)
   -- >>>>>>>> shade2/ai.hsp:29 	if cBit(cSandBag,cc){ ...
   if chara:calc("is_hung_on_sandbag") then
      if chara:is_in_fov() then
         if Rand.one_in(30) then
            Gui.mes_c(I18N.quote_speech("action.npc.sand_bag"), "Talk")
         end
      end
      chara:set_aggro(chara:get_target(), 0)
      return true
   end

   return result
   -- <<<<<<<< shade2/ai.hsp:32 		} ..
end
Event.register("elona.before_default_ai_action", "Block if hung on sandbag", check_if_sandbag, {priority = 5000})

local function check_if_leashed(chara, params, result)
   -- >>>>>>>> shade2/ai.hsp:34 	if sync(cc)=false : if cBlind(pc)=false : if rnd( ...
   local leashed_to = chara.leashed_to
   if leashed_to then
      local map = chara:current_map()
      local leader = map:get_object_of_type("base.chara", leashed_to)
      if not Chara.is_alive(leader) then
         chara.leashed_to = nil
      else
         if not chara:is_in_fov()
            and not leader:has_effect("elona.blindness")
            and Rand.one_in(4)
            and not map:has_type("world")
         -- TODO pet arena
         then
            if chara:is_in_same_party(leader) then
               chara:set_target(leader, 0)
            else
               if Rand.one_in(2) then
                  Gui.mes(I18N.quote_speech("action.npc.leash.dialog"))
                  leader:act_hostile_towards(chara)
               end
               if Rand.one_in(4) then
                  chara.leashed_to = nil
                  Gui.mes_c("action.npc.leash.untangle", "SkyBlue", chara)
               end
            end

            Magic.cast("elona.shadow_step", { source = chara, target = leader })
            return true
         end
      end

      return result
      -- <<<<<<<< shade2/ai.hsp:40 		} ..
   end
end
Event.register("elona.before_default_ai_action", "Block if leashed", check_if_leashed, {priority = 5000})

local function check_if_exploding(chara, params, result)
   if chara:calc("is_about_to_explode") then
      Magic.cast("elona.suicide_attack", {source = chara, x = chara.x, y = chara.y})
      return true
   end
   return result
end
Event.register("elona.before_default_ai_action", "Block if exploding", check_if_exploding, {priority = 6000})
