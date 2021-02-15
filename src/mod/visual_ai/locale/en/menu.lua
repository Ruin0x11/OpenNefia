return {
   visual_ai = {
      gui = {
         menu = {
            category = function(category)
               return ("Category: %s"):format(category)
            end
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
