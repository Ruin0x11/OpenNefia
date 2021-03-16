local Event = require("api.Event")
local ShopInventory = require("mod.elona.api.ShopInventory")
local Enum = require("api.Enum")
local Weather = require("mod.elona.api.Weather")
local Calc = require("mod.elona.api.Calc")
local I18N = require("api.I18N")
local Quest = require("mod.elona_sys.api.Quest")

local role = {
   {
      _id = "shopkeeper",
      elona_id = 1,

      dialog_choices = {
         {"elona.shopkeeper:buy", "talk.npc.shop.choices.buy"},
         {"elona.shopkeeper:sell", "talk.npc.shop.choices.sell"}
      }
   },
   {
      _id = "special",
      elona_id = 3,
   },
   {
      _id = "citizen",
      elona_id = 4,
   },
   {
      _id = "identifier",
      elona_id = 5,
   },
   {
      _id = "elder",
      elona_id = 6,
   },
   {
      _id = "trainer",
      elona_id = 7,
      dialog_choices = {
         {"elona.trainer:train", "talk.npc.trainer.choices.train.ask"},
         {"elona.trainer:learn", "talk.npc.trainer.choices.learn.ask"}
      }
   },
   {
      _id = "informer",
      elona_id = 8,
   },
   {
      _id = "bartender",
      elona_id = 9,
   },
   {
      _id = "arena_master",
      elona_id = 10,
   },
   {
      _id = "pet_arena_master",
      elona_id = 11,
   },
   {
      _id = "healer",
      elona_id = 12,
   },
   {
      _id = "adventurer",
      elona_id = 13,
   },
   {
      _id = "guard",
      elona_id = 14,

      dialog_choices = {
         function(speaker, state)
            local map = speaker:current_map()
            local to_choice = function(chara)
               return {
                  "elona.guard:where_is",
                  I18N.get("talk.npc.guard.choices.where_is", chara),
                  params = { chara_uid = chara.uid }
               }

            end
            return Quest.iter_accepted()
               :flatmap(function(quest) return Quest.find_target_charas(quest, map) end)
               :map(to_choice)
               :to_list()
         end,
         function()
            return {{"elona.guard:lost_item", "talk.npc.guard.lost_wallet"}}
         end,
         function()
            return {{"elona.guard:lost_item", "talk.npc.guard.lost_suitcase"}}
         end,
      }
   },
   {
      _id = "royal_family",
      elona_id = 15,
   },
   {
      _id = "shop_guard",
      elona_id = 16,
   },
   {
      _id = "slaver",
      elona_id = 17
   },
   {
      _id = "maid",
      elona_id = 18
   },
   {
      _id = "sister",
      elona_id = 19
   },
   {
      _id = "custom_chara",
      elona_id = 20,
   },
   {
      _id = "returner",
      elona_id = 21,
   },
   {
      _id = "horse_master",
      elona_id = 22
   },
   {
      _id = "caravan_master",
      elona_id = 23
   },
   {
      _id = "innkeeper",
      elona_id = 1005,

      dialog_choices = {
         function()
            local cost = Calc.calc_innkeeper_meal_cost()
            local text = ("%s (%s%s)"):format(I18N.get("talk.npc.innkeeper.choices.eat"), cost, I18N.get("ui.gold"))
            return {{"elona.innkeeper:buy_meal", text}}
         end,
         function()
            if Weather.is_bad_weather() then
               return {{"elona.innkeeper:shelter", "talk.npc.innkeeper.choices.go_to_shelter"}}
            end
         end,
      }
   },
   {
      _id = "spell_writer",
      elona_id = 1020,
   },
}

data:add_multi("base.role", role)

local function find_wandering_merchant_role(chara)
   local filter = function(role) return role.inventory_id == "elona.wandering_merchant" end
   return chara:iter_roles("elona.shopkeeper"):filter(filter):nth(1)
end

local function proc_drop_wandering_merchant_trunk(chara, params, drops)
   -- >>>>>>>> shade2/item.hsp:298 	if cRole(rc)=cRoleShopWander{ ...
   local role = find_wandering_merchant_role(chara)
   if role == nil then
      return drops
   end

   if chara.shop_inventory == nil then
      ShopInventory.refresh_shop(chara)
   end

   local function on_create(item, chara_)
      for _, i in chara_.shop_inventory:iter() do
         assert(item:take_object(i))
      end
      item.own_state = Enum.OwnState.Shop
   end

   drops[#drops+1] = {
      _id = "elona.shopkeepers_trunk",
      amount = 1,
      on_create = on_create
   }
   -- <<<<<<<< shade2/item.hsp:301 		} ..
end
Event.register("elona.on_chara_generate_loot_drops", "Generate wandering merchant shopkeeper's trunk", proc_drop_wandering_merchant_trunk)
