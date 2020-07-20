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
         {"elona.shopkeeper:buy", "talk.npc.shop.choices.buy"},
         {"elona.shopkeeper:sell", "talk.npc.shop.choices.sell"}
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
      _id = "citizen",
      elona_id = 4,
   },
   {
      _id = "special",
      elona_id = 3,
   },
   {
      _id = "bartender",
      elona_id = 9,
   },
   {
      _id = "wizard",
      elona_id = 5,
   },
   {
      _id = "elder",
      elona_id = 6,
   },
   {
      _id = "trainer",
      elona_id = 7,
   },
   {
      _id = "informer",
      elona_id = 8,
   },
   {
      _id = "arena_master",
      elona_id = 10,
   },
   {
      _id = "healer",
      elona_id = 12,
   },
   {
      _id = "royal_family",
      elona_id = 15,
   },
   {
      _id = "shop_guard",
      elona_id = 16,
   },
   {
      _id = "slaver",
      elona_id = 17
   },
   {
      _id = "returner",
      elona_id = 21,
   },
   {
      _id = "caravan_master",
      elona_id = 23
   },
   {
      _id = "innkeeper",
      elona_id = 1005,
   },
   {
      _id = "spell_writer",
      elona_id = 1020,
   },
}

data:add_multi("elona.role", role)
