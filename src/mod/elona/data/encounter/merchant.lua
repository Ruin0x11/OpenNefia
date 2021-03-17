local Rand = require("api.Rand")
local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Effect = require("mod.elona.api.Effect")
local Skill = require("mod.elona_sys.api.Skill")
local Charagen = require("mod.elona.api.Charagen")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Event = require("api.Event")
local ElonaQuest = require("mod.elona.api.ElonaQuest")

data:add {
   _type = "elona.encounter",
   _id = "merchant",

   encounter_level = function()
      -- >>>>>>>> shade2/action.hsp:685 			encounterLv=10+rnd(100) ...
      return 10 + Rand.rnd(100)
      -- <<<<<<<< shade2/action.hsp:685 			encounterLv=10+rnd(100) ..
   end,

   on_map_entered = function(map, level, outer_map, outer_x, outer_y)
      local player = Chara.player()

      -- >>>>>>>> shade2/map.hsp:1623 			flt  ...
      local merchant = Chara.create("elona.shopkeeper", 10, 11, nil, map)
      merchant:add_role("elona.shopkeeper", { inventory_id = "elona.wandering_merchant" })
      merchant.shop_rank = level
      merchant.name = I18N.get("chara.job.wandering_vendor", merchant.name)
      Effect.generate_money(merchant)
      for _ = 1, level / 2 + 1 do
         Skill.gain_level(merchant)
      end

      for _ = 1, 6 + Rand.rnd(6) do
         local filter = {
            initial_level = level + Rand.rnd(6),
            tag_filters = { "shopguard" }
         }
         local guard = Charagen.create(14, 11, filter, map)
         if guard then
            guard:add_role("elona.shop_guard") -- Prevents incognito from having an effect
            guard.name = ("%s Lv%d"):format(guard.name, guard.level)
         end
      end

      local event = function()
         -- >>>>>>>> shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ...
         local map_ = player:current_map()
         if map_.uid == map.uid then
            local merchant_ = Chara.find("elona.shopkeeper", "all", map_)
            Dialog.start(merchant_)
         end
         -- <<<<<<<< shade2/main.hsp:1680 	tc=findChara(idShopKeeper) : gosub *chat ..
      end

      DeferredEvent.add(event)
      -- <<<<<<<< shade2/map.hsp:1636 	 ..
   end
}

local function is_wandering_merchant(chara)
   return chara:iter_roles("elona.shopkeeper"):any(function(role) return role.inventory_id == "elona.wandering_merchant" end)
end

local function exit_merchant_encounter(_, params, result)
   if params.talk.dialog._id == "elona.default" and is_wandering_merchant(params.talk.speaker) then
      if result.node_id == "__END__" then
         ElonaQuest.travel_to_previous_map()
      end
   end
   return result
end
Event.register("elona_sys.on_step_dialog", "Exit merchant encounter on dialog end", exit_merchant_encounter)

local function add_attack_dialog_option(speaker, _, choices)
   -- >>>>>>>> shade2/chat.hsp:2217 		if cRole(tc)=cRoleShopWander:chatList 31,lang("襲 ...
   if is_wandering_merchant(speaker) then
      Dialog.add_choice("elona.wandering_merchant:attack_confirm", "talk.npc.shop.choices.attack", choices)
   end
   -- <<<<<<<< shade2/chat.hsp:2217 		if cRole(tc)=cRoleShopWander:chatList 31,lang("襲 ..
   return choices
end
Event.register("elona.calc_dialog_choices", "Add attack option for wandering merchant",
               add_attack_dialog_option, {priority = 210000})

data:add {
   _type = "elona_sys.dialog",
   _id = "wandering_merchant",

   nodes = {
      -- >>>>>>>> shade2/chat.hsp:2583 		listMax=0 ...
      attack_confirm = {
         text = "talk.npc.shop.attack.dialog",
         choices = {
            {"attack", "talk.npc.shop.attack.choices.attack"},
            {"elona.default:you_kidding", "talk.npc.shop.attack.choices.go_back"}
         }
      },
      -- <<<<<<<< shade2/chat.hsp:2588 		if chatVal!1:buff=strKidding:goto *chat_default ..
      attack = function(t)
         -- >>>>>>>> shade2/chat.hsp:2590 		goHostile ...
         Effect.turn_guards_hostile(t.speaker:current_map())
         return "__END__"
         -- <<<<<<<< shade2/chat.hsp:2591 		goto *chat_end ..
      end
   }
}
