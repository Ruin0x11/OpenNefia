local role = {
   {
      _id = "shopkeeper",
      elona_id = 1,

      dialog_choices = {
         {"elona.shopkeeper:buy", "talk.npc.shop.choices.buy"},
         {"elona.shopkeeper:sell", "talk.npc.shop.choices.sell"}
      }
   },
   {
      _id = "special",
      elona_id = 3,
   },
   {
      _id = "citizen",
      elona_id = 4,
   },
   {
      _id = "identifier",
      elona_id = 5,
   },
   {
      _id = "elder",
      elona_id = 6,
   },
   {
      _id = "trainer",
      elona_id = 7,
      dialog_choices = {
         {"elona.trainer:train", "talk.npc.trainer.choices.train.ask"},
         {"elona.trainer:learn", "talk.npc.trainer.choices.learn.ask"}
      }
   },
   {
      _id = "informer",
      elona_id = 8,
   },
   {
      _id = "bartender",
      elona_id = 9,
   },
   {
      _id = "arena_master",
      elona_id = 10,
   },
   {
      _id = "pet_arena_master",
      elona_id = 11,
   },
   {
      _id = "healer",
      elona_id = 12,
   },
   {
      _id = "adventurer",
      elona_id = 13,
   },
   {
      _id = "guard",
      elona_id = 14,

      dialog_choices = {
         function()
            -- TODO quest
            return {{"elona.guard:where_is", "talk.npc.guard.where_is"}}
         end,
         function()
            return {{"elona.guard:lost_item", "talk.npc.guard.lost_wallet"}}
         end,
         function()
            return {{"elona.guard:lost_item", "talk.npc.guard.lost_suitcase"}}
         end,
      }
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
      _id = "maid",
      elona_id = 18
   },
   {
      _id = "sister",
      elona_id = 19
   },
   {
      _id = "custom_chara",
      elona_id = 20,
   },
   {
      _id = "returner",
      elona_id = 21,
   },
   {
      _id = "horse_master",
      elona_id = 22
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

data:add_multi("base.role", role)
