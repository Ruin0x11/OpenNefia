local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Filters = require("mod.elona.api.Filters")
local Itemgen = require("mod.elona.api.Itemgen")
local I18N = require("api.I18N")
local Quest = require("mod.elona_sys.api.Quest")
local Gui = require("api.Gui")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local Event = require("api.Event")
local Itemname = require("mod.elona.api.Itemname")
local ElonaItem = require("mod.elona.api.ElonaItem")

local supply = {
   _id = "supply",
   _type = "elona_sys.quest",

   elona_id = 1004,
   ordering = 100000,
   client_chara_type = 3,
   reward = "elona.supply",
   reward_fix = 65,

   min_fame = 0,
   chance = 5,

   params = {
      target_item_id = "string"
   },

   difficulty = function() return math.clamp(Rand.rnd(Chara.player():calc("level") + 5) + 1, 1, 30) end,

   expiration_hours = function() return (Rand.rnd(3) + 1) * 24 end,
   deadline_days = function() return Rand.rnd(6) + 2 end,

   locale_data = function(self)
      return {
         objective = Itemname.qualify_article(Itemname.qualify_name(self.params.target_item_id)),
      }
   end
}

function supply.generate(self, client, start)
   local category = Rand.choice(Filters.fsetsupply)
   local item_id = Itemgen.random_item_id_raw(nil, {category})
   assert(item_id)

   self.reward_fix = self.reward_fix + self.difficulty

   self.params = {
      target_item_id = item_id,
   }

   return true
end

data:add(supply)

local function supply_quest_for(chara)
   local function is_quest_client(q)
      return q._id == "elona.supply" and q.client_uid == chara.uid
   end
   return Quest.iter():filter(is_quest_client):nth(1)
end

local function find_item(chara, item_id)
   return chara:iter_inventory():filter(function(i) return i._id == item_id end):nth(1)
end

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_supply",

   root = "talk.npc.quest_giver",
   nodes = {
      trade = function(t)
         Gui.mes_c("TODO", "Yellow")
      end,
      give = function(t)
         -- TODO generalize with dialog argument
         local quest = supply_quest_for(t.speaker)
         assert(quest)

         local item = find_item(Chara.player(), quest.params.target_item_id)

         Gui.mes("talk.npc.common.hand_over", item)
         ElonaItem.ensure_free_item_slot(t.speaker)
         local sep = assert(item:move_some(1, t.speaker))
         t.speaker.item_to_use = sep
         t.speaker.was_passed_quest_item = true

         Chara.player():refresh_weight()

         return Quest.complete(quest, t.speaker)
      end
   }
}

local function add_give_dialog_choice(speaker, _, choices)
   local quest = supply_quest_for(speaker)
   if quest then
      local item = find_item(Chara.player(), quest.params.target_item_id)
      if item then
         Dialog.add_choice("elona.quest_supply:give", I18N.get("talk.npc.quest_giver.choices.here_is_item", item:build_name(1)), choices)
      end
   end
   return choices
end

Event.register("elona.calc_dialog_choices", "Add give option for supply quest client",
               add_give_dialog_choice)
