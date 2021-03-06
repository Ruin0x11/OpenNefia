local Map = require("api.Map")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Const = require("api.Const")
local Hunger = require("mod.elona.api.Hunger")
local Magic = require("mod.elona_sys.api.Magic")
local Skill = require("mod.elona_sys.api.Skill")
local Itemgen = require("mod.tools.api.Itemgen")
local Filters = require("mod.elona.api.Filters")
local Item = require("api.Item")
local Effect = require("mod.elona.api.Effect")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local CodeGenerator = require("api.CodeGenerator")

data:add_type {
   name = "random_event",
   fields = {
         {
            name = "image",
            type = "id:base.asset",
            template = true,
         },
         {
            name = "on_event_triggered",
            type = "function",
            default = CodeGenerator.gen_literal [[
function()
end
]],
            template = true
         },
         {
            name = "choice_count",
            type = "integer",
            default = 1,
            template = true,
         },
         {
            name = "choices",
            type = "table?",
            default = nil,
            template = true,
         },
   }
}

data:add {
   _type = "elona.random_event",
   _id = "murderer",

   image = "base.bg_re9",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:90 	repeat 20 ...
      local map = Map.current()

      local choices = Chara.iter_others():to_list()

      for _ = 1, 20 do
         local victim = Rand.choice(choices)
         if Chara.is_alive(victim, map) then
            Gui.mes("random_event._.elona.murderer.scream")
            victim:damage_hp(math.max(victim:calc("max_hp"), 99999), "elona.unknown")
            break
         end
      end
      -- <<<<<<<< shade2/event.hsp:94 	loop ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "strange_feast",

   image = "base.bg_re10",

   choice_count = 2,
   choices = {
      [1] = function()
         -- >>>>>>>> shade2/event.hsp:107 	if rtval=1{ ...
         local player = Chara.player()
         player.nutrition = Const.INNKEEPER_MEAL_NUTRITION
         Gui.mes("talk.npc.innkeeper.eat.results")
         Hunger.show_eating_message(player)
         Hunger.proc_anorexia(player)
         -- <<<<<<<< shade2/event.hsp:111 		} ..
      end
   }
}

data:add {
   _type = "elona.random_event",
   _id = "smell_of_food",

   image = "base.bg_re10",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:117 	cHunger(pc)-=5000  ...
      local player = Chara.player()
      player.nutrition = player.nutrition - 5000
      -- <<<<<<<< shade2/event.hsp:117 	cHunger(pc)-=5000  ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "avoiding_misfortune",

   image = "base.bg_re8",
}

