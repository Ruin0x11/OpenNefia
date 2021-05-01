local I18N = require("api.I18N")
local Chara = require("api.Chara")
local Area = require("api.Area")
local Const = require("api.Const")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local World = require("api.World")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Talk = require("api.Talk")

local function get_random_text(t)
   local speaker = t.speaker
   local id = "talk.random.default"
   local params = {
      gender = I18N.get("ui.sex2." .. Chara.player():calc("gender"))
   }

   local from_talk = Talk.gen_text(speaker, "base.dialog")
   if from_talk then
      return from_talk
   end

   local map = speaker:current_map()
   local area = Area.for_map(map)

   local function has_shop(chara, inv_id)
      return chara:iter_roles("elona.shopkeeper")
         :any(function(role) return role.inventory_id == inv_id end)
   end

   if speaker:calc("interest") <= 0 then
      id = "talk.random.bored"
   elseif speaker:is_in_player_party() then
      id = "talk.random.ally_default"
   elseif speaker._id == "elona.prostitute" then
      id = "talk.random.prostitute"
   elseif has_shop(speaker, "elona.moyer") then
      id = "talk.random.moyer"
   elseif speaker:find_role("elona.slaver") then
      id = "talk.random.slavekeeper"
   elseif speaker:calc("impression") >= Const.IMPRESSION_FRIEND and Rand.one_in(3) then
      id = "talk.random.rumor.loot"
   elseif area and area.metadata.is_noyel_christmas_festival then
      id = "talk.random.christmas_festival"
   elseif Rand.one_in(2) then
      id = "talk.random.personality." .. tostring(speaker:calc("personality") or 0)
   elseif Rand.one_in(3) and area._archetype then
      id = "talk.random.area." .. area._archetype
   end

   local npc = speaker:produce_locale_data()
   local player = Chara.player():produce_locale_data()

   local str = I18N.get_optional(id, npc, player, params)
   if str == nil then
      str = I18N.get("talk.random.default", npc, player, params)
   end

   return str
end

local function talk_text(t)
   -- >>>>>>>> elona122/shade2/text.hsp:957 *random_talk ..
   local str = get_random_text(t)

   return { {str} }
   -- <<<<<<<< elona122/shade2/text.hsp:977 	return ..
end

local function modify_impress_and_interest(speaker)
   -- >>>>>>>> elona122/shade2/chat.hsp:2203 		if cInterest(tc)>0 : if cRelation(tc)!cAlly : if ..
   if speaker.interest > 0 and not speaker:is_in_player_party() then
      if Rand.one_in(3) and speaker.impression < Const.IMPRESSION_FRIEND then
         local charisma = Chara.player():skill_level("elona.stat_charisma")
         if Rand.rnd(charisma + 1) > 10 then
            Skill.modify_impression(speaker, Rand.rnd(3))
         else
            Skill.modify_impression(speaker, -Rand.rnd(3))
         end
      end
      speaker.interest = speaker.interest - Rand.rnd(30)
      speaker.interest_renew_date = World.date_hours() + 8
   end
   -- <<<<<<<< elona122/shade2/chat.hsp:2208 		} ..
end

data:add {
   _type = "elona_sys.dialog",
   _id = "default",

   nodes = {
      __start = {
         on_start = function(t)
            modify_impress_and_interest(t.speaker)
         end,
         text = talk_text,
         choices = function(t, state)
            local speaker = t.speaker
            local choices = speaker:emit("elona.calc_dialog_choices", {state=state}, {})

            table.insert(choices, {"__END__", "ui.bye"})

            return choices
         end
      },
      talk = {
         text = talk_text,
         jump_to = "__start"
      },
      you_kidding = {
         text = {
            {"talk.npc.common.you_kidding"}
         },
         jump_to = "__start"
      },
      thanks = {
         text = {
            {"talk.npc.common.thanks"}
         },
         jump_to = "__start"
      },
      trade = function(t)
         -- >>>>>>>> shade2/chat.hsp:2443 	if chatVal=20{ ..
         local result, canceled = ElonaAction.trade(Chara.player(), t.speaker)

         if canceled then
            return "elona.default:you_kidding"
         end
         return "elona.default:thanks"
         -- <<<<<<<< shade2/chat.hsp:2452 		} ..
      end,
   },
}
