local Chara = require("api.Chara")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Item = require("api.Item")
local ChooseAllyMenu = require("api.gui.menu.ChooseAllyMenu")
local ICharaElonaFlags = require("mod.elona.api.aspect.chara.ICharaElonaFlags")
local Gui = require("api.Gui")
local StayingCharas = require("api.StayingCharas")
local Calc = require("mod.elona.api.Calc")
local I18N = require("api.I18N")
local Effect = require("mod.elona.api.Effect")

local function give_wife(raphael, wife)
   local player = Chara.player()
   if not wife:has_tag("man") then
      raphael:apply_effect("elona.insanity", 1000)
      Effect.modify_karma(player, 2)
      return true
   else
      Effect.modify_karma(player, -15)
      return false
   end
end

local function format_name_sell(chara)
   -- >>>>>>>> shade2/command.hsp:572 		s=""+cnAka(i)+" "+cnName(i)  ...
   return ("%s %s Lv.%d"):format(chara:calc("title"), chara:calc("name"), chara:calc("level"))
   -- <<<<<<<< shade2/command.hsp:574 		cs_list s,wX+84 ,wY+66+cnt*19-1,19 ..
end

local function format_info_sell(chara)
   -- >>>>>>>> shade2/command.hsp:575 		s=""+(calcSlaveValue(i)*2/3)+strGold ...
   local value = math.floor(Calc.calc_slave_value(chara) * 2 / 3)
   return tostring(value) .. I18N.get("ui.gold")
   -- <<<<<<<< shade2/command.hsp:576 		pos wX+390,wY+66+cnt*19+2:mes s ..
end

local function query_sell_ally()
   local player = Chara.player()
   local map = player:current_map()
   local filter = function(c)
      return Chara.is_alive(c) and not StayingCharas.get_staying_area_for_global(c)
   end
   local allies = player:iter_other_party_members(map):filter(filter):to_list()

   local topic = {
      name_formatter = format_name_sell,
      info_formatter = format_info_sell,
      window_title = "ui.ally_list.sell.title",
      header_status = "ui.ally_list.sell.value",
      x_offset = 20
   }

   Gui.mes("ui.ally_list.sell.prompt")
   return ChooseAllyMenu:new(allies, topic):query()
end

data:add {
   _type = "elona_sys.dialog",
   _id = "raphael",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.wife_collector")
         if flag == 0 then
            return "quest_ask"
         elseif flag == 1 or flag == 1000 then
            return "bring_wife"
         end

         return "elona_sys.ignores_you:__start"
      end,

      quest_ask = {
         text = "talk.unique.raphael.quest.dialog",
         choices = {
            {"quest_yes", "talk.unique.raphael.quest.choices.yes"},
            {"quest_no", "talk.unique.raphael.quest.choices.no"},
         },
         default_choice = "quest_no"
      },
      quest_no = {
         text = "talk.unique.raphael.quest.no",
      },
      quest_yes = {
         on_start = function()
            Sidequest.update_journal()
         end,
         text = "talk.unique.raphael.quest.yes",
         on_finish = function()
            Sidequest.set_progress("elona.wife_collector", 1)
         end
      },

      bring_wife = {
         text = "talk.unique.raphael.bring_wife.dialog",
         choices = {
            {"bring_wife_choose", "talk.unique.raphael.bring_wife.choices.this_one"},
            {"bring_wife_go_back", "talk.unique.raphael.bring_wife.choices.go_back"},
         },
         default_choice = "bring_wife_go_back"
      },
      bring_wife_go_back = {
         text = "talk.unique.raphael.bring_wife.go_back",
      },
      bring_wife_choose = function(t, state)
         local result, canceled = query_sell_ally()

         if not result or canceled then
            return "bring_wife_no_such_wife"
         end

         local wife = result.chara

         if not wife:calc_aspect(ICharaElonaFlags, "is_married") then
            return "bring_wife_not_married"
         end

         state.wife = wife

         return "bring_wife_come_along"
      end,
      bring_wife_come_along = {
         text = function(t, state)
            local wife = state.wife
            local text = I18N.get("talk.unique.raphael.bring_wife.this_one.come_along", wife.name)
            return {{text}}
         end,
         on_finish = function(t, state)
            local raphael = t.speaker
            local result = give_wife(raphael, state.wife)
            state.raphael = t.speaker
            state.result = result
         end,
         choices = {
            {"bring_wife_leaving", "ui.more"}
         }
      },
      bring_wife_leaving = {
         text = function(t, state)
            return {{"talk.unique.raphael.bring_wife.this_one.leaving", speaker = state.wife}}
         end,
         choices = {
            {"bring_wife_show_result", "ui.more"}
         }
      },
      bring_wife_show_result = function(t, state)
         t.speaker = assert(state.raphael)
         local result = state.result
         if result then
            return "bring_wife_not_human"
         elseif Sidequest.progress("elona.wife_collector") == 1 then
            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.gold_piece", player.x, player.y, {amount=5000}, map)
            Gui.mes_c("quest.completed", "Green")
            Sidequest.update_journal()
            Sidequest.set_progress("elona.wife_collector", 1000)
         end

         return "bring_wife_end"
      end,
      bring_wife_not_human = {
         text = "talk.unique.raphael.bring_wife.this_one.not_human",
         choices = {
            {"bring_wife_end", "ui.more"}
         }
      },
      bring_wife_no_such_wife = {
         text = "talk.unique.raphael.bring_wife.this_one.no_such_wife",
      },
      bring_wife_not_married = {
         text = "talk.unique.raphael.bring_wife.this_one.not_married",
      },
      bring_wife_end = {
         on_start = function(_, state)
            state.wife:vanquish()
            Gui.play_sound("base.complete1")

            local player = Chara.player()
            local map = player:current_map()
            Item.create("elona.unicorn_horn", player.x, player.y, {amount=2}, map)
            Item.create("elona.platinum_coin", player.x, player.y, {amount=2}, map)
            Gui.mes("common.something_is_put_on_the_ground")
         end,
         text = "talk.unique.raphael.bring_wife.this_one.end"
      }
   }
}