data:add {
   _type = "elona.random_event",
   _id = "your_potential",

   image = "base.bg_re4",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:130 	call effect,(efId=efPotential,tc=pc) ...
      Magic.cast("elona.effect_gain_potential", { target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:130 	call effect,(efId=efPotential,tc=pc) ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "gaining_faith",

   image = "base.bg_re12",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:138 	skillExp rsPrayer,pc,1000,6,1000 ...
      Skill.gain_skill_exp(Chara.player(), "elona.faith", 1000, 6, 1000)
      -- <<<<<<<< shade2/event.hsp:138 	skillExp rsPrayer,pc,1000,6,1000 ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "small_luck",

   image = "base.bg_re3",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:148 	call effect,(efId=efMakeMaterial,efP=100,tc=pc) ...
      Magic.cast("elona.effect_create_material", { power = 100, target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:148 	call effect,(efId=efMakeMaterial,efP=100,tc=pc) ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "dream_harvest",

   image = "base.bg_re3",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:154 	call effect,(efId=efMakeMaterial,efP=200,tc=pc) ...
      Magic.cast("elona.effect_create_material", { power = 200, target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:154 	call effect,(efId=efMakeMaterial,efP=200,tc=pc) ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "camping_site",

   image = "base.bg_re3",

   choice_count = 2,
   choices = {
      [1] = function()
         -- >>>>>>>> shade2/event.hsp:168 	if rtval=1{ ...
         local player = Chara.player()
         local map = player:current_map()
         for _ = 1, 1 + Rand.rnd(4) do
            Itemgen.create(player.x, player.y, { categories = Rand.choice(Filters.fsetremain) }, map)
         end
         Gui.mes("common.something_is_put_on_the_ground")
         -- <<<<<<<< shade2/event.hsp:173 		} ..
      end
   }
}

data:add {
   _type = "elona.random_event",
   _id = "creepy_dream",

   image = "base.bg_re5",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:177 	snd seCurse2 ...
      Gui.play_sound("base.curse2")
      Magic.cast("elona.effect_weaken_resistance", { power = 100, target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:178 	call effect,(efId=efLooseResist,efP=100,tc=pc) ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "monster_dream",

   image = "base.bg_re2",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:186 	snd seCurse2 ...
      Gui.play_sound("base.curse2")
      Magic.cast("elona.mutation", { power = 100, target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:187 	call effect,(efId=spMutation,efP=100,tc=pc) ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "treasure_of_dream",

   image = "base.bg_re15",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:195 	flt:item_create pc,idTreasureMap:txt lang(itemNam ...
      local treasure_map = Item.create("elona.treasure_map", nil, nil, {}, Chara.player())
      if treasure_map then
         Gui.mes("common.you_put_in_your_backpack", treasure_map:build_name(1))
      end
      -- <<<<<<<< shade2/event.hsp:195 	flt:item_create pc,idTreasureMap:txt lang(itemNam ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "lucky_day",

   image = "base.bg_re12",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:203 	addBuff tc,buffLucky,777,1500 ...
      Effect.add_buff(Chara.player(), Chara.player(), "elona.lucky", 777, 1500)
      -- <<<<<<<< shade2/event.hsp:203 	addBuff tc,buffLucky,777,1500 ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "quirk_of_fate",

   image = "base.bg_re15",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:211 	flt:item_create pc,idStatueLuck:txt lang(itemName ...
      local statue = Item.create("elona.statue_of_ehekatl", nil, nil, {}, Chara.player())
      if statue then
         Gui.mes("common.you_put_in_your_backpack", statue:build_name(1))
      end
      -- <<<<<<<< shade2/event.hsp:211 	flt:item_create pc,idStatueLuck:txt lang(itemName ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "cursed_whispering",

   image = "base.bg_re5",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:219 	if trait(traitResCurse){ ...
      local player = Chara.player()
      if player:trait_level("elona.res_curse") > 0 then
         Gui.mes("random_event._.elona.cursed_whispering.no_effect")
      else
         if player:iter_equipment():length() > 0 then
            Magic.cast("elona.effect_curse", { source = player, target = player, power = 200 })
         elseif not DeferredEvent.is_pending() then
            DeferredEvent.add(DeferredEvents.sleep_ambush)
         end
      end
      -- <<<<<<<< shade2/event.hsp:227 		} ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "malicious_hand",

   image = "base.bg_re9",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:235 	p=rnd(cGold(pc)/8+1):if  cBit(cResSteal,pc):p=0 ...
      local player = Chara.player()

      local stolen_amount = Rand.rnd(player.gold / 8 + 1)
      if player:calc("is_protected_from_theft") then
         stolen_amount = 0
      end

      if stolen_amount > 0 then
         Gui.mes("random_event._.elona.malicious_hand.you_lose", stolen_amount)
         player.gold = player.gold - stolen_amount
      else
         Gui.mes("random_event._.elona.malicious_hand.no_effect")
      end
      -- <<<<<<<< shade2/event.hsp:241 		} ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "corpse",

   image = "base.bg_re7",

   choice_count = 2,
   choices = {
      [1] = function()
         -- >>>>>>>> shade2/event.hsp:255 		txt lang("あなたは遺留品をあさった。","You loot the remains." ...
         local player = Chara.player()
         local map = player:current_map()
         Gui.mes("random_event._.elona.corpse.loot")
         Effect.modify_karma(player, -2)
         for _ = 1, 1 + Rand.rnd(3) do
            local filter = {
               level = nil,
               quality = Calc.calc_object_quality(Enum.Quality.Good)
            }
            if Rand.one_in(3) then
               filter.categories = Rand.choice(Filters.fsetwear)
            else
               filter.categories = Rand.choice(Filters.fsetremain)
            end
            Itemgen.create(player.x, player.y, filter, map)
         end
         Gui.mes("common.something_is_put_on_the_ground")
         -- <<<<<<<< shade2/event.hsp:261 		txtQuestItem ..
      end,
      [2] = function()
         -- >>>>>>>> shade2/event.hsp:263 		txt lang("あなたは骨と遺留品を埋葬した。","You bury the corpse  ...
         local player = Chara.player()
         Gui.mes("random_event._.elona.corpse.bury")
         Effect.modify_karma(player, 5)
         -- <<<<<<<< shade2/event.hsp:263 		txt lang("あなたは骨と遺留品を埋葬した。","You bury the corpse  ..
      end
   }
}

data:add {
   _type = "elona.random_event",
   _id = "wizards_dream",

   image = "base.bg_re6",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:268 	call effect,(efId=efGainSpell,efP=100,tc=pc) ...
      return Magic.cast("elona.effect_gain_knowledge", { power = 100, target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:268 	call effect,(efId=efGainSpell,efP=100,tc=pc) ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "development",

   image = "base.bg_re4",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:276 	call effect,(efId=efGainGrowth,efP=100,tc=pc) ...
      return Magic.cast("elona.effect_gain_potential", { power = 100, target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:276 	call effect,(efId=efGainGrowth,efP=100,tc=pc) ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "regeneration",

   image = "base.bg_re4",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:284 	skillExp rsHealing,pc,1000 ...
      Skill.gain_skill_exp(Chara.player(), "elona.healing", 1000)
      -- <<<<<<<< shade2/event.hsp:284 	skillExp rsHealing,pc,1000 ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "meditation",

   image = "base.bg_re4",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:292 	skillExp rsMeditation,pc,1000 ...
      Skill.gain_skill_exp(Chara.player(), "elona.meditation", 1000)
      -- <<<<<<<< shade2/event.hsp:292 	skillExp rsMeditation,pc,1000 ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "great_luck",

   image = "base.bg_re1",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:300 	cPlat(pc)++ ...
      local player = Chara.player()
      player.platinum = player.platinum + 1
      -- <<<<<<<< shade2/event.hsp:300 	cPlat(pc)++ ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "mad_millionaire",

   image = "base.bg_re1",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:308 	p=rnd(cGold(pc)/10+1000)+1:cGold(pc)+=p ...
      local player = Chara.player()
      local amount = Rand.rnd(player.gold / 10 + 1000) + 1
      player.gold = player.gold + amount
      Gui.mes("random_event._.elona.mad_millionaire.you_pick_up", amount)
      -- <<<<<<<< shade2/event.hsp:309 	txt lang("金貨"+p+"枚を手に入れた。","You pick up "+p+" gol ..
   end
}

data:add {
   _type = "elona.random_event",
   _id = "wandering_priest",

   image = "base.bg_re11",

   on_event_triggered = function()
      -- >>>>>>>> shade2/event.hsp:317 	call effect,(efId=spHolyVeil,efP=800,tc=pc)	 ...
      Magic.cast("elona.buff_holy_veil", { power = 800, target = Chara.player() })
      -- <<<<<<<< shade2/event.hsp:317 	call effect,(efId=spHolyVeil,efP=800,tc=pc)	 ..
   end
}
