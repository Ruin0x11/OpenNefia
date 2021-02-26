return {
   visual_ai = {
      gui = {
         menu = {
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
