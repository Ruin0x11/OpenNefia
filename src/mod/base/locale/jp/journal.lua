return {
   journal = {
      menu = {
         title = "ジャーナル",
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
               fame = function(_1) return ("名声: %d"):format(_1) end,
               arena = function(_1, _2)
                  return ("EXバトル: 勝利 %s回 最高Lv%s")
                     :format(_1, _2)
               end,
               deadline = function(_1)
                  return ("ノルマ: %s日以内")
                     :format(_1)
               end,
               pay = function(_1)
                  return ("給料: 約 %s gold  ")
                     :format(_1)
               end
            },
            income_and_expense = {
               title = "Income & Expense",
               bills = {
                  labor = function(_1)
                     return ("　人件費  : 約 %s gold")
                        :format(_1)
                  end,
                  maintenance = function(_1)
                     return ("　運営費  : 約 %s gold")
                        :format(_1)
                  end,
                  sum = function(_1)
                     return ("　合計　  : 約 %s gold")
                        :format(_1)
                  end,
                  tax = function(_1)
                     return ("　税金    : 約 %s gold")
                        :format(_1)
                  end,
                  title = "◆ 請求書内訳(毎月1日に発行)",
                  unpaid = function(_1)
                     return ("現在未払いの請求書は%s枚")
                        :format(_1)
                  end
               },
               salary = {
                  sum = function(_1)
                     return ("　合計　　 : 約 %s gold")
                        :format(_1)
                  end,
                  title = "◆ 給料(毎月1日と15日に支給)"
               }
            },
            completed_quests = {
               title = "Completed Quests",
            }
         }
      },
   }
}
