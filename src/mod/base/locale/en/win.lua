return {
   win = {
      conquer_lesimas = "Unbelievable! You conquered Lesimas!",
      watch_event_again = "You want to watch this event again?",
      window = {
         arrived_at_tyris = function(_1, _2, _3)
            return ("In the year %s, %s/%s, you arrived at North Tyris.")
               :format(_1, _2, _3)
         end,
         caption = "Trace",
         comment = function(_1)
            return ("Upon killing Zeome, you said, \"%s\"")
               :format(_1)
         end,
         have_killed = function(_1, _2)
            return ("You've killed %s creature%s and reached\nmaximum of %s level of dungeons.")
               :format(_2, s(_2), ordinal(_1))
         end,
         lesimas = function(_1, _2, _3)
            return ("In the year %s, %s/%s, you conquered Lesimas.")
               :format(_1, _2, _3)
         end,
         score = function(_1)
            return ("Your score is %s point%s now.")
               :format(_1, s(_1))
         end,
         title = "*Win*",
         your_journey_continues = "Your journey continues..."
      },
      you_acquired_codex = function(_1, _2)
         return ("Blessing to %s, %s! You've finally acquired the codex!")
            :format(_2, _1)
      end,
      words = {
         _0 = "Finally!",
         _1 = "It's a matter of course.",
         _2 = "Woooooo!",
         _3 = "Heh.",
         _4 = "I can't sleep tonight.",
         _5 = "You're kidding."
      }
   }
}
