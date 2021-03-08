local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Rank = require("mod.elona.api.Rank")
local Quest = require("mod.elona_sys.api.Quest")
local Calc = require("mod.elona.api.Calc")

data:add {
   _type = "base.journal_page",
   _id = "news",

   ordering = 40000,

   render = function()
      -- TODO adventurers

      return ([[
 - %s -

]]):format(
         I18N.get("journal._.elona.news.title")
          )
   end
}

local function format_quest_status(quest)
   -- >>>>>>>> shade2/text.hsp:1236 		if qStatus(rq)=qSuccess:buff+="@QC["+lang("依頼 完了 ...
   local status
   if quest.state == "completed" then
      status = ("<size=10><color=#006464>[%s]"):format(I18N.get("quest.journal.common.complete"))
   else
      status = ("<size=10><color=#646400>[%s]"):format(I18N.get("quest.journal.common.job"))
   end

   local client = I18N.get("quest.journal.common.client", quest.client_name)
   local location = I18N.get("quest.journal.common.client", quest.map_name)
   local remaining = I18N.get("quest.journal.common.remaining", Quest.format_deadline_text(quest.deadline_days))
   local reward = I18N.get("quest.journal.common.reward", Quest.format_reward_text(quest))

   local detail_text
   if quest.state == "completed" then
      detail_text = I18N.get("quest.journal.common.report_to_the_client")
   else
      detail_text = Quest.format_detail_text(quest)
   end
   local detail = I18N.get("quest.journal.common.detail", detail_text)

   return table.concat({status, client, location, remaining, reward, detail}, "\n")
   -- <<<<<<<< shade2/text.hsp:1247 		buff+=s(4)+"¥n" ..
end

data:add {
   _type = "base.journal_page",
   _id = "quest",

   ordering = 45000,

   render = function()
      -- TODO main quest
      local main_quest_info = "TODO main quest"

      local quest_infos = Quest.iter_accepted():map(format_quest_status):to_list()
      local quest_info = table.concat(quest_infos, "\n\n")

      -- TODO sidequests
      local sub_quest_info = "TODO sub quest"

      return ([[
 - %s -

%s

%s

%s
]]):format(
         I18N.get("journal._.elona.quest.title"),
         main_quest_info,
         quest_info,
         sub_quest_info
          )
   end
}

data:add {
   _type = "base.journal_page",
   _id = "quest_item",

   ordering = 50000,

   render = function()
      -- TODO main quest, side quests

      return ([[
 - %s -

]]):format(
         I18N.get("journal._.elona.quest_item.title")
          )
   end
}

local function format_rank(rank_proto, rank)
   local rank_id = rank_proto._id
   local place = Rank.get(rank_id)
   if place >= 10000 then
      return nil
   end

   local rank_title = Rank.title(rank_id)
   if rank_title == nil then
      return nil
   end
   local rank_position = math.floor(place / 100)
   local rank_income = I18N.get("journal._.elona.title_and_ranking.pay", Calc.calc_rank_income(rank_id))
   local rank_deadline = ""
   if Rank.get_decay_period_days(rank_id) then
      local days_left = rank.days_until_decay
      rank_deadline = ("\n%s"):format(I18N.get("journal._.elona.title_and_ranking.deadline", days_left))
   end

   return ([[
%s Rank.%d
%s%s
]]):format(rank_title, rank_position, rank_income, rank_deadline)
end

data:add {
   _type = "base.journal_page",
   _id = "title_and_ranking",

   ordering = 55000,

   render = function()
      -- >>>>>>>> shade2/command.hsp:951 	noteadd " - Title & Ranking - ":noteadd "" ...
      local player = Chara.player()

      local fame = I18N.get("journal._.elona.title_and_ranking.fame", player:calc("fame"))

      local rank_texts = Rank.iter():map(format_rank):filter(fun.op.truth):to_list()
      local ranks = table.concat(rank_texts, "\n\n")

      -- TODO arena
      local ex_battle_wins = 0
      local ex_battle_max_level = 0
      local arena = I18N.get("journal._.elona.title_and_ranking.arena", ex_battle_wins, ex_battle_max_level)

      return ([[
 - %s -

%s

%s

%s
]]):format(
         I18N.get("journal._.elona.title_and_ranking.title"),
         fame,
         ranks,
         arena)
      -- <<<<<<<< shade2/command.hsp:964 	noteadd lang("EXバトル: 勝利 "+gExBattleWin+"回 最高Lv"+g ..
   end
}

data:add {
   _type = "base.journal_page",
   _id = "income_and_expense",

   ordering = 60000,

   render = function()
      -- >>>>>>>> shade2/command.hsp:973 	noteadd " - Income & Expense - ":noteadd "" ...
      -- TODO buildings, taxes, bills, hired servants

      local player = Chara.player()
      local salary_gold = Calc.calc_displayed_total_income(player)

      local labor_expenses = save.elona.labor_expenses
      local building_expenses = Calc.calc_building_expenses(player)
      local tax_expenses = Calc.calc_tax_expenses(player)
      local total_expenses = Calc.calc_base_bill_amount(player)

      local unpaid_bill_count = save.elona.unpaid_bill_count

      return ([[
 - %s -

%s
<size=12><color=#000064>%s

%s
<size=12><color=#640000>%s
<size=12><color=#640000>%s
<size=12><color=#640000>%s
<size=12><color=#640000>%s

%s
]]):format(
         I18N.get("journal._.elona.income_and_expense.title"),

         I18N.get("journal._.elona.income_and_expense.salary.title"),
         I18N.get("journal._.elona.income_and_expense.salary.sum", salary_gold),

         I18N.get("journal._.elona.income_and_expense.bills.title"),
         I18N.get("journal._.elona.income_and_expense.bills.labor", labor_expenses),
         I18N.get("journal._.elona.income_and_expense.bills.maintenance", building_expenses),
         I18N.get("journal._.elona.income_and_expense.bills.tax", tax_expenses),
         I18N.get("journal._.elona.income_and_expense.bills.sum", total_expenses),

         I18N.get("journal._.elona.income_and_expense.bills.unpaid", unpaid_bill_count))
      -- <<<<<<<< shade2/command.hsp:1001 	loop ..
   end
}

data:add {
   _type = "base.journal_page",
   _id = "completed_quests",

   ordering = 65000,

   render = function()
      -- TODO main quest, side quests

      return ([[
 - %s -

]]):format(
         I18N.get("journal._.elona.completed_quests.title")
          )
   end
}
