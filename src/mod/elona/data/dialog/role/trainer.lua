local Gui = require("api.Gui")
local Skill = require("mod.elona_sys.api.Skill")
local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local I18N = require("api.I18N")

local function train_skill(player, skill_id, cost)
   Gui.play_sound("base.paygold1")
   -- >>>>>>>> shade2/chat.hsp:3095 			cPlat(pc)-=calcTrainCost(csSkill,cc) ..
   player.platinum = player.platinum - cost
   Skill.gain_skill(player, skill_id)
   save.elona.total_skills_learned = save.elona.total_skills_learned + 1
   -- <<<<<<<< shade2/chat.hsp:3096 			modGrowth cc,csSkill,limit(15-sGrowth(csSkill,c ..
end

local function learn_skill(player, skill_id, cost)
   Gui.play_sound("base.paygold1")
   -- >>>>>>>> shade2/chat.hsp:3095 			cPlat(pc)-=calcTrainCost(csSkill,cc) ..
   player.platinum = player.platinum - cost
   local amount = math.clamp(15 - player:skill_potential(skill_id) / 15, 2, 15)
   Skill.modify_potential(player, skill_id, amount)
   -- <<<<<<<< shade2/chat.hsp:3096 			modGrowth cc,csSkill,limit(15-sGrowth(csSkill,c ..
end

data:add {
   _type = "elona_sys.dialog",
   _id = "trainer",

   nodes = {
      -- >>>>>>>> shade2/chat.hsp:3076 *chat_train ..
      train = function(t, state)
         local result, canceled = CharacterInfoMenu:new(Chara.player(), "trainer_train", {}):query()
         if result and not canceled then
            state.skill_id = result._id
            state.cost = Calc.calc_train_cost(result._id, Chara.player())
            return "train_confirm"
         end
         return "come_again"
      end,
      train_confirm = {
         text = function(t, state)
            local skill_name = I18N.localize("base.skill", state.skill_id, "name")
            return {
               I18N.get("talk.npc.trainer.cost.training", skill_name, state.cost)
            }
         end,
         choices = function(t, state)
            local choices = {}

            if Chara.player().platinum >= state.cost then
               table.insert(choices, { "train_accept", "talk.npc.trainer.choices.train.accept" })
            end
            table.insert(choices, { "come_again", "talk.npc.trainer.choices.go_back" })

            return choices
         end
      },
      train_accept = {
         on_start = function(t, state)
            learn_skill(Chara.player(), state.skill_id, state.cost)
         end,
         text = "talk.npc.trainer.finish.training",
         jump_to = "elona.default:__start"
      },
      learn = function(t, state)
         local trainer_skills = Calc.calc_trainer_skills(t.speaker, Chara.player())
         local result, canceled = CharacterInfoMenu:new(Chara.player(), "trainer_learn", { trainer_skills = trainer_skills }):query()
         if result and not canceled then
            state.skill_id = result._id
            state.cost = Calc.calc_learn_cost(result._id, Chara.player())
            return "learn_confirm"
         end
         return "come_again"
      end,
      learn_confirm = {
         text = function(t, state)
            local skill_name = I18N.localize("base.skill", state.skill_id, "name")
            return {
               I18N.get("talk.npc.trainer.cost.learning", skill_name, state.cost)
            }
         end,
         choices = function(t, state)
            local choices = {}

            if Chara.player().platinum >= state.cost then
               table.insert(choices, { "learn_accept", "talk.npc.trainer.choices.learn.accept" })
            end
            table.insert(choices, { "come_again", "talk.npc.trainer.choices.go_back" })

            return choices
         end
      },
      learn_accept = {
         on_start = function(t, state)
            train_skill(Chara.player(), state.skill_id, state.cost)
         end,
         text = "talk.npc.trainer.finish.learning",
         jump_to = "elona.default:__start"
      },
      come_again = {
         text = "talk.npc.trainer.leave",
         jump_to = "elona.default:__start"
      }
   }
   -- <<<<<<<< shade2/chat.hsp:3107 	goto *chat_default ..
}
