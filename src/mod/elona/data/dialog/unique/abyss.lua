local Chara = require("api.Chara")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Rank = require("mod.elona.api.Rank")
local Guild = require("mod.elona.api.Guild")
local Itemgen = require("mod.elona.api.Itemgen")

local common = require("mod.elona.data.dialog.common")

local function start_trial()
    Sidequest.set_progress("elona.guild_thief_joining", 1)
    Sidequest.update_journal()
end

local function join_guild()
   Sidequest.set_progress("elona.guild_thief_joining", 1000)
   Rank.set("elona.guild", 10000, true)

   Guild.set_guild(Chara.player(), "elona.thief")

   Gui.mes_c("quest.completed", "Green")
   Gui.play_sound("base.complete1")
   Sidequest.update_journal()
   Gui.mes_c("talk.unique.abyss.nonmember.joined", "Yellow")
end

local function move_off_guild_entrance(t)
   local abyss = t.speaker
   abyss:set_pos(17, 17)
   abyss.initial_x = 17
   abyss.initial_y = 17
end

local function update_quota()
   save.elona.guild_thief_stolen_goods_quota = Guild.calc_thief_guild_quota()
   Sidequest.set_progress("elona.guild_thief_quota", 1)
   Sidequest.update_journal()
end

local function receive_reward()
   local player = Chara.player()
   local map = player:current_map()
   local guild_rank = Rank.get("elona.guild")

   Sidequest.set_progress("elona.guild_thief_quota", 0)
   Itemgen.create(player.x, player.y,
                  {
                     level = 51 - guild_rank / 200,
                     categories = "elona.furniture"
                  },
                  map)
   Item.create("elona.gold_piece", player.x, player.y, { amount = 10000 - guild_rank + 1000 }, map)
   Item.create("elona.platinum_coin", player.x, player.y, { amount = math.clamp(3 - guild_rank / 3000, 1, 3) }, map)

   common.quest_completed()

   Rank.modify("elona.guild", 500, 8)
end

data:add {
   _type = "elona_sys.dialog",
   _id = "abyss",

   nodes = {
      __start = function()
         if Chara.player():calc("guild") ~= "elona.thief" then
            return "guild_nonmember"
         end

         return "guild_member"
      end,

      guild_nonmember = {
         text = "talk.unique.abyss.nonmember.dialog",
         choices = {
            {"guild_desc", "talk.unique.abyss.nonmember.choices.tell_me_about"},
            {"guild_join_check", "talk.unique.abyss.nonmember.choices.want_to_join"},
            {"__END__", "ui.bye"}
         }
      },
      guild_desc = {
         text = "talk.unique.abyss.nonmember.tell_me_about",
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_join_check = function()
         if Sidequest.progress("elona.guild_thief_joining") == 0 then
            return "guild_join_start"
         elseif save.elona.unpaid_bill_count <= 4 then
            return "guild_join_waiting"
         end

         return "guild_join_finish"
      end,
      guild_join_start = {
         text = {
            {"talk.unique.abyss.nonmember.want_to_join._0"},
            start_trial,
            {"talk.unique.abyss.nonmember.want_to_join._1"},
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_join_waiting = {
         text = "talk.unique.abyss.nonmember.quota",
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_join_finish = {
         text = {
            {"talk.unique.abyss.nonmember.end._0"},
            join_guild,
            {"talk.unique.abyss.nonmember.end._1"},
         },
         on_finish = move_off_guild_entrance,
      },

      guild_member = {
         on_start = move_off_guild_entrance,
         text = function()
            return I18N.get("talk.unique.abyss.member.dialog", Rank.title("elona.guild"), Chara.player():calc("name"))
         end,
         choices = function()
            local choices = {}
            if Sidequest.progress("elona.guild_thief_quota") == 0 then
               table.insert(choices, {"guild_quota_new", "guild.dialog.choices.new_quota"})
            else
               table.insert(choices, {"guild_quota_check", "guild.dialog.choices.report_quota"})
            end
            table.insert(choices, {"__END__", "ui.bye"})

            return choices
         end
      },
      guild_quota_new = {
         on_start = update_quota,
         text = function()
            return I18N.get("talk.unique.abyss.member.new_quota", save.elona.guild_thief_stolen_goods_quota)
         end,
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_quota_check = function()
         if save.elona.guild_thief_stolen_goods_quota > 0 then
            return "guild_quota_waiting"
         end
         return "guild_quota_finish"
      end,
      guild_quota_waiting = {
         text = "guild.dialog.report_quota.waiting",
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_quota_finish = {
         on_start = receive_reward,
         text = "guild.dialog.report_quota.end",
      },
   }
}
