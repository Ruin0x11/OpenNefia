local Chara = require("api.Chara")
local Input = require("api.Input")
local ShopInventory = require("mod.elona.api.ShopInventory")
local World = require("api.World")
local Quest = require("mod.elona_sys.api.Quest")
local Event = require("api.Event")

data:add {
   _type = "elona_sys.dialog",
   _id = "default",

   root = "",
   nodes = {
      __start = {
         text = {
            {"dialog"}
         },
         choices = function(t)
            local choices = t.speaker:emit("elona.calc_dialog_choices", {}, {})

            table.insert(choices, {"__END__", "__BYE__"})

            return choices
         end
      },
      talk = {
         text = {
            {"talk"}
         },
         choices = "__start"
      },
      you_kidding = {
         text = {
            {"talk.npc.common.you_kidding"}
         },
         choices = "__start"
      },
   },
}

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_giver",

   root = "talk.npc.quest_giver",
   nodes = {
      quest_about = {
         text = function(t)
            local quest = Quest.for_client(t.speaker)
            assert(quest, "Character doesn't have a quest.")
            local _, desc = Quest.get_name_and_desc(quest, t.speaker, false)
            return {{desc}}
         end,
         choices = {
            {"before_accept", "about.choices.take"},
            {"elona.default:you_kidding", "about.choices.leave"}
         }
      },
      before_accept = function(t)
         local quest = Quest.for_client(t.speaker)
         assert(quest, "Character doesn't have a quest.")

         if Quest.iter_accepted():length() >= 5 then
            return "too_many_unfinished"
         end

         local quest_proto = data["elona_sys.quest"]:ensure(quest._id)

         local node = "accept"
         if quest_proto.on_accept then
            local ok
            ok, node = quest_proto.on_accept(quest, t.speaker)
            if not ok then
               assert(node, "`on_accept()` must return a boolean and dialog node")
               return node
            end
         end

         quest.state = "accepted"

         return node or "accept"
      end,
      too_many_unfinished = {
         text = {
            {"about.too_many_unfinished"}
         },
         choices = "elona.default:__start"
      },
      accept = {
         text = {
            {"about.thanks"}
         },
         choices = "elona.default:__start"
      },
      finish = function(t)
         local quest = Quest.for_client(t.speaker)
         assert(quest, "Character doesn't have a quest.")
         return Quest.complete(quest, t.speaker)
      end
   },
}

local function add_quest_dialog(speaker, params, result)
   local quest = Quest.for_client(speaker)
   if quest and quest.state == "not_accepted" then
      table.insert(result, {"elona.quest_giver:quest_about", "talk.npc.quest_giver.choices.about_the_work"})
   end

   return result
end

Event.register("elona.calc_dialog_choices", "Add quest dialog choices", add_quest_dialog)

local function refresh_shop(shopkeeper)
   local inv_id = shopkeeper.roles["elona.shopkeeper"].inventory_id
   shopkeeper.shop_inventory = ShopInventory.generate(inv_id, shopkeeper)

   -- TODO
   local restock_interval = 4
   shopkeeper.shop_restock_date = World.date():hours() + 24 * restock_interval

   shopkeeper:emit("elona.on_shop_restocked", {inventory_id=inv_id})
end

data:add {
   _type = "elona_sys.dialog",
   _id = "shopkeeper",

   root = "",
   nodes = {
      buy = function(t)
         if t.speaker.shop_inventory == nil
            or World.date():hours() >= t.speaker:calc("shop_restock_date")
         then
            refresh_shop(t.speaker)
         end

         Input.query_inventory(Chara.player(), "elona.inv_buy", {target=t.speaker, shop=t.speaker.shop_inventory})
         return "elona.default:talk"
      end,
      sell = function(t)
         Input.query_inventory(Chara.player(), "elona.inv_sell", {target=t.speaker})
         return "elona.default:talk"
      end,
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "guard",

   root = "",
   nodes = {
      where_is = function(t)
         return "elona.default:talk"
      end,
      lost_item = function(t)
         return "elona.default:talk"
      end,
   }
}

require("mod.elona.data.dialog.unique.miches")
require("mod.elona.data.dialog.unique.larnneire")
require("mod.elona.data.dialog.unique.lomias")
require("mod.elona.data.dialog.unique.rilian")
require("mod.elona.data.dialog.unique.poppy")
