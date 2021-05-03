return {
   visual_ai = {
      gui = {
         menu = {
            hint = {
               action = {
                  append = "追加",
                  insert = "挿入",
                  replace = "入れ替える",
                  insert_down = "下に挿入",
                  delete = "削除",
                  delete_merge_down = "詰める",
                  delete_to_right = "右に削除",
                  swap_branches = "条件節の交換",

                  confirm = "決定",
               }
            },
            title = "ビジュアルAI",
            category = function(category)
               return ("種類: %s"):format(category)
            end,
            insert_block = "ブロックの挿入",
            replace_block = "ブロックの入れ替え",
         },
         category = {
            condition = "条件",
            action = "行動",
            target = "対象",
            special = "特殊"
         }
      }
   }
}
