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
   }
}

data:add_multi("elona.role", role)
