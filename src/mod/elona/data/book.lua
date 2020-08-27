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
   { _id = "my_diary" },
   { _id = "beginners_guide", is_randomly_generated = false },
   { _id = "its_a_bug", is_randomly_generated = false },
   { _id = "dont_read_this" },
   { _id = "museum_guide" },
   { _id = "crimberry_addict" },
   { _id = "cats_cradle" },
   { _id = "herb_effect" },
   { _id = "shopkeeper_guide" },
   { _id = "easy_gardening" },
   { _id = "water" },
   { _id = "breeders_guide" },
   { _id = "strange_diary" },
   { _id = "pyramid_invitation", is_randomly_generated = false },
   { _id = "card_game_manual" },
   { _id = "dungeon_guide" },
})
