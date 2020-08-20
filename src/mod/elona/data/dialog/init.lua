local Chara = require("api.Chara")
local Input = require("api.Input")
local ShopInventory = require("mod.elona.api.ShopInventory")
local World = require("api.World")
local Quest = require("mod.elona_sys.api.Quest")
local Event = require("api.Event")
local I18N = require("api.I18N")
local Const = require("api.Const")
local Rand = require("api.Rand")
local Area = require("api.Area")
local Skill = require("mod.elona_sys.api.Skill")

data:add {
   _type = "elona_sys.dialog",
   _id = "is_sleeping",
   root = "talk",
   nodes = {
      __start = {
         text = {
            {"is_sleeping", args = function(t) return {t.speaker} end},
         }
      },
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "is_busy",
   root = "talk",
   nodes = {
      __start = {
         text = {
            {"is_busy", args = function(t) return {t.speaker} end},
         }
      },
   }
}

local function talk_text(t)
   -- >>>>>>>> elona122/shade2/text.hsp:957 *random_talk ..
   local speaker = t.speaker
   local id = "talk.random.default"
   local params = {
      gender = I18N.get("ui.sex2." .. Chara.player():calc("gender"))
   }

   local map = speaker:current_map()
   local area = Area.for_map(map)

   local function has_shop(chara, inv_id)
      return chara:iter_roles("elona.shopkeeper")
         :any(function(role) return role.inventory_id == inv_id end)
   end

   -- TODO move role-related talk
   if speaker:find_role("elona.maid") and save.elona.waiting_guests > 0 then
      id = "talk.random.maid"
      params.ref = I18N.get("talk.random.params.maid", save.elona.waiting_guests)
   elseif speaker:calc("interest") <= 0 then
      id = "talk.random.bored"
   elseif speaker:is_allied() then
      id = "talk.random.ally_default"
   elseif speaker._id == "elona.prostitute" then
      id = "talk.random.prostitute"
   elseif has_shop(speaker, "elona.moyer") then
      id = "talk.random.moyer"
   elseif speaker:find_role("elona.slaver") then
      id = "talk.random.slavekeeper"
   elseif speaker:calc("impression") >= Const.IMPRESSION_FRIEND and Rand.one_in(3) then
      id = "talk.random.rumor.loot"
   elseif map and map.is_noyel_christmas_festival then
      id = "talk.random.christmas_festival"
   elseif Rand.one_in(2) then
      id = "talk.random.personality." .. tostring(speaker:calc("personality") or 0)
   elseif Rand.one_in(3) and area._archetype then
      id = "talk.random.area." .. area._archetype
   end

   local npc = speaker:produce_locale_data()
   local player = Chara.player():produce_locale_data()

   local str = I18N.get_optional(id, npc, player, params)
   if str == nil then
      str = I18N.get("talk.random.default", npc, player, params)
   end

   return { {str} }
   -- <<<<<<<< elona122/shade2/text.hsp:977 	return ..
end

local function modify_impress_and_interest(speaker)
   -- >>>>>>>> elona122/shade2/chat.hsp:2203 		if cInterest(tc)>0 : if cRelation(tc)!cAlly : if ..
   if speaker.interest > 0 and not speaker:is_allied() then
      if Rand.one_in(3) and speaker.impression < Const.IMPRESSION_FRIEND then
         local charisma = Chara.player():skill_level("elona.stat_charisma")
         if Rand.rnd(charisma + 1) > 10 then
            Skill.modify_impression(speaker, Rand.rnd(3))
         else
            Skill.modify_impression(speaker, -Rand.rnd(3))
         end
      end
      speaker.interest = speaker.interest - Rand.rnd(30)
      speaker.interest_renew_date = World.date_hours() + 8
   end
   -- <<<<<<<< elona122/shade2/chat.hsp:2208 		} ..
end

data:add {
   _type = "elona_sys.dialog",
   _id = "default",

   root = "",
   nodes = {
      __start = {
         text = talk_text,
         choices = function(t)
            local speaker = t.speaker
            local choices = speaker:emit("elona.calc_dialog_choices", {}, {})

            table.insert(choices, {"__END__", "__BYE__"})

            modify_impress_and_interest(speaker)

            return choices
         end
      },
      talk = {
         text = talk_text,
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
   -- TODO multiple shop roles
   local role = shopkeeper:find_role("elona.shopkeeper")
   local inv_id = role.inventory_id
   local inv_data = data["elona.shop_inventory"]:ensure(inv_id)
   shopkeeper.shop_inventory = ShopInventory.generate(inv_id, shopkeeper)

   -- >>>>>>>> elona122/shade2/chat.hsp:3564  ..
   local restock_interval = inv_data.restock_interval or 24
   shopkeeper.shop_restock_date = World.date_hours() + restock_interval
   -- <<<<<<<< elona122/shade2/chat.hsp:3565 	cRoleRestock(tc)=dateID+restockTime*(1+(cRole(tc) ..

   shopkeeper:emit("elona.on_shop_restocked", {inventory_id=inv_id})
end

data:add {
   _type = "elona_sys.dialog",
   _id = "shopkeeper",

   root = "",
   nodes = {
      buy = function(t)
         if t.speaker.shop_inventory == nil
            or World.date():hours() >= t.speaker.shop_restock_date
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
