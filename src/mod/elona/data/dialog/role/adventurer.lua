local Adventurer = require("mod.elona.api.Adventurer")
local I18N = require("api.I18N")
local Chara = require("api.Chara")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Gui = require("api.Gui")
local Enum = require("api.Enum")
local World = require("api.World")
local Const = require("api.Const")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Anim = require("mod.elona_sys.api.Anim")
local Mef = require("api.Mef")
local Effect = require("mod.elona.api.Effect")
local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")
local Calc = require("mod.elona.api.Calc")
local Skill = require("mod.elona_sys.api.Skill")
local Map = require("api.Map")
local Magic = require("mod.elona_sys.api.Magic")

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
      },

      -- House guest dialog

      guest_new_years = {
         text = {
            "talk.visitor.adventurer.new_year.happy_new_year",
            "talk.visitor.adventurer.new_year.gift"
         },
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:100 		flt:item_create -1,idNewYear,cX(pc),cY(pc):if st ...
            local player = Chara.player()
            local map = player:current_map()

            local gift = Item.create("elona.new_years_gift", player.x, player.y, {}, map)
            if gift then
               local impression = t.speaker:calc("impression")
               gift.params.new_years_gift_quality = impression + Rand.rnd(50)
               Gui.mes("talk.visitor.adventurer.new_year.throws", t.speaker, gift:build_name(1))
            end
            -- <<<<<<<< shade2/chat.hsp:101 		txt lang(name(tc)+"は"+itemName(ci,1)+"を置いていった。", ..
         end
      },

      guest_hate = {
         text = "talk.visitor.adventurer.hate.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:107 	if (cImpression(tc)<defImpHate){ ...
            local adv = t.speaker
            local map = adv:current_map()
            Gui.mes("talk.visitor.adventurer.hate.text", adv)
            if Rand.one_in(2) then
               for _ = 1, 28 do
                  local tx = adv.x + Rand.rnd(3) - Rand.rnd(3)
                  local ty = adv.y + Rand.rnd(3) - Rand.rnd(3)
                  if map:is_in_bounds(tx, ty) then
                     if tx ~= adv.x and ty ~= adv.y then
                        Gui.mes("talk.visitor.adventurer.hate.throws", adv)
                        Gui.play_sound("base.throw2", adv.x, adv.y)
                        local cb = Anim.ranged_attack(adv.x, adv.y, tx, ty, "elona.item_molotov", nil)
                        Gui.start_draw_callback(cb)
                        Mef.create("elona.fire", tx, ty, { duration = Rand.rnd(15) + 20, power = 50 }, map)
                        Effect.damage_map_fire(tx, ty, adv, map)
                     end
                  end
               end
            else
               for _ = 1, 8 + Rand.rnd(6) do
                  local vomit = Item.create("elona.vomit", nil, nil, {}, map)
                  if vomit then
                     Gui.mes("food.vomits", adv)
                     Gui.play_sound("base.vomit", vomit.x, vomit.y)
                     Gui.wait(10)
                  end
               end
            end
            -- <<<<<<<< shade2/chat.hsp:128 		} ..
         end
      },

      guest_token_of_friendship = {
         text = "talk.visitor.adventurer.like.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:132 		cBitMod cTokenFriend,tc,true ...
            local adv = t.speaker
            local player = Chara.player()
            local map = player:current_map()
            local flags = adv:get_aspect_or_default(ICharaElonaFlags, true)
            local token = Item.create("elona.token_of_friendship", player.x, player.y, {}, map)
            if token then
               flags.has_given_token_of_friendship = true
               Gui.mes("talk.visitor.receive", token:build_name(1), adv)
               Gui.mes("talk.visitor.adventurer.like.wonder_if")
            end
            -- <<<<<<<< shade2/chat.hsp:136 		listMax=0 ..
         end
      },

      guest_train = function(t, state)
         -- >>>>>>>> shade2/chat.hsp:140 		advFavoriteSkill tc:csSkill=rtval(rnd(stat)) ...
         local role = assert(t.speaker:find_role("elona.adventurer"))
         local skill_ids = assert(role.favorite_skill_ids)
         state.skill_id = Rand.choice(skill_ids)
         if t.speaker:calc("impression") >= Const.IMPRESSION_SOULMATE and Rand.one_in(3) then
            state.skill_id = assert(role.favorite_stat_id)
         end
         -- <<<<<<<< shade2/chat.hsp:141 		if cImpression(tc)>=defImpSoulMate:if rnd(3)=0:a ..

         local player = Chara.player()
         if player:has_skill(state.skill_id) then
            state.cost = Calc.calc_train_cost(state.skill_id, player)
            return "guest_train_train"
         else
            state.cost = Calc.calc_learn_cost(state.skill_id, player)
            return "guest_train_learn"
         end
      end,
      guest_train_train = {
         text = function(t, state)
            local skill_name = I18N.localize("base.skill", state.skill_id, "name")
            return {I18N.get("talk.visitor.adventurer.train.train.dialog", skill_name, state.cost, t.speaker)}
         end,
         choices = function(t, state)
            local choices = {}

            if Chara.player().platinum >= state.cost then
               Dialog.add_choice("guest_train_train_yes", "talk.visitor.adventurer.train.choices.train", choices)
            end
            Dialog.add_choice("guest_train_no", "talk.visitor.adventurer.train.choices.pass", choices)

            return choices
         end,
         default_choice = "guest_train_no"
      },
      guest_train_train_yes = {
         on_start = function(t, state)
            -- >>>>>>>> shade2/chat.hsp:164 			cPlat(pc)-=calcTrainCost(csSkill,pc,1) ...
            local player = Chara.player()
            player.platinum = math.max(math.floor(player.platinum - state.cost), 0)

            local skill_proto = data["base.skill"]:ensure(state.skill_id)
            local delta = math.floor(15 - player:skill_potential(state.skill_id) / 15)
            local limit = 15
            if skill_proto.type == "stat" then
               limit = 5
            end
            delta = math.clamp(delta, 2, limit)

            Skill.modify_potential(player, state.skill_id, delta)
            -- <<<<<<<< shade2/chat.hsp:165 			modGrowth cc,csSkill,limit(15-sGrowth(csSkill,c ..

            local the = I18N.get("magic.gain_skill_potential.the")
            local skill_name = I18N.localize("base.skill", state.skill_id, "name")

            Gui.play_sound("base.ding2", player.x, player.y)
            if skill_proto.type == "stat" then
               Gui.mes_c("magic.gain_potential.increases", "Green", player, skill_name)
            else
               Gui.mes_c(the .. I18N.get("magic.gain_skill_potential.increases", player, skill_name), "Green")
            end
         end,
         text = "talk.visitor.adventurer.train.train.after",
         choices = {
            {"__END__", "ui.more"}
         },
      },
      guest_train_learn = {
         text = function(t, state)
            local skill_name = I18N.localize("base.skill", state.skill_id, "name")
            return {I18N.get("talk.visitor.adventurer.train.learn.dialog", skill_name, state.cost, t.speaker)}
         end,
         choices = function(t, state)
            local choices = {}

            if Chara.player().gold >= state.cost then
               Dialog.add_choice("guest_train_learn_yes", "talk.visitor.adventurer.train.choices.learn", choices)
            end
            Dialog.add_choice("guest_train_no", "talk.visitor.adventurer.train.choices.pass", choices)

            return choices
         end,
         default_choice = "guest_train_no"
      },
      guest_train_learn_yes = {
         on_start = function(t, state)
            -- >>>>>>>> shade2/chat.hsp:158 			cPlat(pc)-=calcLearnCost(csSkill,pc,1) ...
            local player = Chara.player()
            player.platinum = math.max(math.floor(player.platinum - state.cost), 0)
            Skill.gain_skill(player, state.skill_id)
            save.elona.total_skills_learned = save.elona.total_skills_learned + 1
            -- <<<<<<<< shade2/chat.hsp:159 			skillGain cc,csSkill:gLearned++ ..
         end,
         text = "talk.visitor.adventurer.train.learn.after",
         choices = {
            {"__END__", "ui.more"}
         },
      },
      guest_train_no = {
         text = "talk.visitor.adventurer.train.pass",
         choices = {
            {"__END__", "ui.more"}
         },
      },

      guest_friendship = {
         text = "talk.visitor.adventurer.friendship.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:173 		if inv_getFreeId(-1)=falseM{ ...
            local adv = t.speaker
            local player = Chara.player()
            local map = player:current_map()
            if not Map.can_drop_items(map) then
               Gui.mes("talk.visitor.adventurer.friendship.no_empty_spot")
            else
               local item_id
               if Rand.one_in(4) then
                  item_id = "elona.small_medal"
               else
                  item_id = "elona.platinum_coin"
               end

               local coin = assert(Item.create(item_id, player.x, player.y, {}, map))
               Gui.mes("talk.visitor.receive", coin:build_name(1), adv)
               Gui.play_sound("base.get1", player.x, player.y)
            end
            -- <<<<<<<< shade2/chat.hsp:180 			} ..
         end
      },

      guest_souvenir = {
         text = "talk.visitor.adventurer.souvenir.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:186 		if inv_getFreeId(pc)=falseM{ ...
            local player = Chara.player()
            if player:is_inventory_full() then
               Gui.mes("talk.visitor.adventurer.souvenir.inventory_is_full")
            else
               local gift = assert(Item.create("elona.gift", nil, nil, {}, player))
               Gui.mes("talk.visitor.adventurer.souvenir.receive", gift:build_name(1))
               Gui.play_sound("base.get1", player.x, player.y)
            end
            -- <<<<<<<< shade2/chat.hsp:192 			} ..
         end
      },

      guest_materials = {
         text = "talk.visitor.adventurer.materials.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:198 		txt lang(name(tc)+"は色々なものが詰まった袋を、あなたに手渡した。",name ...
            local adv = t.speaker
            Gui.mes("talk.visitor.adventurer.materials.receive", adv)
            Magic.cast("elona.effect_create_material", { power = 100, target = Chara.player() })
            -- <<<<<<<< shade2/chat.hsp:199 		call effect,(efId=efMakeMaterial,efP=100,tc=pc) ..
         end
      },

      guest_favorite_skill = {
         text = function(t)
            -- >>>>>>>> shade2/chat.hsp:204 		advFavoriteSkill tc:csSkill=rtval(rnd(stat)) ...
            local role = assert(t.speaker:find_role("elona.adventurer"))
            local skill_ids = assert(role.favorite_skill_ids)
            local skill_id = Rand.choice(skill_ids)
            local skill_name = I18N.localize("base.skill", skill_id, "name")
            return {I18N.get("talk.visitor.adventurer.favorite_skill.dialog", skill_name, t.speaker)}
            -- <<<<<<<< shade2/chat.hsp:205 		chatMore lang(skillName(csSkill)+"は"+_ore(3)+"の得 ..
         end,
         choices = {
            {"__END__", "ui.more"}
         },
      },

      guest_favorite_stat = {
         text = function(t)
            -- >>>>>>>> shade2/chat.hsp:210 		advFavoriteStat tc:csSkill=stat ...
            local role = assert(t.speaker:find_role("elona.adventurer"))
            local skill_id = assert(role.favorite_stat_id)
            local skill_name = I18N.localize("base.skill", skill_id, "name")
            return {I18N.get("talk.visitor.adventurer.favorite_stat.dialog", skill_name, t.speaker)}
            -- <<<<<<<< shade2/chat.hsp:211 		chatMore lang(_ore(3)+"は"+skillName(csSkill)+"が自 ..
         end,
         choices = {
            {"__END__", "ui.more"}
         },
      },

      guest_conversation = {
         text = "talk.visitor.adventurer.conversation.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            -- >>>>>>>> shade2/chat.hsp:217 			txt lang("あなたと"+name(tc)+"は愉快に語り合った！","You hold ...
            Gui.mes("talk.visitor.adventurer.conversation.hold", t.speaker)
            Skill.modify_impression(t.speaker, 10)
            -- <<<<<<<< shade2/chat.hsp:218 			modImp tc,10:swbreak ..
         end
      },

      guest_drinking_party = {
         text = "talk.visitor.adventurer.drink.dialog",
         choices = {
            {"__END__", "ui.more"}
         },
         on_finish = function(t)
            local adv = t.speaker
            local player = Chara.player()
            Gui.play_sound("base.drink1", player.x, player.y)
            if config.base.positional_audio then
               Gui.play_sound("base.drink1", adv.x, adv.y)
            end

            Gui.mes_c("magic.alcohol.normal", "SkyBlue")

            adv:apply_effect("elona.drunk", 1000)
            player:apply_effect("elona.drunk", 1000)
            Skill.modify_impression(adv, 15)
         end
      },
   }
}
