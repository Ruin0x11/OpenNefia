return {
   visual_ai = {
      gui = {
         menu = {
            hint = {
               action = {
                  append = "Append",
                  insert = "Insert",
                  replace = "Replace",
                  insert_down = "Insert Down",
                  delete = "Delete",
                  delete_merge_down = "Delete Down",
                  delete_to_right = "Delete to Right",
                  swap_branches = "Swap Branches",

                  confirm = "Confirm",
               }
            },
            title = "Visual AI",
            category = function(category)
               return ("Category: %s"):format(category)
            end,
            insert_block = "Insert Block",
            replace_block = "Replace Block",
         },
         category = {
            condition = "Condition",
            action = "Action",
            target = "Target",
            special = "Special"
         }
      }
   }
}
