data:add_type {
   name = "role",
   schema = schema.Record {
   }
}

local role = {
   {
      _id = "shopkeeper",
      params = {},
      elona_id = 1000,

      dialog_choices = {
         {"elona.shopkeeper:buy", "buy"},
         {"elona.shopkeeper:sell", "sell"}
      }
   },
   {
      _id = "guard",
      elona_id = 14,
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
   },
   {
      _id = "non_quest_target",
      elona_id = 4,
   },
   {
      _id = "non_quest_giver",
      elona_id = 3,
   },
}

data:add_multi("elona.role", role)
