local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Gui = require("api.Gui")
local ElonaAction = require("mod.elona.api.ElonaAction")

data:add {
   _type = "elona_sys.dialog",
   _id = "prostitute",

   nodes = {
      before_confirm = function(t, state)
         state.cost = math.floor(t.speaker:skill_level("elona.stat_charisma") * 25 + 100 + Chara.player():calc("fame") / 10)
         return "confirm"
      end,
      confirm = {
         text = function(t, state)
            return {
               I18N.get("talk.npc.prostitute.buy", state.cost, t.speaker)
            }
         end,
         choices = function(t, state)
            local choices = {}

            if Chara.player().gold >= state.cost then
               Dialog.add_choice("accept", "talk.npc.common.sex.choices.accept", choices)
            end
            Dialog.add_choice("elona.default:you_kidding", "talk.npc.common.sex.choices.go_back", choices)

            return choices
         end
      },
      accept = {
         on_start = function(t, state)
            -- >>>>>>>> shade2/chat.hsp:2931 		snd sePayGold : cGold(cc)-=sexValue:cGold(tc)+=s ...
            Gui.play_sound("base.paygold1")
            Chara.player().gold = Chara.player().gold - state.cost
            t.speaker.gold = t.speaker.gold + state.cost
            -- <<<<<<<< shade2/chat.hsp:2931 		snd sePayGold : cGold(cc)-=sexValue:cGold(tc)+=s ..
         end,
         text = "talk.npc.common.sex.start",
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:2933 		cc=tc:tc=pc:gosub *sexsex:cc=pc: goto *chat_end ...
            ElonaAction.do_sex(t.speaker, Chara.player())
            -- <<<<<<<< shade2/chat.hsp:2933 		cc=tc:tc=pc:gosub *sexsex:cc=pc: goto *chat_end ...
         end

      }
   }
}
