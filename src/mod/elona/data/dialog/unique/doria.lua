local Chara = require("api.Chara")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Item = require("api.Item")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Guild = require("mod.elona.api.Guild")
local Rank = require("mod.elona.api.Rank")
local Itemgen = require("mod.elona.api.Itemgen")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")

local common = require("mod.elona.data.dialog.common")

local function start_trial()
    Sidequest.set_progress("elona.guild_fighter_joining", 1)
    Sidequest.update_journal()
    save.elona.guild_fighter_target_chara_id = Guild.random_fighter_guild_target_id(10)
    save.elona.guild_fighter_target_chara_quota = 15
end

local function join_guild()
   Sidequest.set_progress("elona.guild_fighter_joining", 1000)
   Rank.set("elona.guild", 10000)

   Guild.set_guild(Chara.player(), "elona.fighter")

   Gui.mes_c("quest.completed", "Green")
   Gui.play_sound("base.complete1")
   Sidequest.update_journal()
   Gui.mes_c("talk.unique.doria.nonmember.joined", "Yellow")
end

local function move_off_guild_entrance(t)
   local doria = t.speaker
   doria:set_pos(29, 2)
   doria.initial_x = 29
   doria.initial_y = 2
end

local function update_quota()
   local level = Guild.calc_fighter_guild_target_level(Chara.player())
   save.elona.guild_fighter_target_chara_id = Guild.random_fighter_guild_target_id(level)
   save.elona.guild_fighter_target_chara_quota = Guild.calc_fighter_guild_target_count()
   Sidequest.set_progress("elona.guild_fighter_quota", 1)
   Sidequest.update_journal()
end

local function receive_reward()
   local player = Chara.player()
   local map = player:current_map()
   local guild_rank = Rank.get("elona.guild")

   Sidequest.set_progress("elona.guild_fighter_quota", 0)
   Itemgen.create(player.x, player.y,
                  {
                     level = 51 - guild_rank / 200,
                     quality = Calc.calc_object_quality(Enum.Quality.Good),
                     categories = "elona.equip_melee"
                  },
                  map)
   Item.create("elona.gold_piece", player.x, player.y, { amount = 10000 - guild_rank + 1000 }, map)
   Item.create("elona.platinum_coin", player.x, player.y, { amount = math.clamp(4 - guild_rank / 2500, 1, 4) }, map)

   common.quest_completed()

   Rank.modify("elona.guild", 500, 8)
end

data:add {
   _type = "elona_sys.dialog",
   _id = "doria",

   nodes = {
      __start = function()
         if Chara.player():calc("guild") ~= "elona.fighter" then
            return "guild_nonmember"
         end

         return "guild_member"
      end,

      guild_nonmember = {
         text = {
            {"talk.unique.doria.nonmember.dialog"},
         },
         choices = {
            {"guild_desc", "talk.unique.doria.nonmember.choices.tell_me_about"},
            {"guild_join_check", "talk.unique.doria.nonmember.choices.want_to_join"},
            {"__END__", "ui.bye"}
         }
      },
      guild_desc = {
         text = {
            {"talk.unique.doria.nonmember.tell_me_about"},
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_join_check = function()
         if Sidequest.progress("elona.guild_fighter_joining") == 0 then
            return "guild_join_start"
         elseif save.elona.guild_fighter_target_chara_quota > 0 then
            return "guild_join_waiting"
         end

         return "guild_join_finish"
      end,
      guild_join_start = {
         text = {
            {"talk.unique.doria.nonmember.want_to_join._0"},
            start_trial,
            function()
               local chara_name = I18N.get("chara." .. save.elona.guild_fighter_target_chara_id .. ".name")
               return I18N.get("talk.unique.doria.nonmember.want_to_join._1", save.elona.guild_fighter_target_chara_quota, chara_name)
            end
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_join_waiting = {
         text = function()
            local chara_name = I18N.get("chara." .. save.elona.guild_fighter_target_chara_id .. ".name")
            return I18N.get("talk.unique.doria.nonmember.quota", save.elona.guild_fighter_target_chara_quota, chara_name)
         end,
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_join_finish = {
         text = {
            {"talk.unique.doria.nonmember.end._0"},
            join_guild,
            {"talk.unique.doria.nonmember.end._1"},
         },
         on_finish = move_off_guild_entrance,
      },

      guild_member = {
         on_start = move_off_guild_entrance,
         text = function()
            return I18N.get("talk.unique.doria.member.dialog", Rank.title("elona.guild"), Chara.player():calc("name"))
         end,
         choices = function()
            local choices = {}
            if Sidequest.progress("elona.guild_fighter_quota") == 0 then
               table.insert(choices, {"guild_quota_new", "talk.unique.lexus.member.choices.new_quota"})
            else
               table.insert(choices, {"guild_quota_check", "talk.unique.lexus.member.choices.report_quota"})
            end
            table.insert(choices, {"__END__", "ui.bye"})

            return choices
         end
      },
      guild_quota_new = {
         on_start = update_quota,
         text = function()
            local chara_name = I18N.get("chara." .. save.elona.guild_fighter_target_chara_id .. ".name")
            return I18N.get("talk.unique.doria.member.new_quota", save.elona.guild_fighter_target_chara_quota, chara_name)
         end,
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_quota_check = function()
         if save.elona.guild_fighter_target_chara_quota > 0 then
            return "guild_quota_waiting"
         end
         return "guild_quota_finish"
      end,
      guild_quota_waiting = {
         text = {
            {"talk.unique.lexus.member.report_quota.waiting"},
         },
         choices = {
            {"__start", "ui.more"},
         }
      },
      guild_quota_finish = {
         text = {
            receive_reward,
            {"talk.unique.lexus.member.report_quota.end"},
         },
      },
   }
}
