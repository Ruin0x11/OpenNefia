local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Rank = require("mod.elona.api.Rank")

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

data:add {
   _type = "base.journal_page",
   _id = "quest",

   ordering = 45000,

   render = function()
      -- TODO
      return ([[
 - %s -

]]):format(
         I18N.get("journal._.elona.quest.title")
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

data:add {
   _type = "base.journal_page",
   _id = "title_and_ranking",

   ordering = 55000,

   render = function()
      local player = Chara.player()

      local fame = I18N.get("journal._.elona.title_and_ranking.fame", player:calc("fame"))

      local ranks = ""

      for _, rank in Rank.iter() do
         -- TODO rank
      end

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
   end
}

data:add {
   _type = "base.journal_page",
   _id = "income_and_expense",

   ordering = 60000,

   render = function()
      -- TODO buildings, taxes, bills, hired servants

      local salary_gold = 0

      local labor_expenses = 0
      local building_expenses = 0
      local tax_expenses = 0
      local total_expenses = 0

      local unpaid_bills = 0

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

         I18N.get("journal._.elona.income_and_expense.bills.unpaid", unpaid_bills))
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
