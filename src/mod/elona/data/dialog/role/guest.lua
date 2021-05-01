local Chara = require("api.Chara")
local Skill = require("mod.elona_sys.api.Skill")
local Rand = require("api.Rand")
local I18N = require("api.I18N")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Gui = require("api.Gui")
local Effect = require("mod.elona.api.Effect")
local ElonaAction = require("mod.elona.api.ElonaAction")
local ShopInventory = require("mod.elona.api.ShopInventory")
local Input = require("api.Input")

data:add {
   _type = "base.role",
   _id = "guest_citizen"
}
data:add {
   _type = "elona_sys.dialog",
   _id = "guest_citizen",

   nodes = {
      __start = {
         text = "talk.visitor.just_visiting",
         choices = {
            {"__END__", "ui.more"}
         }
      }
   }
}

data:add {
   _type = "base.role",
   _id = "guest_trainer"
}
data:add {
   _type = "elona_sys.dialog",
   _id = "guest_trainer",

   nodes = {
      __start = function(t, state)
         if save.elona.date_of_last_guest_trainer_visit.month == save.base.date.month then
            return "no_more_training"
         end

         save.elona.date_of_last_guest_trainer_visit = save.base.date:clone()

         local platinum_cost = 3
         local default_skills = Skill.iter_base_attributes():to_list()
         local skills = {}
         local i = Rand.rnd(#default_skills - 2) + 1
         for j = i, i + 2 do
            skills[#skills+1] = default_skills[j]._id
         end

         local guild_id = Chara.player():calc("guild")
         if guild_id then
            local guild_data = data["elona.guild"]:ensure(guild_id)
            if guild_data.guest_trainer_skills then
               skills = guild_data.guest_trainer_skills
            end
         else
            platinum_cost = 4
         end

         state.guild_id = guild_id
         state.skill_ids = skills
         state.cost = platinum_cost

         return "train"
      end,

      no_more_training = {
         text = "talk.visitor.trainer.no_more_this_month",
         choices = {
            {"__END__", "ui.more"}
         },
      },

      train = {
         text = function(t, state)
            local text
            if state.guild_id then
               local guild_name = I18N.localize("elona.guild", state.guild_id, "name")
               text = I18N.get("talk.visitor.trainer.dialog.member", guild_name, state.cost, t.speaker)
            else
               text = I18N.get("talk.visitor.trainer.dialog.nonmember", state.cost, t.speaker)
            end
            return {text}
         end,
         choices = function(t, state)
            local choices = {}

            Dialog.add_choice("not_today", "talk.visitor.trainer.choices.not_today", choices)

            if Chara.player().platinum >= state.cost then
               for _, skill_id in ipairs(state.skill_ids) do
                  local params = {
                     skill_id = skill_id
                  }
                  local skill_name = I18N.localize("base.skill", skill_id, "name")
                  local text = I18N.get("talk.visitor.trainer.choices.improve", skill_name)
                  Dialog.add_choice("improve", text, choices, params)
               end
            end

            return choices
         end,
         default_choice = "not_today"
      },
      not_today = {
         text = "talk.visitor.trainer.regret",
         choices = {
            {"__END__", "ui.more"}
         }
      },
      improve = {
         on_start = function(t, state, params)
            assert(params.skill_id)
            local player = Chara.player()
            player.platinum = math.max(math.floor(player.platinum - state.cost), 0)
            Gui.play_sound("base.ding3")
            local skill_name = I18N.localize("base.skill", params.skill_id, "name")
            Gui.mes_c("talk.visitor.trainer.potential_expands", "Green", player, skill_name)
            Skill.modify_potential(player, params.skill_id, 10)
         end,
         text = "talk.visitor.trainer.after",
         choices = {
            {"__END__", "ui.more"}
         }
      }
   }
}

data:add {
   _type = "base.role",
   _id = "guest_beggar"
}
data:add {
   _type = "elona_sys.dialog",
   _id = "guest_beggar",

   nodes = {
      __start = {
         text = "talk.visitor.beggar.dialog",
         choices = {
            {"give_yes", "talk.visitor.choices.yes"},
            {"give_no", "talk.visitor.choices.no"}
         }
      },

      give_yes = {
         on_start = function(t)
            local player = Chara.player()
            local beggar = t.speaker
            local gold_amount = math.max(math.floor(player.gold / 20), 0) + 1
            Gui.mes("talk.visitor.beggar.spare", gold_amount, beggar)
            player.gold = math.max(player.gold - gold_amount, 0)
            Gui.play_sound("base.paygold1")
            beggar.gold = beggar.gold + gold_amount
            Effect.modify_karma(player, 2)
         end,
         text = "talk.visitor.beggar.after"
      },
      give_no = {
         text = "talk.visitor.beggar.cheap",
         choices = {
            {"__END__", "ui.more"}
         }
      }
   }
}

data:add {
   _type = "base.role",
   _id = "guest_punk"
}
data:add {
   _type = "elona_sys.dialog",
   _id = "guest_punk",

   nodes = {
      __start = {
         text = "talk.visitor.punk.dialog",
         choices = {
            {"sex_yes", "talk.visitor.choices.yes"},
            {"sex_no", "talk.visitor.choices.no"}
         }
      },

      sex_yes = {
         text = "talk.npc.common.sex.start",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            ElonaAction.do_sex(Chara.player(), t.speaker)
         end
      },
      sex_no = {
         text = "talk.visitor.punk.hump",
         choices = {
            {"__END__", "ui.more"}
         },
      }
   }
}

data:add {
   _type = "base.role",
   _id = "guest_producer"
}
data:add {
   _type = "elona_sys.dialog",
   _id = "guest_producer",

   nodes = {
      __start = {
         text = "talk.visitor.mysterious_producer.want_to_be_star",
         choices = {
            {"sex_yes", "talk.visitor.choices.yes"},
            {"sex_no", "talk.visitor.choices.no"}
         }
      },

      sex_yes = {
         text = "talk.visitor.mysterious_producer.no_turning_back",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            ElonaAction.do_sex(Chara.player(), t.speaker)
         end
      },
      sex_no = {
         text = "talk.visitor.punk.hump",
         choices = {
            {"__END__", "ui.more"}
         },
      }
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "guest_merchant",

   nodes = {
      __start = {
         text = "talk.visitor.merchant.dialog",
         choices = {
            {"buy", "talk.npc.shop.choices.buy"},
            {"sell", "talk.npc.shop.choices.sell"},
            {"not_now", "talk.visitor.merchant.choices.not_now"}
         },
         default_choice = "not_now"
      },

      buy = function(t)
         if t.speaker.shop_inventory == nil then
            ShopInventory.refresh_shop(t.speaker)
         end

         Input.query_inventory(Chara.player(), "elona.inv_buy", {target=t.speaker, shop=t.speaker.shop_inventory})
         return "__start"
      end,

      sell = function(t)
         Input.query_inventory(Chara.player(), "elona.inv_sell", {target=t.speaker})
         return "__start"
      end,

      not_now = {
         text = "talk.visitor.merchant.regret",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:327 	cRole(tc)=cRoleGuestCitizen ...
            t.speaker:remove_all_roles("elona.shopkeeper")
            t.speaker:add_role("elona.guest_citizen")
            -- <<<<<<<< shade2/chat.hsp:327 	cRole(tc)=cRoleGuestCitizen ..
         end
      }
   }
}
