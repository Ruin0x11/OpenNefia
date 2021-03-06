return {
   journal = {
      menu = {
         title = "Journal",
      },
      _ = {
         elona = {
            news = {
               title = "News"
            },
            quest = {
               title = "Quest"
            },
            quest_item = {
               title = "Quest Item"
            },
            title_and_ranking = {
               title = "Title & Ranking",
               fame = function(_1) return ("Fame: %d"):format(_1) end,
               arena = function(_1, _2)
                  return ("EX Arena Wins:%s  Highest Level:%s")
                     :format(_1, _2)
               end,
               deadline = function(_1)
                  return ("Deadline: %s Days left")
                     :format(_1)
               end,
               pay = function(_1)
                  return ("Pay: About %s gold pieces ")
                     :format(_1)
               end
            },
            income_and_expense = {
               title = "Income & Expense",
               bills = {
                  labor = function(_1)
                     return ("  Labor  : About %s GP")
                        :format(_1)
                  end,
                  maintenance = function(_1)
                     return ("  Maint. : About %s GP")
                        :format(_1)
                  end,
                  sum = function(_1)
                     return ("  Sum    : About %s GP")
                        :format(_1)
                  end,
                  tax = function(_1)
                     return ("  Tax    : About %s GP")
                        :format(_1)
                  end,
                  title = "Bills  (Issued every 1st day)",
                  unpaid = function(_1)
                     return ("You have %s unpaid bills.")
                        :format(_1)
                  end
               },
               salary = {
                  sum = function(_1)
                     return ("  Sum    : About %s GP")
                        :format(_1)
                  end,
                  title = "Salary (Paid every 1st and 15th day)"
               }
            },
            completed_quests = {
               title = "Completed Quests",
            }
         }
      }
   }
}
