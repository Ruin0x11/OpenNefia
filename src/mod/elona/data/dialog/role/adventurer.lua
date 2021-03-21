local Adventurer = require("mod.elona.api.Adventurer")
local I18N = require("api.I18N")
local Chara = require("api.Chara")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Gui = require("api.Gui")
local Enum = require("api.Enum")
local World = require("api.World")
local Const = require("api.Const")

data:add {
   _type = "elona_sys.dialog",
   _id = "adventurer",

   nodes = {
      hire = function(t)
         local cost = math.max(math.floor(Adventurer.calc_hire_cost(t.speaker)), 0)
         return { node_id = "hire_confirm", params = { cost = cost } }
      end,
      hire_confirm = {
         text = function(t, state, params)
            return {
               I18N.get("talk.npc.adventurer.hire.cost", params.cost, t.speaker)
            }
         end,
         choices = function(t, state, params)
            local choices = {}

            if Chara.player().gold >= params.cost then
               Dialog.add_choice("hire_accept", "talk.npc.adventurer.hire.choices.pay", choices, params)
            end
            Dialog.add_choice("elona.default:you_kidding", "talk.npc.adventurer.hire.choices.go_back", choices)

            return choices
         end
      },
      hire_accept = function(t, state, params)
         -- >>>>>>>> shade2/chat.hsp:2831 			snd sePayGold : cGold(pc)-=calcHireAdv(tc) ...
         local adv = t.speaker
         Gui.play_sound("base.paygold1")
         local player = Chara.player()
         player.gold = player.gold - params.cost
         adv.relation = Enum.Relation.Ally
         adv.is_hired = true
         local role = assert(adv:find_role("elona.adventurer"))
         role.contract_expiry_date = World.date_hours() + 24 * 7
         role.times_contracted = role.times_contracted + 1
         Gui.play_sound("base.pray1")
         Gui.mes_c("talk.npc.adventurer.hire.you_hired", "Yellow", adv)
         return "elona.default:thanks"
         -- <<<<<<<< shade2/chat.hsp:2835 			snd sePray : txtEf coYellow : txt lang(name(tc) ..
      end,

      join = function(t)
         local adv = t.speaker

         if Chara.player():calc("level") < Adventurer.calc_join_level_requirement(adv) then
            return "join_too_weak"
         end

         local role = assert(adv:find_role("elona.adventurer"))
         if not (t.speaker.impression >= Const.IMPRESSION_MARRY and role.times_contracted > 2) then
            return "join_not_known"
         end

         return "join_accept"
      end,
      join_too_weak = {
         text = "talk.npc.adventurer.join.too_weak",
         jump_to = "elona.default:__start"
      },
      join_not_known = {
         text = "talk.npc.adventurer.join.not_known",
         jump_to = "elona.default:__start"
      },
      join_accept = {
         text = "talk.npc.adventurer.join.accept",
         choices = {
            {"do_join", "ui.more"}
         }
      },
      do_join = function(t)
         -- >>>>>>>> shade2/chat.hsp:2848 			chatMore lang(_kimi(3)+"となら上手くやっていけそう"+_da()+_y ...
         local player = Chara.player()
         if not player:can_recruit_allies() then
            return "join_party_full"
         end

         local adv = t.speaker
         adv:remove_all_roles("elona.adventurer")
         save.elona.staying_adventurers:unregister(adv)
         adv.impression = Const.IMPRESSION_FRIEND
         Adventurer.generate_and_place()

         player:recruit_as_ally(adv)

         return "__END__"
         -- <<<<<<<< shade2/chat.hsp:2854 			goto *chat_end ..
      end,
      join_party_full = {
         text = "talk.npc.adventurer.join.party_full",
         jump_to = "elona.default:__start"
      }
   }
}
