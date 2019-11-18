data:add_type {
   name = "role",
   schema = schema.Record {
   }
}

local role = {
   {
      _id = "shopkeeper",
      params = {},

      dialog_choices = {
         {"elona.shopkeeper:buy", "buy"},
         {"elona.shopkeeper:sell", "sell"}
      }
   },
   {
      _id = "guard",
      params = {},

      dialog_choices = {
         function()
            return {{"elona.guard:where_is", "where_is"}}
         end,
         function()
            return {{"elona.guard:lost_item", "lost wallet"}}
         end,
         function()
            return {{"elona.guard:lost_item", "lost suitcase"}}
         end,
      }
   }
}

data:add_multi("elona.role", role)
