data:add_type {
   name = "book",
   fields = {
      {
         name = "is_randomly_generated",
         default = true,
         template = true
      }
   }
}

data:add_multi("elona.book", {
   { _id = "my_diary", elona_id = 0 },
   { _id = "beginners_guide", elona_id = 1, is_randomly_generated = false },
   { _id = "its_a_bug", elona_id = 2, is_randomly_generated = false },
   { _id = "dont_read_this", elona_id = 3 },
   { _id = "museum_guide", elona_id = 4 },
   { _id = "crimberry_addict", elona_id = 5 },
   { _id = "cats_cradle", elona_id = 6 },
   { _id = "herb_effect", elona_id = 7 },
   { _id = "shopkeeper_guide", elona_id = 8 },
   { _id = "easy_gardening", elona_id = 9 },
   { _id = "water", elona_id = 10 },
   { _id = "breeders_guide", elona_id = 11 },
   { _id = "strange_diary", elona_id = 12 },
   { _id = "pyramid_invitation", elona_id = 13, is_randomly_generated = false },
   { _id = "card_game_manual", elona_id = 14 },
   { _id = "dungeon_guide", elona_id = 15 },
})
