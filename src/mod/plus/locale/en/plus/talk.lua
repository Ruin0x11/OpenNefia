return {
   talk = {
      sleep_event = {
         breakfast = {
            function(_1)
               return ("%s looks like %s just finished diligently working."):format(name(_1), he(_1))
            end,
            function(_1)
               return ("%s %s fidgeting nervously a little."):format(name(_1), is(_1))
            end,
            "\"Hurry up or it's going to get cold.\"",
            "\"Breakfast is the most important meal of the day.\""
         },
         handmade_gift = {
            function(_1)
               return ("%s looks like %s just finished diligently working."):format(name(_1), he(_1))
            end,
            function(_1)
               return ("%s proudly displays the fruits of %s labor."):format(name(_1), his(_1))
            end,
            "\"Not bad, if I do say so myself.\"",
            "\"Ta-daaah!\""
         },
         handknitted_gift = {
            function(_1)
               return ("%s is trying to hide some cuts on %s hands."):format(name(_1), his(_1))
            end,
            "\"I put in lots of effort to make this.\"",
            "\"Even if you'd just sell it for the family income...\"",
            "It's kinda misshapen, but..."
         }
      }
   }
}
